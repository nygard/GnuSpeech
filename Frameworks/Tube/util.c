/*******************************************************************************
 *
 *  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *  
 *  Contributors: Steve Nygard
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
 *  util.c
 *  Tube
 *
 *  Version: 1.0.1
 *
 ******************************************************************************/

#include <math.h>
#include "util.h"

/*  RANGE OF ALL VOLUME CONTROLS  */
#define VOL_MAX                   60

/*  CONSTANTS FOR NOISE GENERATOR  */
#define FACTOR                    377.0
#define INITIAL_SEED              0.7892347

/*  PITCH VARIABLES  */
#define PITCH_BASE                220.0
#define PITCH_OFFSET              3           /*  MIDDLE C = 0  */
#define LOG_FACTOR                3.32193


/******************************************************************************
*
*	function:	speedOfSound
*
*	purpose:	Returns the speed of sound according to the value of
*                       the temperature (in Celsius degrees).
*
*       arguments:      temperature
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double speedOfSound(double temperature)
{
    return 331.4 + (0.6 * temperature);
}

/******************************************************************************
*
*       function:       amplitude
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

double amplitude(double decibelLevel)
{
    /*  CONVERT 0-60 RANGE TO -60-0 RANGE  */
    decibelLevel -= VOL_MAX;

    /*  IF -60 OR LESS, RETURN AMPLITUDE OF 0  */
    if (decibelLevel <= (-VOL_MAX))
        return 0.0;

    /*  IF 0 OR GREATER, RETURN AMPLITUDE OF 1  */
    if (decibelLevel >= 0.0)
        return 1.0;

    /*  ELSE RETURN INVERSE LOG VALUE  */
    return pow(10.0, (decibelLevel / 20.0));
}



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

double frequency(double pitch)
{
    return PITCH_BASE * pow(2.0, (((double)(pitch + PITCH_OFFSET)) / 12.0));
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

    return sum;
}



/******************************************************************************
*
*	function:	noise
*
*	purpose:	Returns one value of a random sequence.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double noise(void)
{
    static double seed = INITIAL_SEED;

    double product = seed * FACTOR;
    seed = product - (int)product;
    return (seed - 0.5);
}



/******************************************************************************
*
*	function:	noiseFilter
*
*	purpose:	One-zero lowpass filter.
*
*       arguments:      input
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double noiseFilter(double input)
{
    static double noiseX = 0.0;

    double output = input + noiseX;
    noiseX = input;
    return output;
}
