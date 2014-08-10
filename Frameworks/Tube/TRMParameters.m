//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMParameters.h"

#import "TRMTubeModel.h"

@implementation TRMParameters
{
    double _glottalPitch;
    double _glottalVolume;
    double _aspirationVolume;
    double _fricationVolume;
    double _fricationPosition;
    double _fricationCenterFrequency;
    double _fricationBandwidth;
    double _radius[TOTAL_REGIONS];
    double _velum;
}

- (double *)radius;
{
    return _radius;
}

@end
