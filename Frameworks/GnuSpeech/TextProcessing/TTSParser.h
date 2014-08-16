//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

@class GSPronunciationDictionary;

@interface TTSParser : NSObject

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)dictionary;

- (NSString *)parseString:(NSString *)string;  // entry point

@end
