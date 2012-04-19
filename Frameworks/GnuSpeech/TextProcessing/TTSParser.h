//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

@class GSPronunciationDictionary;

@interface TTSParser : NSObject
{
    GSPronunciationDictionary * mainDictionary;
	GSPronunciationDictionary * userDictionary;
	GSPronunciationDictionary * appDictionary;
}

+ (void)initialize;

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)aDictionary;
- (void)dealloc;

- (NSString *)parseString:(NSString *)aString;  // entry point

@end
