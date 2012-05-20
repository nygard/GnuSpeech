//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "structs.h" // For TRMSampleRateConverter

// Function return constants
#define ERROR                     (-1)
#define SUCCESS                   0

// Waveform types
#define PULSE                     0
#define SINE                      1

// Math constants
#define PI                        3.14159265358979
#define TWO_PI                    (2.0 * PI)

@class TRMInputParameters, TRMDataList;

@interface TRMTubeModel : NSObject

- (id)initWithInputParameters:(TRMInputParameters *)inputParameters; // Might not even need inputParameters

- (void)synthesizeFromDataList:(TRMDataList *)data;

@property (nonatomic, readonly) TRMSampleRateConverter *sampleRateConverter;

@end
