/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/conversion.c,v $
_State: Exp $


_Log: conversion.c,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.4  1995/04/04  01:57:45  len
 * Added "median pitch" volume scaling.
 *
 * Revision 1.3  1995/03/02  02:55:25  len
 * Added means to call user-supplied page_consumed function, added means to
 * set the pad page to user-specified silence, and changed the controlRate
 * variable to a float.
 *
 * Revision 1.2  1994/11/18  04:28:36  len
 * Added high/low (22050/44100 Hz.) output sample rate switch.
 *
 * Revision 1.1.1.1  1994/09/06  21:45:50  len
 * Initial archive into CVS.
 *

******************************************************************************/



/*  HEADER FILES  ************************************************************/
#import "conversion.h"
#import "synthesizer_module.h"
#import "sr_conversion.h"
#import <math.h>


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static float sampleRate, tableFactor, apSc_2, n1_2;




/******************************************************************************
*
*	function:	optimizeConversion
*
*	purpose:	Precalculates and stores some variables to speed up
*                       conversion in the other functions.
*			
*       arguments:      srate - the current sample rate.
*                       waveform - the current waveform type.
*                       apScale - the effective air radius (aperture Scaling).
*                       n1 - the fixed first nasal section radius (in cm.).
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void optimizeConversion(float srate, int waveform, float apScale, float n1)
{
    int tableSize;


    /*  RECORD SAMPLE RATE  */
    sampleRate = srate;

    /*  SET WAVEFORM TABLE SIZE  */
    if (waveform == WAVEFORM_TYPE_GP)
	tableSize = GP_TABLE_SIZE;
    else
	tableSize = SINE_TABLE_SIZE;

    /*  CALCULATE AND STORE TABLE FACTOR  */
    tableFactor = (float)tableSize / (OVERSAMPLE * sampleRate);

    /*  PRECALCULATE APERTURE SCALING SQUARED  */
    if (apScale < APERTURE_SCALE_MIN)
	apScale = APERTURE_SCALE_MIN;
    apSc_2 = apScale * apScale;

    /*  PRECALCULATE N1 RADIUS SQUARED  */
    n1_2 = n1 * n1;
}



/******************************************************************************
*
*	function:	convertLength
*
*	purpose:	Converts tube length and temperature to the equivalent
*                       control period and sample rate.
*			
*       arguments:      length - length of the tube, in cm.
*                       temperature - temperature of the tube, in degrees C.
*                       controlRate - control rate, in Hz.
*                       period - calculated control period.
*                       srate - calculated sample rate.
*
*	internal
*	functions:	speedOfSound
*
*	library
*	functions:	rint
*
******************************************************************************/

void convertLength(float length, float temperature, float controlRate,
		   int *period, float *srate)
{
    /*  CALCULATE THE CONTROL PERIOD  */
    *period = (int)rint((speedOfSound(temperature) * TOTAL_SECTIONS * 100.0) /
			(length * controlRate));

    /*  CALCULATE THE NEAREST SAMPLE RATE  */
    *srate = controlRate * (float)*period;
}



/******************************************************************************
*
*	function:	convertToTimeRegister
*
*	purpose:	Converts the sample rate to the equivalent integer
*                       and fractional parts of the sample rate conversion
*			time register increment.
*
*       arguments:      srate - input sample rate.
*                       outputSampleRate - D/A converter sample rate.
*                       integerPart - calculated integer part of the time
*                                     register increment.
*                       fractionalPart - calculated fractional part of the
*                                        time register increment.
*	internal
*	functions:	none
*
*	library
*	functions:	rint, pow
*
******************************************************************************/

void convertToTimeRegister(float srate, float outputSampleRate,
			   int *integerPart, int *fractionalPart)
{
    /*  CALCULATE NEW TIME REGISTER INCREMENT  */
    double timeRegisterIncrement =
	rint(pow(2.0,FRACTION_BITS) * srate / outputSampleRate);

    /*  CALCULATE INTEGER PART  */
    *integerPart = (int)(timeRegisterIncrement / pow(2.0,M_BITS));

    /*  CALCULATE FRACTIONAL PART  */
    *fractionalPart = (int)(timeRegisterIncrement -
			    ((double)(*integerPart) * pow(2.0,M_BITS)));
}



