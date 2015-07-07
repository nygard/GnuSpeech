//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonationParameters.h"

@implementation MMIntonationParameters

- (id)init;
{
    if ((self = [super init])) {
        // These default values are chosen from the first set of Tone Group 1, Statement.  The first set is supposed to be a "neutral" choice.
        _notionalPitch              = 2;
        _pretonicPitchRange         = -2;
        _pretonicPerturbationRange  = 4;
        _tonicPitchRange            = -8;
        _tonicPerturbationRange     = 4;
    }

    return self;
}

@end
