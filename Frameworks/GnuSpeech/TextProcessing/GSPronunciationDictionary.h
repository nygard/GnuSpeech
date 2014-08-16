//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface GSPronunciationDictionary : NSObject

- (id)initWithFilename:(NSString *)filename;

@property (readonly) NSString *filename;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, readonly) NSDate *modificationDate;

- (void)loadDictionaryIfNecessary;
- (BOOL)loadDictionary;

- (NSString *)lookupPronunciationForWord:(NSString *)word;
- (NSString *)pronunciationForWord:(NSString *)word;

- (void)testString:(NSString *)str;

@end
