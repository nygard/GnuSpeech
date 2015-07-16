//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMObject.h"

@class MMIntonationParameters, MMToneGroup;

@interface MMIntonation : MMObject

@property (assign) BOOL shouldUseMacroIntonation;
@property (assign) BOOL shouldUseMicroIntonation;
@property (assign) BOOL shouldUseSmoothIntonation;

@property (assign) BOOL shouldUseDrift;
@property (assign) float driftDeviation; // Semitones
@property (assign) float driftCutoff; // Hz

@property (assign) double tempo;

/// If YES, add random semitone/slope to the intonation.  Otherwise use a fixed slope (0.02 for pretonic, 0.04 for tonic continuation, 0.05 for other tonics).
@property (assign) BOOL shouldRandomlyPerturb;

/// If YES, randomly select one of the sets of intonation parameters for a tone group, and adds random semitone/slope to the intonation.
/// If NO, then choose the first set of intonation parameters, which are supposed to be "neutral".
@property (assign) BOOL shouldRandomlySelectFromToneGroup;

/// If YES, select the intonation parameters based on the tone group.
/// If NO, use the manual intonation parameters.
@property (assign) BOOL shouldUseToneGroupIntonationParameters;
@property (strong, readonly) MMIntonationParameters *manualIntonationParameters;

- (MMIntonationParameters *)intonationParametersForToneGroup:(MMToneGroup *)toneGroup;

@end
