//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

@class GSPronunciationDictionary;

@interface TTSParser : NSObject

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)dictionary;

- (NSString *)parseString:(NSString *)string;  // entry point

@end
