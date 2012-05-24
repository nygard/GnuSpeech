//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMFIRFilter.h"

#include <stdlib.h>
#include <math.h>

// Math constants
#define TWO_PI                    (2.0 * M_PI)

// Constants for the FIR filter
#define COEFFICIENT_LIMIT         200

// Error return codes for maximallyFlat()
#define BETA_OUT_OF_RANGE         1
#define GAMMA_OUT_OF_RANGE        2
#define GAMMA_TOO_SMALL           3


static int32_t maximallyFlat(double beta, double gamma, int32_t *np, double *coefficient);
static void trim(double cutoff, int32_t *numberCoefficients, double *coefficient);
static int32_t increment(int32_t pointer, int32_t modulus); // TODO (2012-04-28): Change name, make sure it doesn't get confused with local variables
static int32_t decrement(int32_t pointer, int32_t modulus);
static void rationalApproximation(double number, int32_t *order, int32_t *numerator, int32_t *denominator);

// Allocates memory and initializes the coefficients for the FIR filter used in the oversampling oscillator.

@implementation TRMFIRFilter
{
    double *m_FIRData;
    double *m_FIRCoef;
    int32_t m_FIRPtr;
    int32_t m_numberTaps;
}

- (id)initWithBeta:(double)beta gamma:(double)gamma cutoff:(double)cutoff;
{
    if ((self = [super init])) {
        int32_t numberCoefficients;
        double coefficient[COEFFICIENT_LIMIT+1];
        
        // Determine ideal low pass filter coefficients
        maximallyFlat(beta, gamma, &numberCoefficients, coefficient);
        
        // Trim low-value coefficients
        trim(cutoff, &numberCoefficients, coefficient);
        
        // Determine the number of taps in the filter
        m_numberTaps = (numberCoefficients * 2) - 1;
        
        // Allocate memory for data and coefficients
        m_FIRData = (double *)calloc(m_numberTaps, sizeof(double));
        if (m_FIRData == NULL) {
            fprintf(stderr, "calloc() of FIRData failed.\n");
            [self release];
            return nil;
        }
        
        m_FIRCoef = (double *)calloc(m_numberTaps, sizeof(double));
        if (m_FIRCoef == NULL) {
            fprintf(stderr, "calloc() of FIRCoef failed.\n");
            free(m_FIRData);
            [self release];
            return nil;
        }
        
        // Initialize the coefficients
        int32_t increment = -1;
        int32_t pointer = numberCoefficients;
        for (uint32_t index = 0; index < m_numberTaps; index++) {
            m_FIRCoef[index] = coefficient[pointer];
            pointer += increment;
            if (pointer <= 0) {
                pointer = 2;
                increment = 1;
            }
        }
        
        // Set pointer to first element
        m_FIRPtr = 0;
        
#if DEBUG
        printf("\n");
        for (uint32_t index = 0; index < m_numberTaps; index++)
            printf("FIRCoef[%-d] = %11.8f\n", index, m_FIRCoef[index]);
#endif
    }

    return self;
}

- (void)dealloc;
{
    if (m_FIRData != NULL) {
        free(m_FIRData);
        m_FIRData = NULL;
    }

    if (m_FIRCoef != NULL) {
        free(m_FIRCoef);
        m_FIRCoef = NULL;
    }

    [super dealloc];
}

#pragma mark -

// Is the linear phase, lowpass FIR filter.
- (double)filterInput:(double)input needOutput:(BOOL)needOutput;
{
    if (needOutput) {
        double output = 0.0;
        
        // Put input sample into data buffer
        m_FIRData[m_FIRPtr] = input;
        
        // Sum the output from all filter taps
        for (int32_t i = 0; i < m_numberTaps; i++) {
            output += m_FIRData[m_FIRPtr] * m_FIRCoef[i];
            m_FIRPtr = increment(m_FIRPtr, m_numberTaps);
        }
        
        // Decrement the data pointer ready for next call
        m_FIRPtr = decrement(m_FIRPtr, m_numberTaps);
        
        // Return the output value
        //printf("FIRFilter(%g, %d) = %g\n", input, needOutput, output);
        return output;
    } else {
        // Put input sample into data buffer
        m_FIRData[m_FIRPtr] = input;
        
        // Adjust the data pointer, ready for next call
        m_FIRPtr = decrement(m_FIRPtr, m_numberTaps);
        
        //printf("FIRFilter(%g, %d) = %g\n", input, needOutput, 0.0);
        return 0.0;
    }
}

@end

#pragma mark - Supporting C functions


// Calculates coefficients for a linear phase lowpass FIR  filter, with beta being the center frequency of the
// transition band (as a fraction of the sampling frequency), and gamma the width of the transition band.

// Returns 0 on success, or:
//   BETA_OUT_OF_RANGE
//   GAMMA_OUT_OF_RANGE
//   GAMMA_TOO_SMALL

