//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __FIR_H
#define __FIR_H

// Oversampling FIR filter characteristics
#define FIR_BETA                  .2
#define FIR_GAMMA                 .1
#define FIR_CUTOFF                .00000001

// Variables for FIR lowpass filter
typedef struct {
    double *FIRData, *FIRCoef;
    int FIRPtr, numberTaps;
} TRMFIRFilter;

extern TRMFIRFilter *TRMFIRFilterCreate(double beta, double gamma, double cutoff);
extern void TRMFIRFilterFree(TRMFIRFilter *filter);

extern double FIRFilter(TRMFIRFilter *filter, double input, int needOutput);

#endif
