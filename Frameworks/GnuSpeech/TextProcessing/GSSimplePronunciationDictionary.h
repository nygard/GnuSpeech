//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"

@interface GSSimplePronunciationDictionary : GSPronunciationDictionary

+ (id)mainDictionary;

- (id)initWithFilename:(NSString *)filename;

- (NSDate *)modificationDate;
- (BOOL)loadDictionary;

- (NSDictionary *)pronunciations;
- (NSString *)lookupPronunciationForWord:(NSString *)word;

@end
