//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMInputParameters.h"

@implementation TRMInputParameters
{
    int32_t outputFileFormat;
    float outputRate;
    float controlRate;
    
    double volume;
    int32_t channels;
    double balance;
    
    int32_t waveform;
    double tp;
    double tnMin;
    double tnMax;
    double breathiness;
    
    double length;
    double temperature;
    double lossFactor;
    
    double apScale;
    double mouthCoef;
    double noseCoef;
    
    double noseRadius[TOTAL_NASAL_SECTIONS];
    
    double throatCutoff;
    double throatVol;
    
    int32_t modulation;
    double mixOffset;
}

@synthesize outputFileFormat, outputRate, controlRate;

@synthesize volume, channels, balance;

@synthesize waveform, tp, tnMin, tnMax, breathiness;

@synthesize length, temperature, lossFactor;

@synthesize apScale, mouthCoef, noseCoef;

- (double *)noseRadius;
{
    return noseRadius;
}

@synthesize throatCutoff, throatVol;

@synthesize modulation, mixOffset;

@end
