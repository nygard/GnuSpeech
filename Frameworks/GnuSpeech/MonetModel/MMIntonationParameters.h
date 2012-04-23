//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMObject.h"

@interface MMIntonationParameters : MMObject

@property (assign) float notionalPitch;
@property (assign) float pretonicRange;
@property (assign) float pretonicLift;
@property (assign) float tonicRange;
@property (assign) float tonicMovement;

@end
