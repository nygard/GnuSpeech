//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  HEADER FILES  ************************************************************/
#include "conversion.h"
#include <math.h>


/******************************************************************************
*
*       function:       frequency
*
*       purpose:        Converts a given pitch (0 = middle C) to the
*                       corresponding frequency.
*
*       internal
*       functions:      none
*
*       library
*       functions:      pow
*
******************************************************************************/
/*
double frequency(double pitch)
{
    return(PITCH_BASE * pow(2.0,(((double)(pitch+PITCH_OFFSET))/12.0)));
}
*/

/******************************************************************************
*
*       function:       Pitch
*
*       purpose:        Converts a given frequency to (fractional) semitone;
*                       0 = middle C.
*
*       internal
*       functions:      none
*
*       library
*       functions:      log10, pow
*
******************************************************************************/

double Pitch(double frequency)
{
    return(12.0 *
           log10(frequency/(PITCH_BASE * pow(2.0,(PITCH_OFFSET/12.0)))) *
           LOG_FACTOR);
}



/******************************************************************************
*
*       function:       normalizedPitch
*
*       purpose:        Combines semitones (0 = Middle C) and cents (-100 to
*                       +100) into a single value.
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

float normalizedPitch(int semitones, int cents)
{
    return((float)semitones + (float)cents/100.0);
}



/******************************************************************************
*
*       function:       scaled_volume
*
*       purpose:        Converts 0-60 dB to a fractional value suitable for
*                       the conversion routines now on the DSP.
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

float scaledVolume(float decibel_level)
{
  /*  MAKE SURE THE DECIBEL_LEVEL IS IN RANGE  */
  if (decibel_level < 0.0)
    decibel_level = 0.0;
  else if (decibel_level > (float)VOLUME_MAX)
    decibel_level = (float)VOLUME_MAX;

  /*  RETURN THE RIGHT SHIFTED (FRACTIONAL) VALUE  */
  return(decibel_level/AMPLITUDE_SCALE);
}



/******************************************************************************
*
*       function:       amplitude2
*
*       purpose:        Converts dB value to amplitude value.
*
*       internal
*       functions:      none
*
*       library
*       functions:      pow
*
******************************************************************************/

double amplitude2(double decibelLevel)
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
