//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonation.h"

@interface MMIntonation ()
@property (assign) float notionalPitch;
@property (assign) float pretonicRange;
@property (assign) float pretonicLift;
@property (assign) float tonicRange;
@property (assign) float tonicMovement; // TODO (2004-03-30): Apparently not used.

@end

@implementation MMIntonation

- (id)init;
{
    if ((self = [super init])) {
        _notionalPitch = -1;
        _pretonicRange = 2;
        _pretonicLift  = -2;
        _tonicRange    = -10;
        _tonicMovement = -6;

        _shouldUseMacroIntonation = YES;
        _shouldUseMicroIntonation = YES;
        _shouldUseSmoothIntonation = YES;

        _shouldUseDrift = YES;
        _driftDeviation = 1.0;
        _driftCutoff = 4;

        _tempo = 1.0;
        _radiusMultiply = 1.0;
    }
    
    return self;
}

@end
