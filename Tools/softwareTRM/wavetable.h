#ifndef __WAVETABLE_H
#define __WAVETABLE_H

#include "structs.h"

/*  COMPILE WITH OVERSAMPLING OR PLAIN OSCILLATOR  */
#define OVERSAMPLING_OSCILLATOR   1

/*  GLOTTAL SOURCE OSCILLATOR TABLE VARIABLES  */
#define TABLE_LENGTH              512
#define TABLE_MODULUS             (TABLE_LENGTH-1)

void initializeWavetable(struct _TRMInputParameters *inputParameters);
void updateWavetable(double amplitude);
double oscillator(double frequency);

#endif
