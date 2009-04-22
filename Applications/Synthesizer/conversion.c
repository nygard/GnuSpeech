/*******************************************************************************
 *
 *  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *
 *  Contributors: Adam Fedor, David Hill
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License     
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *******************************************************************************
 *
 *  conversion.c
 *  Synthesizer
 *
 *  Created by Adam Fedor on 1/18/2003.
 *
 *  Version: 0.7.3
 *
 ******************************************************************************/


/*  REVISION INFORMATION  *****************************************************

$Author: fedor $
$Date: 2003/01/18 05:04:50 $
$Revision: 1.2 $
$Source: /cvsroot/gnuspeech/gnuspeech/trillium/src/Synthesizer/conversion.c,v $
$State: Exp $


$Log: conversion.c,v $
Revision 1.2  2003/01/18 05:04:50  fedor
Port to OpenStep/GNUstep

Revision 1.1  2002/03/21 16:49:54  rao
Initial import.

 * Revision 1.1.1.1  1994/05/20  00:22:02  len
 * Initial archive of TRM interactive Synthesizer.
 *

******************************************************************************/

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
