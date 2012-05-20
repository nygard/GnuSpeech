//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#include "fir.h"

@interface TRMWavetable : NSObject

- (id)initWithWaveform:(int32_t)waveForm throttlePulse:(double)tp tnMin:(double)tnMin tnMax:(double)tnMax sampleRate:(double)sampleRate;

- (void)update:(double)amplitude;
- (double)oscillator:(double)frequency;

@end
