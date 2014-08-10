//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

typedef enum : NSUInteger{
    TTSInputModeUnknown  = 0,
    TTSInputModeNormal   = 1,
    TTSInputModeRaw      = 2,
    TTSInputModeLetter   = 3,
    TTSInputModeEmphasis = 4,
    TTSInputModeTagging  = 5,
    TTSInputModeSilence  = 6,
} TTSInputMode;

@class GSPronunciationDictionary;

@interface TTSParserOld : NSObject

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)dictionary;

- (NSString *)parseString:(NSString *)string;
- (void)markModes:(NSString *)string;
- (void)stripPunctuationFromString:(NSString *)string;

- (NSString *)padCharactersInSet:(NSCharacterSet *)characterSet ofString:(NSString *)string;

- (void)finalConversion:(NSString *)string resultString:(NSMutableString *)resultString;
- (NSUInteger)stateForWord:(NSString *)word;
- (void)expandWord:(NSString *)word tonic:(BOOL)isTonic resultString:(NSMutableString *)resultString;
- (NSString *)degenerateString:(NSString *)word;
- (BOOL)shiftSilence;
- (NSString *)toneGroupStringForPunctuation:(NSString *)str;

@end
