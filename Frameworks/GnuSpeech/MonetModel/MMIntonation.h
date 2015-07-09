//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMObject.h"

@class MMIntonationParameters, MMToneGroup;

@interface MMIntonation : MMObject

@property (assign) BOOL shouldUseMacroIntonation;
@property (assign) BOOL shouldUseMicroIntonation;
@property (assign) BOOL shouldUseSmoothIntonation;

@property (assign) BOOL shouldUseDrift;
@property (assign) float driftDeviation; // Standard devications
@property (assign) float driftCutoff; // Hz

@property (assign) double tempo;

/// Affects hard coded parameters 7 and 8 (r1 and r2).
@property (assign) double radiusMultiply;

/// If YES, randomly select one of the sets of intonation parameters for a tone group, and adds random semitone/slope to the intonation.
/// If NO, then choose the first set of intonation parameters, which are supposed to be "neutral".
@property (assign) BOOL shouldRandomizeIntonation;

- (MMIntonationParameters *)intonationParametersForToneGroup:(MMToneGroup *)toneGroup;

@end
