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
 *  conversion.h
 *  Synthesizer
 *
 *  Created by Adam Fedor on 1/18/2003.
 *
 *  Version: 0.7.4
 *
 ******************************************************************************/


/*  REVISION INFORMATION  *****************************************************

$Author: rao $
$Date: 2002/03/21 16:49:54 $
$Revision: 1.1 $
$Source: /cvsroot/gnuspeech/gnuspeech/trillium/src/Synthesizer/conversion.h,v $
$State: Exp $


$Log: conversion.h,v $
Revision 1.1  2002/03/21 16:49:54  rao
Initial import.

 * Revision 1.1.1.1  1994/05/20  00:22:02  len
 * Initial archive of TRM interactive Synthesizer.
 *

******************************************************************************/

/*  GLOBAL FUNCTIONS *********************************************************/
extern double frequency(double pitch);
extern double Pitch(double frequency);
extern float normalizedPitch(int semitones, int cents);
extern float scaledVolume(float decibel_level);
extern double amplitude2(double decibelLevel);

/*  GLOBAL DEFINES  **********************************************************/
#define VOLUME_MIN        0
#define VOLUME_MAX        60
#define VOLUME_DEF        60

#define PITCH_BASE        220.0
#define PITCH_OFFSET      3           /*  MIDDLE C = 0  */
#define LOG_FACTOR        3.32193

#define AMPLITUDE_SCALE       64.0        /*  DIVISOR FOR AMPLITUDE SCALING  */
#define CROSSMIX_FACTOR_SCALE 32.0  /*  DIVISOR FOR CROSSMIX_FACTOR SCALING  */
#define POSITION_SCALE        8.0    /*  DIVISOR FOR FRIC. POSITION SCALING  */

