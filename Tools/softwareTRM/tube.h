#ifndef __TUBE_H
#define __TUBE_H

#include <stdio.h> // For FILE
#include "input.h" // for INPUT

/*  FUNCTION RETURN CONSTANTS  */
#define ERROR                     (-1)
#define SUCCESS                   0

/*  WAVEFORM TYPES  */
#define PULSE                     0
#define SINE                      1

/*  MATH CONSTANTS  */
#define PI                        3.14159265358979
#define TWO_PI                    (2.0 * PI)

extern double maximumSampleValue;

extern int controlPeriod;
extern int sampleRate;
extern double actualTubeLength;

extern FILE  *tempFilePtr;
extern long int numberSamples;


int initializeSynthesizer(struct _TRMData *data);
void synthesize(TRMData *data);
void flushBuffer(void);

#endif
