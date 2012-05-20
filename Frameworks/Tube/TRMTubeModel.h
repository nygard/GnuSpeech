//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "structs.h" // For TRMSampleRateConverter

@class TRMInputParameters, TRMDataList;

@interface TRMTubeModel : NSObject

- (id)initWithInputParameters:(TRMInputParameters *)inputParameters; // Might not even need inputParameters

- (void)synthesizeFromDataList:(TRMDataList *)data;

@property (nonatomic, readonly) TRMSampleRateConverter *sampleRateConverter;

@end
