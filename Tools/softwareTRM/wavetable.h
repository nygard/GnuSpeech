#ifndef __WAVETABLE_H
#define __WAVETABLE_H

//  Compile with oversampling or plain oscillator
#define OVERSAMPLING_OSCILLATOR   1

typedef struct _TRMWavetable {
    double *wavetable;

    int tableDiv1;
    int tableDiv2;
    double tnLength;
    double tnDelta;

    double basicIncrement;
    double currentPosition;
} TRMWavetable;

TRMWavetable *TRMWavetableCreate(int waveform, double tp, double tnMin, double tnMax);
void TRMWavetableRelease(TRMWavetable *wavetable);

void TRMWavetableUpdate(TRMWavetable *wavetable, double amplitude);
double TRMWavetableOscillator(TRMWavetable *wavetable, double frequency);

#endif
