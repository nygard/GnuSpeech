//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMObject.h"

@interface MMIntonation : MMObject

@property (assign) float notionalPitch;
@property (assign) float pretonicRange;
@property (assign) float pretonicLift;
@property (assign) float tonicRange;
@property (assign) float tonicMovement; // TODO (2004-03-30): Apparently not used.

@property (assign) BOOL shouldUseMacroIntonation;
@property (assign) BOOL shouldUseMicroIntonation;
@property (assign) BOOL shouldUseSmoothSmoothIntonation;

@property (assign) BOOL shouldUseDrift;
@property (assign) float driftDeviation; // Standard devications
@property (assign) float driftCutoff; // Hz

@property (assign) double tempo;

/// Affects hard coded parameters 7 and 8 (r1 and r2).
@property (assign) double radiusMultiply;

@end
