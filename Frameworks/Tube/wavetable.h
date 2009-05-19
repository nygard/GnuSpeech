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
 *  wavetable.h
 *  Tube
 *
 *  Version: 1.0.1
 *
 ******************************************************************************/

#ifndef __WAVETABLE_H
#define __WAVETABLE_H

#include "fir.h"

//  Compile with oversampling or plain oscillator
#define OVERSAMPLING_OSCILLATOR   1

typedef struct _TRMWavetable {
    TRMFIRFilter *FIRFilter;
    double *wavetable;

    int tableDiv1;
    int tableDiv2;
    double tnLength;
    double tnDelta;

    double basicIncrement;
    double currentPosition;
} TRMWavetable;

TRMWavetable *TRMWavetableCreate(int waveform, double tp, double tnMin, double tnMax, double sampleRate);
void TRMWavetableFree(TRMWavetable *wavetable);

void TRMWavetableUpdate(TRMWavetable *wavetable, double amplitude);
double TRMWavetableOscillator(TRMWavetable *wavetable, double frequency);

#endif
