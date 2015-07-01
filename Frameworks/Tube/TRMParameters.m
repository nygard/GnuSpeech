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

- (NSString *)valuesString;
{
    NSMutableArray *a1 = [NSMutableArray array];
    [a1 addObject:[NSString stringWithFormat:@"%.3f", _glottalPitch]];
    [a1 addObject:[NSString stringWithFormat:@"%.3f", _glottalVolume]];
    [a1 addObject:[NSString stringWithFormat:@"%.3f", _aspirationVolume]];
    [a1 addObject:[NSString stringWithFormat:@"%.3f", _fricationVolume]];
    [a1 addObject:[NSString stringWithFormat:@"%.3f", _fricationPosition]];
    [a1 addObject:[NSString stringWithFormat:@"%.3f", _fricationCenterFrequency]];
    [a1 addObject:[NSString stringWithFormat:@"%.3f", _fricationBandwidth]];

    for (NSUInteger index = 0; index < TOTAL_REGIONS; index++)
        [a1 addObject:[NSString stringWithFormat:@"%.3f", _radius[index]]];

    [a1 addObject:[NSString stringWithFormat:@"%.3f", _velum]];

    return [a1 componentsJoinedByString:@" "];
}

@end