/******************************************************************************
*
*	function:	scatteringCoefficient
*
*	purpose:	Returns the scattering coefficient for two adjacent
*                       sections, given their radii in cm.
*			
*       arguments:      radius1 - section 1 radius, in cm.
*                       radius2 - section 2 radius, in cm.
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

float scatteringCoefficient(float radius1, float radius2)
{
    float r1_2, r2_2;
    

    /*  RETURN IMMEDIATELY IF BOTH ARGUMENTS ARE ZERO (AVOID ZERO DIVIDE)  */
    if ((radius1 == 0.0) && (radius2 == 0.0))
	return(0.0);

    /*  CALCULATE SQUARED VALUES  */
    r1_2 = radius1 * radius1;
    r2_2 = radius2 * radius2;

    /*  RETURN THE SCATTERING COEFFICIENT  */
    return((r1_2 - r2_2) / (r1_2 + r2_2));
}



/******************************************************************************
*
*	function:	endCoefficient
*
*	purpose:	Returns the scattering coefficient for the junction
*                       between the tube end section and air, given their
*                       radii in cm.  The aperture scaling squared is
*                       precalculated to save time.
*			
*       arguments:      radius - radius of the end tube section, in cm.
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

float endCoefficient(float radius)
{
    float r1_2;


    /*  CALCULATE SQUARED VALUE  */
    r1_2 = radius * radius;

    /*  RETURN THE SCATTERING COEFFICIENT  */
    return((r1_2 - apSc_2) / (r1_2 + apSc_2));
}



/******************************************************************************
*
*	function:	n0Coefficient
*
*	purpose:	Returns the scattering coefficient for junction between
*			the velum and the first nasal section.  Since the
*                       nasal section is normally fixed, its value squared is
*                       precalculated in optimizeConversion().
*
*       arguments:      radius - the radius of the velum section (in cm.).
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

float n0Coefficient(float radius)
{
    float r1_2;


    /*  RETURN IMMEDIATELY IF BOTH RADII ARE ZERO (AVOID ZERO DIVIDE)  */
    if ((radius == 0.0) && (n1_2 == 0.0))
	return(0.0);

    /*  CALCULATE SQUARED VALUE  */
    r1_2 = radius * radius;

    /*  RETURN THE SCATTERING COEFFICIENT  */
    return(((r1_2 - n1_2) / (r1_2 + n1_2)));
}



/******************************************************************************
*
*	function:	alphaCoefficients
*
*	purpose:	Sets the alpha coefficients for a 3-way scattering
*                       junction, given the radii (in cm.).
*			
*       arguments:      pharynx - pharynx section radius in cm.
*                       oral - oral section radius in cm.
*                       velum - velum section radius in cm.
*                       alpha0 - calculated alpha 0 coefficient (pharynx).
*                       alpha1 - calculated alpha 1 coefficient (oral).
*                       alpha2 - calculated alpha 2 coefficient (velum).
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void alphaCoefficients(float pharynx, float oral, float velum,
		       float *alpha0, float *alpha1, float *alpha2)
{
    float r0_2, r1_2, r2_2, sum;


    /*  CALCULATE ALPHA COEFFICIENTS FOR 3-WAY JUNCTION  */
    r0_2 = pharynx * pharynx;
    r1_2 = oral * oral;
    r2_2 = velum * velum;
    sum = 1.0 / (r0_2 + r1_2 + r2_2);
    *alpha0 = sum * r0_2;
    *alpha1 = sum * r1_2;
    *alpha2 = sum * r2_2;
}



/******************************************************************************
*
*	function:	scaledVolume
*
*	purpose:	Converts 0-60 dB to a fractional value suitable for
*                       the conversion routines now on the DSP.
*
*       arguments:      decibelLevel - input decibel level.
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

float scaledVolume(float decibelLevel)
{
    /*  MAKE SURE THE DECIBEL LEVEL IS IN RANGE  */
    if (decibelLevel < VOLUME_MIN)
	decibelLevel = VOLUME_MIN;
    else if (decibelLevel > VOLUME_MAX)
	decibelLevel = VOLUME_MAX;

    /*  RETURN THE RIGHT SHIFTED (FRACTIONAL) VALUE  */
    return(decibelLevel/AMPLITUDE_SCALE);
}



