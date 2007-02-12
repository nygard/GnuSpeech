//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "GSPronunciationDictionary.h"
#include <fcntl.h>
#include <ndbm.h>

@class GSSimplePronunciationDictionary;

@interface GSDBMPronunciationDictionary : GSPronunciationDictionary
{
    DBM *db;
}

+ (NSString *)mainFilename;
+ (BOOL)createDatabase:(NSString *)aFilename fromSimpleDictionary:(GSSimplePronunciationDictionary *)simpleDictionary;

- (id)initWithFilename:(NSString *)aFilename;
- (void)dealloc;

- (NSDate *)modificationDate;
- (BOOL)loadDictionary;

- (NSString *)lookupPronunciationForWord:(NSString *)aWord;

@end
