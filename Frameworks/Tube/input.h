//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __INPUT_H
#define __INPUT_H

#include "structs.h" // For TRMParameters

extern TRMDataList *parseInputFile(const char *inputFile);
extern void addInput(TRMDataList *data, double glotPitch, double glotVol, double aspVol, double fricVol,
                     double fricPos, double fricCF, double fricBW, double *radius,
                     double velum);

extern double glotPitchAt(INPUT *ptr);
extern double glotVolAt(INPUT *ptr);
extern double *radiiAt(INPUT *ptr);
extern double radiusAtRegion(INPUT *ptr, int32_t region);
extern double velumAt(INPUT *ptr);
extern double aspVolAt(INPUT *ptr);
extern double fricVolAt(INPUT *ptr);
extern double fricPosAt(INPUT *ptr);
extern double fricCFAt(INPUT *ptr);
extern double fricBWAt(INPUT *ptr);

extern void printControlRateInputTable(TRMDataList *data);

#endif
