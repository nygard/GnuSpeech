//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "GSPronunciationDictionary.h"

@interface GSSimplePronunciationDictionary : GSPronunciationDictionary
{
    NSMutableDictionary *pronunciations;
}

+ (GSPronunciationDictionary *)mainDictionary;

- (id)init;
- (void)dealloc;

- (BOOL)loadFromFile:(NSString *)filename;

- (NSString *)lookupPronunciationForWord:(NSString *)aWord;


@end
