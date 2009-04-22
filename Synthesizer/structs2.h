/*******************************************************************************
 *
 *  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *
 *  Contributors: David Hill
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
 *  structs2.h
 *  Synthesizer
 *
 *  Created by David Hill on 9/2/2008.
 *
 *  Version: 0.7.3
 *
 ******************************************************************************/


/*
 * Needed to split off "current" and "originalDefaults" declarations
 */

#include <sys/param.h>

static struct _postureRateParameters
{
    double glotPitch;
    double glotPitchDelta;
    double glotVol;
    double glotVolDelta;
    double aspVol;
    double aspVolDelta;
    double fricVol;
    double fricVolDelta;
    double fricPos;
    double fricPosDelta;
    double fricCF;
    double fricCFDelta;
    double fricBW;
    double fricBWDelta;
    double radius[TOTAL_REGIONS];
    double radiusDelta[TOTAL_REGIONS];
    double velum;
    double velumDelta;
} current;

static struct _postureRateParameters originalDefaults;
