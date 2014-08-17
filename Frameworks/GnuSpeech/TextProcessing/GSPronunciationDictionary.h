//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationSource.h"

@interface GSPronunciationDictionary : GSPronunciationSource

- (id)initWithFilename:(NSString *)filename;

@property (readonly) NSString *filename;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, readonly) NSDate *modificationDate;

- (void)loadDictionaryIfNecessary;

- (NSString *)pronunciationForWord:(NSString *)word checkSuffixes:(BOOL)shouldCheckSuffixes;

@end