int maximallyFlat(double beta, double gamma, int32_t *np, double *coefficient)
{
    // Initialize number of points
    (*np) = 0;

    // Cut-off frequency must be between 0 HZ and Nyquist
    if ((beta <= 0.0) || (beta >= 0.5))
        return BETA_OUT_OF_RANGE;
    
    // Transition band must fit with the stop band
    double betaMinimum = ((2.0 * beta) < (1.0 - 2.0 * beta)) ? (2.0 * beta) : (1.0 - 2.0 * beta);
    if ((gamma <= 0.0) || (gamma >= betaMinimum))
        return GAMMA_OUT_OF_RANGE;
    
    // Make sure transition band not too small
    int32_t nt = (int32_t)(1.0 / (4.0 * gamma * gamma));
    if (nt > 160)
        return GAMMA_TOO_SMALL;

    // Calculate the rational approximation to the cut-off point
    double ac = (1.0 + cos(TWO_PI * beta)) / 2.0;
    
    int32_t numerator;
    rationalApproximation(ac, &nt, &numerator, np);

    // Calculate filter order
    int32_t n = (2 * (*np)) - 1;
    if (numerator == 0)
        numerator = 1;

    
    double a[COEFFICIENT_LIMIT+1], c[COEFFICIENT_LIMIT+1];

    // Compute magnitude at NP points
    c[1] = a[1] = 1.0;
    int32_t ll = nt - numerator;

    for (int32_t i = 2; i <= (*np); i++) {
        double sum = 1.0;
        c[i] = cos(TWO_PI * ((double)(i-1)/(double)n));
        double x = (1.0 - c[i]) / 2.0;
        double y = x;
        
        if (numerator == nt)
            continue;
        
        for (int32_t j = 1; j <= ll; j++) {
            double z = y;
            if (numerator != 1) {
                for (int32_t jj = 1; jj <= (numerator - 1); jj++)
                    z *= 1.0 + ((double)j / (double)jj);
            }
            y *= x;
            sum += z;
        }
        a[i] = sum * pow((1.0 - x), numerator);
    }


    /*  CALCULATE WEIGHTING COEFFICIENTS BY AN N-POINT IDFT  */
    for (int32_t i = 1; i <= (*np); i++) {
        coefficient[i] = a[1] / 2.0;
        for (int32_t j = 2; j <= (*np); j++) {
            int m = ((i - 1) * (j - 1)) % n;
            if (m > nt)
                m = n - m;
            coefficient[i] += c[m+1] * a[j];
        }
        coefficient[i] *= 2.0 / (double)n;
    }

    return 0;
}

// Trims the higher order coefficients of the FIR filter which fall below the cutoff value.
void trim(double cutoff, int32_t *numberCoefficients, double *coefficient)
{
    for (int32_t i = (*numberCoefficients); i > 0; i--) {
        if (fabs(coefficient[i]) >= fabs(cutoff)) {
            (*numberCoefficients) = i;
            return;
        }
    }
}

// Increments the pointer to the circular FIR filter buffer, keeping it in the range 0 -> modulus-1.
int32_t increment(int32_t pointer, int32_t modulus)
{
    if (++pointer >= modulus)
        return 0;

    return pointer;
}

// Decrements the pointer to the circular FIR filter buffer, keeping it in the range 0 -> modulus-1.
int32_t decrement(int32_t pointer, int32_t modulus)
{
    if (--pointer < 0)
        return modulus - 1;

    return pointer;
}

// Calculates the best rational approximation to 'number', given the maximum 'order'.
void rationalApproximation(double number, int32_t *order, int32_t *numerator, int32_t *denominator)
{
    // Return immediately if the order is less than one
    if (*order <= 0) {
        *numerator = 0;
        *denominator = 0;
        *order = -1;
        return;
    }

    // Find the absolute value of the fractional part of the number
    double fractionalPart = fabs(number - (int)number);

    // Determine the maximum value of the denominator
    int32_t orderMaximum = 2 * (*order);
    orderMaximum = (orderMaximum > COEFFICIENT_LIMIT) ? COEFFICIENT_LIMIT : orderMaximum;

    int32_t modulus = 0;
    double minimumError = 1.0;

    // Find the best denominator value
    for (int32_t i = (*order); i <= orderMaximum; i++) {
        double ps = i * fractionalPart;
        int ip = (int)(ps + 0.5);
        double error = fabs( (ps - (double)ip)/(double)i );
        if (error < minimumError) {
            minimumError = error;
            modulus = ip;
            *denominator = i;
        }
    }

    // Determine the numerator value, making it negative if necessary
    *numerator = (int)fabs(number) * (*denominator) + modulus;
    if (number < 0)
        *numerator *= (-1);

    // set the order
    *order = *denominator - 1;

    // Reset the numerator and denominator if they are equal
    if (*numerator == *denominator) {
        *denominator = orderMaximum;
        *order = *numerator = *denominator - 1;
    }
}
