//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface GSPronunciationDictionary : NSObject
{
    NSString *version;
    NSMutableArray *suffixOrder;
    NSMutableDictionary *suffixes;
}

- (id)init;
- (void)dealloc;

- (NSString *)version;
- (void)setVersion:(NSString *)newVersion;

- (BOOL)loadFromFile:(NSString *)filename;
- (void)_readSuffixesFromFile:(NSString *)filename;

- (NSString *)lookupPronunciationForWord:(NSString *)aWord;
- (NSString *)pronunciationForWord:(NSString *)aWord;

- (void)testString:(NSString *)str;

- (NSString *)description;

@end
