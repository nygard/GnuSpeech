/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/oversampling_filter.c,v $
_State: Exp $


_Log: oversampling_filter.c,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.1.1.1  1994/09/06  21:45:52  len
 * Initial archive into CVS.
 *

******************************************************************************/



/*  HEADER FILES  ************************************************************/
#import "oversampling_filter.h"
#import <stdlib.h>
#import <math.h>


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
static int maximallyFlat(double beta, double gamma, int *np,
			 double *coefficient);
static void trim(double cutoff, int *numberCoefficients, double *coefficient);
static void rationalApproximation(double number, int *order, int *numerator,
				  int *denominator);


/*  LOCAL DEFINES  ***********************************************************/
#define TWO_PI               6.28318530717959

/*  CONSTANTS FOR THE FIR FILTER  */
#define LIMIT                200
#define BETA_OUT_OF_RANGE    1
#define GAMMA_OUT_OF_RANGE   2
#define GAMMA_TOO_SMALL      3




/******************************************************************************
*
*	function:	initializeFIR
*
*	purpose:	Allocates memory and initializes the coefficients
*                       for the FIR filter used in the oversampling oscillator.
*                       Returns a pointer to the allocated array, which must
*                       be cfree'ed by the caller.
*			
*       arguments:      beta, gamma, cutoff - FIR construction parameters
*                       numberTaps - number of coefficients used
*                       FIRCoef - pointer to coefficient array
*                       
*	internal
*	functions:	maximallyFlat, trim
*
*	library
*	functions:	calloc, DSPDoubleToFix24
*
******************************************************************************/

DSPFix24 *initializeFIR(double beta, double gamma, double cutoff,
			int *numberTaps, DSPFix24 *FIRCoef)
{
    int i, pointer, increment;
    double coefficient[LIMIT+1];
    int numberCoefficients;
    

    /*  DETERMINE IDEAL LOW PASS FILTER COEFFICIENTS  */
    maximallyFlat(beta, gamma, &numberCoefficients, coefficient);

    /*  TRIM LOW-VALUE COEFFICIENTS  */
    trim(cutoff, &numberCoefficients, coefficient);

    /*  DETERMINE THE NUMBER OF TAPS IN THE FILTER  */
    *numberTaps = (numberCoefficients * 2) - 1;

    /*  ALLOCATE MEMORY FOR TO HOLD COEFFICIENTS  */
    FIRCoef = (DSPFix24 *)calloc(*numberTaps, sizeof(DSPFix24));

    /*  INITIALIZE THE COEFFICIENT ARRAY  */
    increment = (-1);
    pointer = numberCoefficients;
    for (i = 0; i < *numberTaps; i++) {
	FIRCoef[i] = DSPDoubleToFix24(coefficient[pointer]);
	pointer += increment;
	if (pointer <= 0) {
	    pointer = 2;
	    increment = 1;
	}
    }

    return(FIRCoef);
}



/******************************************************************************
*
*	function:	maximallyFlat
*
*	purpose:	Calculates coefficients for a linear phase lowpass FIR
*                       filter, with beta being the center frequency of the
*                       transition band (as a fraction of the sampling
*                       frequency), and gamma the width of the transition
*                       band.
*			
*       arguments:      beta, gamma, np, coefficient
*                       
*	internal
*	functions:	rationalApproximation
*
*	library
*	functions:	cos, pow
*
******************************************************************************/

int maximallyFlat(double beta, double gamma, int *np, double *coefficient)
{
    double a[LIMIT+1], c[LIMIT+1];
    double betaMinimum, ac;
    int nt, numerator, n;
    int ll, i;


    /*  INITIALIZE NUMBER OF POINTS  */
    (*np) = 0;

    /*  CUT-OFF FREQUENCY MUST BE BETWEEN 0 HZ AND NYQUIST  */
    if ((beta <= 0.0) || (beta >= 0.5))
	return(BETA_OUT_OF_RANGE);

    /*  TRANSITION BAND MUST FIT WITH THE STOP BAND  */
    betaMinimum =
	((2.0 * beta) < (1.0 - 2.0 * beta)) ? (2.0 * beta) :
	    (1.0 - 2.0 * beta);
    if ((gamma <= 0.0) || (gamma >= betaMinimum))
	return(GAMMA_OUT_OF_RANGE);

    /*  MAKE SURE TRANSITION BAND NOT TOO SMALL  */
    nt = (int)(1.0 / (4.0 * gamma * gamma));
    if (nt > 160)
	return(GAMMA_TOO_SMALL);

    /*  CALCULATE THE RATIONAL APPROXIMATION TO THE CUT-OFF POINT  */
    ac = (1.0 + cos(TWO_PI * beta)) / 2.0;
    rationalApproximation(ac, &nt, &numerator, np);

    /*  CALCULATE FILTER ORDER  */
    n = (2 * (*np)) - 1;
    if (numerator == 0)
	numerator = 1;


    /*  COMPUTE MAGNITUDE AT NP POINTS  */
    c[1] = a[1] = 1.0;
    ll = nt - numerator;

    for (i = 2; i <= (*np); i++) {
	int j;
	double x, sum = 1.0, y;
	c[i] = cos(TWO_PI * ((double)(i-1)/(double)n));
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


    /*  CALCULATE WEIGHTING COEFFICIENTS BY AN N-POINT IDFT  */
    for (i = 1; i <= (*np); i++) {
	int j;
	coefficient[i] = a[1] / 2.0;
	for (j = 2; j <= (*np); j++) {
	    int m = ((i - 1) * (j - 1)) % n;
	    if (m > nt)
		m = n - m;
	    coefficient[i] += c[m+1] * a[j];
	}
	coefficient[i] *= 2.0/(double)n;
    }

    return(0);
}



/******************************************************************************
*
*	function:	trim
*
*	purpose:	Trims the higher order coefficients of the FIR filter
*                       which fall below the cutoff value.
*			
*       arguments:      cutoff, numberCoefficients, coefficient
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void trim(double cutoff, int *numberCoefficients, double *coefficient)
{
    int i;


    for (i = (*numberCoefficients); i > 0; i--) {
	if (fabs(coefficient[i]) >= fabs(cutoff)) {
	    (*numberCoefficients) = i;
	    return;
	}
    }
}



/******************************************************************************
*
*	function:	rationalApproximation
*
*	purpose:	Calculates the best rational approximation to 'number',
*                       given the maximum 'order'.
*			
*       arguments:      number, order, numerator, denominator
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	fabs
*
******************************************************************************/

void rationalApproximation(double number, int *order,
			   int *numerator, int *denominator)
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
