//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

typedef enum {
    TTSInputModeUnknown = 0,
    TTSInputModeNormal = 1,
    TTSInputModeRaw = 2,
    TTSInputModeLetter = 3,
    TTSInputModeEmphasis = 4,
    TTSInputModeTagging = 5,
    TTSInputModeSilence = 6,
} TTSInputMode;

@class GSPronunciationDictionary;

@interface TTSParserOld : NSObject
{
    GSPronunciationDictionary *mainDictionary;
    unichar escapeCharacter;
}

+ (void)initialize;

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)aDictionary;
- (void)dealloc;

- (NSString *)parseString:(NSString *)aString;
- (void)markModes:(NSString *)aString;
- (void)stripPunctuationFromString:(NSString *)aString;

- (NSString *)padCharactersInSet:(NSCharacterSet *)characterSet ofString:(NSString *)aString;

- (void)finalConversion:(NSString *)aString resultString:(NSMutableString *)resultString;
- (NSUInteger)stateForWord:(NSString *)word;
- (void)expandWord:(NSString *)word tonic:(BOOL)isTonic resultString:(NSMutableString *)resultString;
- (NSString *)degenerateString:(NSString *)word;
- (BOOL)shiftSilence;
- (NSString *)toneGroupStringForPunctuation:(NSString *)str;

@end
