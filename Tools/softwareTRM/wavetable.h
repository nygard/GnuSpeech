#ifndef __WAVETABLE_H
#define __WAVETABLE_H

#include "structs.h"

//  Compile with oversampling or plain oscillator
#define OVERSAMPLING_OSCILLATOR   1

void initializeWavetable(struct _TRMInputParameters *inputParameters);
void updateWavetable(double amplitude);
double oscillator(double frequency);

#endif
