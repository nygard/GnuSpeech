#ifndef __WAVETABLE_H
#define __WAVETABLE_H

#include "fir.h"

typedef struct _TRMWavetable {
    double *wavetable;

    double basicIncrement;
    double currentPosition;
    TRMFIRFilter *FIRFilter; // This is only used for the oversampling oscillator.

    int waveform;

    // These are only used for the PULSE waveform:
    int tableDiv1;
    int tableDiv2;
    double tnLength;
    double tnDelta;
    double *squares; // squares of integers: 0^2, 1^2, 2^2, ...  Same size as wavetable.
    double *ones;    // array of 1.0, same size as wavetable.
} TRMWavetable;

TRMWavetable *TRMWavetableCreate(int waveform, double tp, double tnMin, double tnMax, double sampleRate);
void TRMWavetableFree(TRMWavetable *wavetable);

void TRMWavetableUpdate(TRMWavetable *wavetable, double amplitude);
double TRMWavetableOscillator(TRMWavetable *wavetable, double frequency);

#endif
