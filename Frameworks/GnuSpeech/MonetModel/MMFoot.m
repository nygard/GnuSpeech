//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFoot.h"

@implementation MMFoot

- (id)init;
{
    if ((self = [super init])) {
        _tempo           = 1.0;
        _startPhoneIndex = 0;
        _endPhoneIndex   = 0;
        _isMarked        = NO;
        _isLast          = NO;
    }

    return self;
}

@end
