//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"

@interface GSSimplePronunciationDictionary : GSPronunciationDictionary
{
    NSMutableDictionary *pronunciations;
}

+ (id)mainDictionary;

- (id)initWithFilename:(NSString *)aFilename;
- (void)dealloc;

- (NSDate *)modificationDate;
- (BOOL)loadDictionary;

- (NSDictionary *)pronunciations;
- (NSString *)lookupPronunciationForWord:(NSString *)aWord;

@end
