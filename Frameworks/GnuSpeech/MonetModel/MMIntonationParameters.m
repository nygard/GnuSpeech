//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonationParameters.h"

@implementation MMIntonationParameters
{
    float _notionalPitch;
    float _pretonicRange;
    float _pretonicLift;
    float _tonicRange;
    float _tonicMovement; // TODO (2004-03-30): Apparently not used.
}

- (id)init;
{
    if ((self = [super init])) {
        _notionalPitch = -1;
        _pretonicRange = 2;
        _pretonicLift  = -2;
        _tonicRange    = -10;
        _tonicMovement = -6;
    }
    
    return self;
}

@end
