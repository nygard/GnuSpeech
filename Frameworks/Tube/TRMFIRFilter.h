//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#include <stdint.h> // For int32_t

// Oversampling FIR filter characteristics
#define FIR_BETA                  .2
#define FIR_GAMMA                 .1
#define FIR_CUTOFF                .00000001

// FIR lowpass filter
@interface TRMFIRFilter : NSObject

- (id)initWithBeta:(double)beta gamma:(double)gamma cutoff:(double)cutoff;

- (double)filterInput:(double)input needOutput:(int32_t)needOutput;

@end
