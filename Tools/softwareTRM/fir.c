#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "fir.h"

#import <vecLib/vecLib.h>

/*  CONSTANTS FOR THE FIR FILTER  */
#define LIMIT                     200
#define BETA_OUT_OF_RANGE         1
#define GAMMA_OUT_OF_RANGE        2
#define GAMMA_TOO_SMALL           3


static int maximallyFlat(double beta, double gamma, int *np, double *coefficient);
static void trim(double cutoff, int *numberCoefficients, double *coefficient);
static int decrement(int pointer, int modulus);
static void rationalApproximation(double number, int *order, int *numerator, int *denominator);

// Allocates memory and initializes the coefficients for the FIR filter used in the oversampling oscillator.

TRMFIRFilter *TRMFIRFilterCreate(double beta, double gamma, double cutoff)
{
    TRMFIRFilter *newFilter;

    int i, pointer, increment, coefficientCount;
    double coefficient[LIMIT+1];

    //printf("TRMFIRFilterCreate(beta=%g, gamma=%g, cutoff=%.10f\n", beta, gamma, cutoff);

    newFilter = (TRMFIRFilter *)malloc(sizeof(TRMFIRFilter));
    if (newFilter == NULL) {
        fprintf(stderr, "Couldn't malloc() FIRFilter.\n");
        return NULL;
    }

    // Determine ideal low pass filter coefficients
    maximallyFlat(beta, gamma, &coefficientCount, coefficient);

#if 0
    printf("coefficientCount: %d\n", coefficientCount);
    for (i = 0; i < coefficientCount; i++)
        printf("coef[%2d]: %17.10f\n", i, coefficient[i]);
#endif
    //printf("----------------------------------------------------------------------\n");

    // Trim low-value coefficients
    trim(cutoff, &coefficientCount, coefficient);
    //printf("trimmed coefficientCount: %d\n", coefficientCount);

    // Determine the number of taps in the filter
    newFilter->tapCount = (coefficientCount * 2) - 1;
    //printf("newFilter->tapCount: %d\n", newFilter->tapCount);

    newFilter->coefficients = (double *)calloc(newFilter->tapCount * 2, sizeof(double));
    if (newFilter->coefficients == NULL) {
        fprintf(stderr, "calloc() of coefficients failed.\n");
        free(newFilter);
        return NULL;
    }

    // Allocate memory for data and coefficients
    newFilter->data = (double *)calloc(newFilter->tapCount, sizeof(double));
    if (newFilter->data == NULL) {
        fprintf(stderr, "calloc() of data failed.\n");
        free(newFilter->coefficients);
        free(newFilter);
        return NULL;
    }

    // Initialize the coefficients
    increment = -1;
    pointer = coefficientCount;
    for (i = 0; i < newFilter->tapCount; i++) {
        newFilter->coefficients[i] = coefficient[pointer];
        //printf("newFilter->coefficients[%2d] = coefficients[%2d] = %17.10f\n", i, pointer, coefficient[pointer]);
        pointer += increment;
        if (pointer <= 0) {
            pointer = 2;
            increment = 1;
        }
    }

    // Make a copy of the coefficients
    newFilter->middlePtr = newFilter->coefficients + newFilter->tapCount;
    for (i = 0; i < newFilter->tapCount; i++)
        newFilter->middlePtr[i] = newFilter->coefficients[i];

    newFilter->dataIndex = 0;

#if DEBUG
    printf("\n");
    for (i = 0; i < newFilter->tapCount; i++)
        printf("coefficients[%-d] = %11.8f\n", i, newFilter->coefficients[i]);
#endif

    return newFilter;
}

void TRMFIRFilterFree(TRMFIRFilter *filter)
{
    if (filter == NULL)
        return;

    if (filter->coefficients != NULL) {
        free(filter->coefficients);
        filter->coefficients = NULL;
    }

    if (filter->data != NULL) {
        free(filter->data);
        filter->data = NULL;
    }

    free(filter);
}

/******************************************************************************
*
*       function:       FIRFilter
*
*       purpose:        Is the linear phase, lowpass FIR filter.
*
******************************************************************************/

double FIRFilter(TRMFIRFilter *filter, double input, int needOutput)
{
    double output = 0.0;
    double *start;

    // Put input sample into data buffer
    filter->data[filter->dataIndex] = input;
    //printf("----------------------------------------------------------------------\n");
    //printf("Added value at index %d, value: %17.10f, needOutput: %d\n", filter->dataIndex, input, needOutput);

    if (needOutput) {
        int i;
#if 0
        double out[LIMIT];

        // This is actually a bit slower than the regular loop.  Not enough coefficients, and not necessarily aligned properly.
        start = filter->middlePtr - filter->dataIndex;
        vmulD(start, 1, filter->data, 1, out, 1, filter->tapCount);
        for (i = 0; i < filter->tapCount; i++)
            output += out[i];
#endif
#if 1
        // Sum the output from all filter taps
        start = filter->middlePtr - filter->dataIndex;
        for (i = 0; i < filter->tapCount; i++) {
            output += filter->data[i] * start[i];
        }
#endif
    }

    // Adjust the data pointer, ready for next call
    filter->dataIndex = decrement(filter->dataIndex, filter->tapCount);
    //printf("dataIndex index is now %d\n", filter->dataIndex);

    //printf("FIRFilter(%g, %d) = %g\n", input, needOutput, 0.0);
    return output;
}

//
// Local functions
//

