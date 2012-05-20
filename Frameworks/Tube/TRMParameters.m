//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMParameters.h"

@implementation TRMParameters
{
    double glotPitch;
    double glotVol;
    double aspVol;
    double fricVol;
    double fricPos;
    double fricCF;
    double fricBW;
    double radius[TOTAL_REGIONS];
    double velum;
}

@synthesize glotPitch, glotVol, aspVol, fricVol, fricPos, fricCF, fricBW, velum;

- (double *)radius;
{
    return radius;
}

@end
