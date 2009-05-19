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
 *  util.h
 *  Tube
 *
 *  Version: 1.0.1
 *
 ******************************************************************************/

#ifndef __UTIL_H
#define __UTIL_H

#define BETA                      5.658        /*  kaiser window parameters  */
#define IzeroEPSILON              1E-21

double speedOfSound(double temperature);
double amplitude(double decibelLevel);
double frequency(double pitch);
double Izero(double x);
double noise(void);
double noiseFilter(double input);

#endif
