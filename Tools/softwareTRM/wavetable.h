#ifndef __WAVETABLE_H
#define __WAVETABLE_H

//  Compile with oversampling or plain oscillator
#define OVERSAMPLING_OSCILLATOR   1

void initializeWavetable(int waveform, double tp, double tnMin, double tnMax);
void updateWavetable(double amplitude);
double oscillator(double frequency);

#endif
