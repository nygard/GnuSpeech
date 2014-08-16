//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface GSPronunciationDictionary : NSObject

- (id)initWithFilename:(NSString *)filename;

@property (readonly) NSString *filename;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, readonly) NSDate *modificationDate;

- (void)loadDictionaryIfNecessary;

/// Look up the pronunciation in the dictionary.  If nothing is found, check against the suffix replacements and return the modified word + extra pronunciation.
- (NSString *)pronunciationForWord:(NSString *)word;

- (void)testString:(NSString *)str;

@end
