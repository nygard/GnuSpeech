//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface TRMSampleRateConverter : NSObject

@property (assign) double sampleRateRatio;
@property (nonatomic, readonly) double *h;
@property (nonatomic, readonly) double *deltaH;
@property (assign) uint32_t timeRegisterIncrement;
@property (assign) uint32_t filterIncrement;
@property (assign) uint32_t phaseIncrement;
@property (assign) uint32_t timeRegister;

@property (assign) double maximumSampleValue;
@property (assign) int32_t numberSamples;
@property (assign) FILE *tempFilePtr;

@end
