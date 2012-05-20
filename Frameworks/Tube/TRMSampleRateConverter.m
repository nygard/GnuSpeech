//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMSampleRateConverter.h"

#import "structs.h"

@implementation TRMSampleRateConverter
{
    double sampleRateRatio;
    double h[FILTER_LENGTH];
    double deltaH[FILTER_LENGTH];
    uint32_t timeRegisterIncrement;
    uint32_t filterIncrement;
    uint32_t phaseIncrement;
    uint32_t timeRegister;
    
    // Temporary sample storage values
    double maximumSampleValue;
    int32_t numberSamples;
    FILE *tempFilePtr;
}

@synthesize sampleRateRatio, timeRegisterIncrement, filterIncrement, phaseIncrement, timeRegister;

@synthesize maximumSampleValue, numberSamples, tempFilePtr;

- (double *)h;
{
    return h;
}

- (double *)deltaH;
{
    return deltaH;
}

@end
