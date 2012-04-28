//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __TUBE_H
#define __TUBE_H

#include <stdio.h> // For FILE
#include "input.h" // For INPUT
#include "structs.h" // For TRMSampleRateConverter

// Function return constants
#define ERROR                     (-1)
#define SUCCESS                   0

// Waveform types
#define PULSE                     0
#define SINE                      1

// Math constants
#define PI                        3.14159265358979
#define TWO_PI                    (2.0 * PI)

extern BOOL verbose;

TRMTubeModel *TRMTubeModelCreate(TRMInputParameters *inputParameters);
void TRMTubeModelFree(TRMTubeModel *model);

void synthesize(TRMTubeModel *tubeModel, TRMDataList *data);

#endif
