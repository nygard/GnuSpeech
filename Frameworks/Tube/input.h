//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __INPUT_H
#define __INPUT_H

#include "structs.h" // For TRMParameters
#import "TRMDataList.h"

TRMDataList *parseInputFile(const char *inputFile);

void printControlRateInputTable(TRMDataList *data);

#endif
