//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

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

extern TRMWavetable *TRMWavetableCreate(int waveform, double tp, double tnMin, double tnMax, double sampleRate);
extern void TRMWavetableFree(TRMWavetable *wavetable);

extern void TRMWavetableUpdate(TRMWavetable *wavetable, double amplitude);
extern double TRMWavetableOscillator(TRMWavetable *wavetable, double frequency);

#endif
