//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface TRMSampleRateConverter : NSObject

- (id)initWithInputRate:(double)inputRate outputRate:(double)outputRate;

- (void)dataFill:(double)data;
- (void)flush;

@property (assign) double maximumSampleValue;
@property (assign) int32_t numberSamples;
@property (assign) FILE *tempFilePtr;

@end
