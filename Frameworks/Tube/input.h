//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __INPUT_H
#define __INPUT_H

#include "structs.h" // For TRMParameters

TRMDataList *parseInputFile(const char *inputFile);
void addInput(TRMDataList *data, double glotPitch, double glotVol, double aspVol, double fricVol,
              double fricPos, double fricCF, double fricBW, double *radius,
              double velum);

double glotPitchAt(INPUT *ptr);
double glotVolAt(INPUT *ptr);
double *radiiAt(INPUT *ptr);
double radiusAtRegion(INPUT *ptr, int region);
double velumAt(INPUT *ptr);
double aspVolAt(INPUT *ptr);
double fricVolAt(INPUT *ptr);
double fricPosAt(INPUT *ptr);
double fricCFAt(INPUT *ptr);
double fricBWAt(INPUT *ptr);

void printControlRateInputTable(TRMDataList *data);

#endif
