//
// $Id: TTSParser.h,v 1.7 2004/04/30 19:00:06 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h> // for unichar

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

@interface TTSParser : NSObject
{
    unichar escapeCharacter;
    GSPronunciationDictionary *mainDictionary;
}

+ (void)initialize;

- (id)init;
- (void)dealloc;

- (NSString *)parseString:(NSString *)aString;
- (void)markModes:(NSString *)aString;
- (void)stripPunctuationFromString:(NSString *)aString;


- (void)finalConversion:(NSString *)aString resultString:(NSMutableString *)resultString;
- (int)stateForWord:(NSString *)word;
- (void)expandWord:(NSString *)word tonic:(BOOL)isTonic resultString:(NSMutableString *)resultString;
- (NSString *)degenerateString:(NSString *)word;
- (BOOL)shiftSilence;
- (NSString *)toneGroupStringForPunctuation:(NSString *)str;

@end
