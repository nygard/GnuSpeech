//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

// Oropharynx Regions
#define TRM_R1          0      //  S1
#define TRM_R2          1      //  S2
#define TRM_R3          2      //  S3
#define TRM_R4          3      //  S4 & S5
#define TRM_R5          4      //  S6 & S7
#define TRM_R6          5      //  S8
#define TRM_R7          6      //  S9
#define TRM_R8          7      //  S10
#define TOTAL_REGIONS   8

// Nasal Tract Sections
#define TRM_N1                    0
#define TRM_VELUM                 TRM_N1
#define TRM_N2                    1
#define TRM_N3                    2
#define TRM_N4                    3
#define TRM_N5                    4
#define TRM_N6                    5
#define TOTAL_NASAL_SECTIONS      6

@class TRMInputParameters, TRMDataList, TRMSampleRateConverter;

@interface TRMTubeModel : NSObject

- (id)initWithInputParameters:(TRMInputParameters *)inputParameters; // Might not even need inputParameters

- (void)synthesizeFromDataList:(TRMDataList *)data;

@property (readonly) TRMSampleRateConverter *sampleRateConverter;

@end
