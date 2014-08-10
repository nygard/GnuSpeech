//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"

@interface GSSimplePronunciationDictionary : GSPronunciationDictionary

+ (id)mainDictionary;

- (NSDictionary *)pronunciations;

@end
