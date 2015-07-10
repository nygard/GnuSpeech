//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface MMRuleValues : NSObject

@property (assign) NSUInteger number;
@property (assign) NSUInteger firstPhone;
@property (assign) NSUInteger lastPhone;
@property (assign) double duration;
@property (assign) double beat; // absolute time of beat, in milliseconds

@end
