//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface MMFoot : NSObject

@property (assign) double tempo;
@property (assign) NSUInteger startPhoneIndex; // index into phones
@property (assign) NSUInteger endPhoneIndex;   // index into phones
@property (assign) BOOL isMarked;              // isTonic
@property (assign) BOOL isLast;                // Is this the last foot of (the tone group?)

@end
