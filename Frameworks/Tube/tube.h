/******************************************************************************
 *                                                                            * 
 *  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock          *
 *                                                                            *
 *  Contributors: Steve Nygard                                                *
 *                                                                            *
 *  This program is free software: you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by      *
 *  the Free Software Foundation, either version 3 of the License, or         *
 *  (at your option) any later version.                                       *
 *                                                                            *
 *  This program is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 *  GNU General Public License for more details.                              *
 *                                                                            *
 *  You should have received a copy of the GNU General Public License         *
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                            *
 ******************************************************************************/

#ifndef __TUBE_H
#define __TUBE_H

#include <stdio.h> // For FILE
#include "input.h" // For INPUT
#include "structs.h" // For TRMSampleRateConverter

/*  FUNCTION RETURN CONSTANTS  */
#define ERROR                     (-1)
#define SUCCESS                   0

/*  WAVEFORM TYPES  */
#define PULSE                     0
#define SINE                      1

/*  MATH CONSTANTS  */
#define PI                        3.14159265358979
#define TWO_PI                    (2.0 * PI)

//extern int controlPeriod;
//extern int sampleRate;
//extern double actualTubeLength;
extern int verbose;

TRMTubeModel *TRMTubeModelCreate(TRMInputParameters *inputParameters);
void TRMTubeModelFree(TRMTubeModel *model);

void synthesize(TRMTubeModel *tubeModel, TRMData *data);

#endif
