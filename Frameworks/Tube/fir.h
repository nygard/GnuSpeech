//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __FIR_H
#define __FIR_H

#include <stdint.h> // For int32_t

// Oversampling FIR filter characteristics
#define FIR_BETA                  .2
#define FIR_GAMMA                 .1
#define FIR_CUTOFF                .00000001

// Variables for FIR lowpass filter
typedef struct {
    double *FIRData;
    double *FIRCoef;
    int32_t FIRPtr;
    int32_t numberTaps;
} TRMFIRFilter;

TRMFIRFilter *TRMFIRFilterCreate(double beta, double gamma, double cutoff);
void TRMFIRFilterFree(TRMFIRFilter *filter);

double FIRFilter(TRMFIRFilter *filter, double input, int32_t needOutput);

#endif
