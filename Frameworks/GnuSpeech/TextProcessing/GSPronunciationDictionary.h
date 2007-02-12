//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/Foundation.h>

@interface GSPronunciationDictionary : NSObject
{
    NSString *filename;
    NSString *version;

    NSMutableArray *suffixOrder;
    NSMutableDictionary *suffixes;

    BOOL hasBeenLoaded;
}

+ (id)mainDictionary;

- (id)initWithFilename:(NSString *)aFilename;
- (void)dealloc;

- (NSString *)filename;

- (NSString *)version;
- (void)setVersion:(NSString *)newVersion;

- (NSDate *)modificationDate;

- (void)loadDictionaryIfNecessary;
- (BOOL)loadDictionary;

- (void)_readSuffixesFromFile:(NSString *)aFilename;

- (NSString *)lookupPronunciationForWord:(NSString *)aWord;
- (NSString *)pronunciationForWord:(NSString *)aWord;

- (void)testString:(NSString *)str;

- (NSString *)description;

@end
