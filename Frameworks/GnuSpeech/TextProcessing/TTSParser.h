//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

@class GSPronunciationDictionary;

@interface TTSParser : NSObject

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)aDictionary;

- (NSString *)parseString:(NSString *)aString;  // entry point

@end
