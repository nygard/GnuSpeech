//
// $Id: GSPronunciationDictionary.h,v 1.1 2004/04/30 03:27:44 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface GSPronunciationDictionary : NSObject
{
    NSMutableDictionary *pronunciations;
    NSMutableArray *suffixOrder;
    NSMutableDictionary *suffixes;
}

+ (GSPronunciationDictionary *)mainDictionary;

//- (id)initWithContentsOfFile:(NSString *)filename;
- (id)init;
- (void)dealloc;

- (void)readFile:(NSString *)filename;
- (void)_readSuffixesFromFile:(NSString *)filename;

- (NSString *)pronunciationForWord:(NSString *)aWord;

- (void)testString:(NSString *)str;

@end