/******************************************************************************
*
*       function:       maximallyFlat
*
*       purpose:        Calculates coefficients for a linear phase lowpass FIR
*                       filter, with beta being the center frequency of the
*                       transition band (as a fraction of the sampling
*                       frequency), and gamme the width of the transition
*                       band.
*
******************************************************************************/

int maximallyFlat(double beta, double gamma, int *np, double *coefficient)
{
    double a[LIMIT+1], c[LIMIT+1], betaMinimum, ac;
    int nt, numerator, n, ll, i;


    // Initialize number of points
    (*np) = 0;

    // Cut-off frequency must be between 0 HZ and Nyquist
    if ((beta <= 0.0) || (beta >= 0.5))
        return BETA_OUT_OF_RANGE;

    // Transition band must fit with the stop band
    betaMinimum = ((2.0 * beta) < (1.0 - 2.0 * beta)) ? (2.0 * beta) :
        (1.0 - 2.0 * beta);
    if ((gamma <= 0.0) || (gamma >= betaMinimum))
        return GAMMA_OUT_OF_RANGE;

    // Make sure transition band not too small
    nt = (int)(1.0 / (4.0 * gamma * gamma));
    if (nt > 160)
        return GAMMA_TOO_SMALL;

    // Calculate the rational approximation to the cut-off point
    ac = (1.0 + cos(2.0 * M_PI * beta)) / 2.0;
    rationalApproximation(ac, &nt, &numerator, np);

    //  Calculate filter order
    n = (2 * (*np)) - 1;
    if (numerator == 0)
        numerator = 1;


    // Compute magnitude at np points
    c[1] = a[1] = 1.0;
    ll = nt - numerator;

    for (i = 2; i <= (*np); i++) {
        int j;
        double x, sum = 1.0, y;
        c[i] = cos(2.0 * M_PI * ((double)(i-1)/(double)n));
        x = (1.0 - c[i]) / 2.0;
        y = x;

        if (numerator == nt)
            continue;

        for (j = 1; j <= ll; j++) {
            double z = y;
            if (numerator != 1) {
                int jj;
                for (jj = 1; jj <= (numerator - 1); jj++)
                    z *= 1.0 + ((double)j / (double)jj);
            }
            y *= x;
            sum += z;
        }
        a[i] = sum * pow((1.0 - x), numerator);
    }


    // Calculate weighting coefficients by an N-point IDFT
    for (i = 1; i <= (*np); i++) {
        int j;
        coefficient[i] = a[1] / 2.0;
        for (j = 2; j <= (*np); j++) {
            int m = ((i - 1) * (j - 1)) % n;
            if (m > nt)
                m = n - m;
            coefficient[i] += c[m+1] * a[j];
        }
        coefficient[i] *= 2.0 / (double)n;
    }

    return 0;
}



/******************************************************************************
*
*       function:       trim
*
*       purpose:        Trims the higher order coefficients of the FIR filter
*                       which fall below the cutoff value.
*
******************************************************************************/

void trim(double cutoff, int *coefficientCount, double *coefficient)
{
    int i;

    for (i = *coefficientCount; i > 0; i--) {
        if (fabs(coefficient[i]) >= fabs(cutoff)) {
            *coefficientCount = i; // TODO (2004-08-26): Shouldn't this really be i+1, so that it includes this coefficient?
            return;
        }
    }
}



/******************************************************************************
*
*       function:       decrement
*
*       purpose:        Decrements the pointer to the circular FIR filter
*                       buffer, keeping it in the range 0 -> modulus-1.
*
******************************************************************************/

int decrement(int pointer, int modulus)
{
    if (--pointer < 0)
        return modulus - 1;

    return pointer;
}



/******************************************************************************
*
*       function:       rationalApproximation
*
*       purpose:        Calculates the best rational approximation to 'number',
*                       given the maximum 'order'.
*
******************************************************************************/

void rationalApproximation(double number, int *order, int *numerator, int *denominator)
{
    double fractionalPart, minimumError = 1.0;
    int i, orderMaximum, modulus = 0;


    /*  RETURN IMMEDIATELY IF THE ORDER IS LESS THAN ONE  */
    if (*order <= 0) {
        *numerator = 0;
        *denominator = 0;
        *order = -1;
        return;
    }

    /*  FIND THE ABSOLUTE VALUE OF THE FRACTIONAL PART OF THE NUMBER  */
    fractionalPart = fabs(number - (int)number);

    /*  DETERMINE THE MAXIMUM VALUE OF THE DENOMINATOR  */
    orderMaximum = 2 * (*order);
    orderMaximum = (orderMaximum > LIMIT) ? LIMIT : orderMaximum;

    /*  FIND THE BEST DENOMINATOR VALUE  */
    for (i = (*order); i <= orderMaximum; i++) {
        double ps = i * fractionalPart;
        int ip = (int)(ps + 0.5);
        double error = fabs( (ps - (double)ip)/(double)i );
        if (error < minimumError) {
            minimumError = error;
            modulus = ip;
            *denominator = i;
        }
    }

    /*  DETERMINE THE NUMERATOR VALUE, MAKING IT NEGATIVE IF NECESSARY  */
    *numerator = (int)fabs(number) * (*denominator) + modulus;
    if (number < 0)
        *numerator *= (-1);

    /*  SET THE ORDER  */
    *order = *denominator - 1;

    /*  RESET THE NUMERATOR AND DENOMINATOR IF THEY ARE EQUAL  */
    if (*numerator == *denominator) {
        *denominator = orderMaximum;
        *order = *numerator = *denominator - 1;
    }
}
