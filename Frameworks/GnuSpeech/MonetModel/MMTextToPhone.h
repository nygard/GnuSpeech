//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class GSPronunciationDictionary;

@interface MMTextToPhone : NSObject

/// Convenience initializer, to use the DBM based pronunciation dictionary.
- (id)init;

/// Designated intializer.
- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)pronunciationDictionary;

/// This method translates the text into a string of phones.
- (NSString *)phoneStringFromText:(NSString *)text;

@end
