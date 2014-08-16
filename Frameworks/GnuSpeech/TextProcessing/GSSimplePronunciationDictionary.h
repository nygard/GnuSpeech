//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"

@interface GSSimplePronunciationDictionary : GSPronunciationDictionary

+ (id)mainDictionary;
+ (id)specialAcronymDictionary;

- (NSDictionary *)pronunciations;

@end
