/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/scaling.c,v $
_State: Exp $


_Log: scaling.c,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.1  1995/04/04  01:57:47  len
 * Added "median pitch" volume scaling.
 *

******************************************************************************/

/*  HEADER FILES  ************************************************************/
#import <stdio.h>
#import <math.h>
#import "conversion.h"


/*  LOCAL DEFINES  ***********************************************************/
#define PI                 3.14159265358979


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
static float hpGain(float frequency, float hpCoefficient, float sampleRate);




/******************************************************************************
*
*	function:	scaling
*
*	purpose:	Returns a value used to scale the overall amplitude
*                       of the synthesizer, based on the gain of the highpass
*			radiation filter and the approximate median pitch
*                       of the glottal source.
*
*       arguments:      medianPitch - center pitch of the voice
*                       hpCoefficient - highpass filter coefficient
*                       sampleRate - current system sample rate
*
*	internal
*	functions:	hpGain, frequency
*
*	library
*	functions:	none
*
******************************************************************************/

float scaling(float medianPitch, float hpCoefficient, float sampleRate)
{
    return(0.3281848/hpGain(frequency(medianPitch),hpCoefficient,sampleRate));
}



/******************************************************************************
*
*	function:	hpGain
*
*	purpose:	Returns the gain of the highpass filter (a value from
*                       0.0 to 1.0) according to the filter coefficient,
*                       at the specified frequency (range 0 to nyquist).
*			
*       arguments:      frequency - frequency at which gain is to be calculated
*                       hpCoefficient - high pass coefficient (0 to nyquist)
*                       sampleRate - current system sample rate
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	cos, sin, sqrt
*
******************************************************************************/

static float hpGain(float frequency, float hpCoefficient, float sampleRate)
{
    float omega, a0, a1, b1, a, b, c, d, cosOmega, sinOmega, nyquist;


    /*  CALCULATE NYQUIST FREQUENCY  */
    nyquist = sampleRate / 2.0;

    /*  CALCULATE OMEGA (FREQUENCY SCALED TO BETWEEN 0 AND PI)  */
    omega = PI * frequency / nyquist;

    /*  CALCULATE FILTER COEFFICIENTS  */
    a0 = (nyquist - hpCoefficient) / nyquist;
    a1 = b1 = -a0;

    /*  CALCULATE AND RETURN GAIN AT SPECIFIED FREQUENCY  */
    cosOmega = cos(omega);
    sinOmega = sin(omega);

    a = a0 + (a1 * cosOmega);
    b = -a1 * sinOmega;
    c = 1.0 + (b1 * cosOmega);
    d = -b1 * sinOmega;

    return( sqrt((a * a) + (b * b)) / sqrt((c * c) + (d * d)) );
}
