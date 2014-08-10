//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"
#include <fcntl.h>
#include <ndbm.h>

@class GSSimplePronunciationDictionary;

@interface GSDBMPronunciationDictionary : GSPronunciationDictionary

+ (NSString *)mainFilename;
+ (BOOL)createDatabase:(NSString *)filename fromSimpleDictionary:(GSSimplePronunciationDictionary *)simpleDictionary;

@end
