//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

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
