#ifndef __WAVETABLE_H
#define __WAVETABLE_H

#include "fir.h"

// Waveform types
typedef enum {
    TRMWaveformTypePulse = 0,
    TRMWaveformTypeSine = 1,
} TRMWaveformType;

typedef struct _TRMWavetable {
    double *wavetable;

    double basicIncrement;
    double currentPosition;
    TRMFIRFilter *FIRFilter; // This is only used for the oversampling oscillator.

    TRMWaveformType waveform;

    // These are only used for the TRMWaveformTypePulse waveform:
    double riseTime;
    double minimumFallTime;
    double maximumFallTime;

    int tableDiv1;
    int tableDivMax;
    double tnLength; // TODO (2004-08-30): Looks like we don't need to keep this around.
    double tnDelta;
    double *squares; // squares of integers: 0^2, 1^2, 2^2, ...  Same size as wavetable.
    double *ones;    // array of 1.0, same size as wavetable.
} TRMWavetable;

TRMWavetable *TRMWavetableCreate(int waveform, double tp, double tnMin, double tnMax, double sampleRate);
void TRMWavetableFree(TRMWavetable *wavetable);

unsigned int TRMWavetableLength(TRMWavetable *wavetable);
void TRMWavetableSetWaveform(TRMWavetable *wavetable, TRMWaveformType newWaveform);
void TRMWavetableSetRiseTime(TRMWavetable *wavetable, double newRiseTime);
void TRMWavetableSetMinimumFallTime(TRMWavetable *wavetable, double newMinimumFallTime);
void TRMWavetableSetMaximumFallTime(TRMWavetable *wavetable, double newMaximumFallTime);

void TRMWavetableCalculate(TRMWavetable *wavetable);

void TRMWavetableUpdate(TRMWavetable *wavetable, double amplitude);
double TRMWavetableOscillator(TRMWavetable *wavetable, double frequency);

#endif
