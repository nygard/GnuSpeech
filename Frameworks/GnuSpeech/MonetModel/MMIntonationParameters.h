//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/// This represents the intonation parameters that vary by tone group.
@interface MMIntonationParameters : NSObject

@property (assign) float notionalPitch;

@property (assign) float pretonicPitchRange;

/// Pitch gets perturbed from flat line by +/- half this value.
@property (assign) float pretonicPerturbationRange;

@property (assign) float tonicPitchRange;

/// Pitch gets perturbed from flag line by +/- half this value.
@property (assign) float tonicPerturbationRange;

@end
