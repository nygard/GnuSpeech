/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/sr_conversion.c,v $
_State: Exp $


_Log: sr_conversion.c,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.1.1.1  1994/09/06  21:45:50  len
 * Initial archive into CVS.
 *

******************************************************************************/



/*  HEADER FILES  ************************************************************/
#include "sr_conversion.h"
#include <math.h>
#include <stdio.h>


/*  LOCAL DEFINES  ***********************************************************/
#define PI              3.14159265358979
#define IzeroEPSILON    1E-21




/******************************************************************************
*
*	function:	initialize_sr_conversion
*
*	purpose:	Creates the windowed lowpass impulse function for
*                       sample rate conversion.  Also creates the deltas.
*			
*       arguments:      zero_crossings:  number of zero crossings
*                                        (one side only)
*                       l_bits:    the number of bits used to index each zero
*                                  crossing.  2^l_bits = samples/zero-crossing
*                       beta:      Kaiser window parameter
*                       lp_cutoff: the low pass cutoff frequency, as a factor
*                                  (0 to 1.0) of Nyquist (1.0 = ideal low pass
*                                  filter with cutoff at sample_rate/2.
*                       h:         newly allocated and calculated array of
*                                  sampled impulse function
*			hDelta:    newly allocated and calculated array of 
*                                  delta values
*                       filterLength:  calculated length of filter function
*                                      (both negative and positive sides)
*
*	internal
*	functions:	Izero
*
*	library
*	functions:	pow, calloc, sin, cos, sqrt, DSPDoubleToFix24, cfree
*
******************************************************************************/

void initialize_sr_conversion(int zero_crossings, int l_bits, float beta,
			      float lp_cutoff, DSPFix24 *h[],
			      DSPFix24 *hDelta[], int *filterLength)
{
    int i, j, k, l_range, filter_limit, mid_point;
    double x, y, temp, *impulse, *impulseDelta, guardSample;
    double IBeta, halfLength;


    /*  CALCULATE l_range  */
    l_range = (int)pow(2.0,(double)l_bits);

    /*  CALCULATE DIVISOR  */
    x = PI / (double)l_range;

    /*  CALCULATE filterLength  */
    *filterLength = zero_crossings * 2 * l_range;

    /*  CALCULATE filter_limit  */
    filter_limit = *filterLength - 1;

    /*  CALCULATE mid_point AND halfLength  */
    mid_point = *filterLength / 2;
    halfLength = (double)mid_point;

    /*  ALLOCATE FILTER AND FILTER DELTA TEMPORARY BUFFERS  */
    impulse = calloc(*filterLength, sizeof(double));
    impulseDelta = calloc(*filterLength, sizeof(double));

    /*  ALLOCATE FILTER AND FILTER DELTA MEMORY  */
    *h = (DSPFix24 *)calloc(*filterLength, sizeof(DSPFix24));
    *hDelta = (DSPFix24 *)calloc(*filterLength, sizeof(DSPFix24));

    /*  MID-POINT IS ALWAYS EQUAL TO LOWPASS CUTOFF  */
    impulse[mid_point] = lp_cutoff;

    /*  CALCULATE IMPULSE RESPONSE, AND APPLY KAISER WINDOW  */
    IBeta = 1.0 / Izero(beta);
    for (i = (mid_point+1), j = (mid_point-1), k = 1;
	 i < *filterLength;
	 i++, j--, k++) {
	y = (double)k * x;
	temp = (double)k / halfLength;

	impulse[i] = impulse[j] = (sin(y * lp_cutoff) / y) *
	    (Izero(beta * sqrt(1.0 - (temp * temp))) * IBeta);
    }

    /*  CALCULATE 1ST SAMPLE AND GUARD SAMPLE  */
    y = (double)k * x;
    temp = (double)k / halfLength;
    guardSample = impulse[0] =  (sin(y * lp_cutoff) / y) *
	(Izero(beta * sqrt(1.0 - temp*temp)) * IBeta);


    /*  CALCULATE THE DELTA VALUES  */
    for (i = 0; i < filter_limit; i++)
	impulseDelta[i] = impulse[i+1] - impulse[i];
    impulseDelta[filter_limit] = guardSample - impulse[filter_limit];


    /*  CONVERT DOUBLE VALUES TO DSPFix24's, PUT INTO NEW BUFFERS  */
    for (i = 0; i < *filterLength; i++) {
	(*h)[i] = DSPDoubleToFix24(impulse[i]);
	(*hDelta)[i] = DSPDoubleToFix24(impulseDelta[i]);
    }
    
    /*  FREE TEMPORARY BUFFERS  */
    cfree((char *)impulse);
    cfree((char *)impulseDelta);
}



/******************************************************************************
*
*	function:	Izero
*
*	purpose:	Returns the value for the modified Bessel function of
*                       the first kind, order 0, as a double.
*			
*       arguments:      x - input argument
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double Izero(double x)
{
    double sum, u, halfx, temp;
    int n;

    sum = u = n = 1;
    halfx = x / 2.0;

    do {
	temp = halfx / (double)n;
	n += 1;
	temp *= temp;
	u *= temp;
	sum += u;
    } while (u >= (IzeroEPSILON * sum));

    return(sum);
}