/******************************************************************************
*
*       function:       amplitude
*
*       purpose:        Converts dB value (0-60) to amplitude value (0-1).
*
*       arguments:      decibelLevel - input decibel level (0 - 60 dB).
*
*       internal
*       functions:      none
*
*       library
*       functions:      pow
*
******************************************************************************/

float amplitude(float decibelLevel)
{
    /*  CONVERT 0-60 RANGE TO -60-0 RANGE  */
    decibelLevel -= VOLUME_MAX;

    /*  IF -60 OR LESS, RETURN AMPLITUDE OF 0  */
    if (decibelLevel <= (-VOLUME_MAX))
        return(0.0);

    /*  IF 0 OR GREATER, RETURN AMPLITUDE OF 1  */
    if (decibelLevel >= 0.0)
        return(1.0);

    /*  ELSE RETURN INVERSE LOG VALUE  */
    return(pow(10.0,(decibelLevel/20.0)));
}



/******************************************************************************
*
*	function:	tableIncrement
*
*	purpose:	Converts a pitch to the appropriate oscillator
*                       table increment, using the table size, sample rate,
*			and the oversampling factor (in precalculated form to
*                       save time).
*
*       arguments:      pitch - input pitch in (fractional) semitones.
*
*	internal
*	functions:	frequency
*
*	library
*	functions:	none
*
******************************************************************************/

float tableIncrement(float pitch)
{
    return(frequency(pitch) * tableFactor);
}



/******************************************************************************
*
*	function:	frequency
*
*	purpose:	Converts a given pitch (0 = middle C) to the
*                       corresponding frequency.
*
*       arguments:      pitch - input pitch, in (fractional) semitones.
*
*	internal
*	functions:	none
*
*	library
*	functions:	pow
*
******************************************************************************/

float frequency(float pitch)
{
    return(PITCH_BASE * pow(2.0,(pitch+PITCH_OFFSET)/12.0));
}



/******************************************************************************
*
*	function:	pitch
*
*	purpose:	Converts a given frequency to (fractional) semitone;
*                       0 = middle C.
*
*       arguments:      frequency - input frequency, in Hertz.
*
*	internal
*	functions:	none
*
*	library
*	functions:	log10, pow
*
******************************************************************************/

float pitch(float frequency)
{
    return(12.0 *
	   log10(frequency/(PITCH_BASE * pow(2.0,(PITCH_OFFSET/12.0)))) *
	   LOG_FACTOR);
}



/******************************************************************************
*
*	function:	scaledFrequency
*
*	purpose:	Scales the frequency so that it is a fractional value,
*                       by dividing by the current sample rate.
*			
*       arguments:      frequency - the input frequency (0 - SR).
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

float scaledFrequency(float frequency)
{
    return(frequency / sampleRate);
}



/******************************************************************************
*
*	function:	scaledPosition
*
*	purpose:	Converts the frication insertion position (0 - 4)
*                       into a fractional form suitable for the DSP.
*			
*       arguments:      position - frication insertion position.
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

float scaledPosition(float position)
{
    return(position / POSITION_SCALE);
}



/******************************************************************************
*
*	function:	scaledCrossmixFactor
*
*	purpose:	Converts the crossmix offset (in dB) to a scaled
*                       factor suitable for the DSP.
*			
*       arguments:      mixOffset - the crossmix offset (30 - 60 dB).
*                       
*	internal
*	functions:	amplitude
*
*	library
*	functions:	none
*
******************************************************************************/

float scaledCrossmixFactor(float mixOffset)
{
    return(1.0 / (amplitude(mixOffset) * CROSSMIX_SCALE));
}



/******************************************************************************
*
*	function:	dampingFactor
*
*	purpose:	Converts the junction loss percentage into a 
*                       fractional damping factor.
*			
*       arguments:      lossFactor - input loss factor (a percentage).
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

float dampingFactor(float lossFactor)
{
    return((100.0 - lossFactor) / 100.0);
}



/******************************************************************************
*
*       function:       speedOfSound
*
*       purpose:        Returns the speed of sound according to the value of
*                       the temperature (in Celsius degrees).  The speed is
*                       expressed as meters/second.
*
*       arguments:      temperature - in Celsius degrees
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

float speedOfSound(float temperature)
{
  return (331.4 + (0.6 * temperature));
}
