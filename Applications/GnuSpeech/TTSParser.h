//
// $Id: TTSParser.h,v 1.3 2004/04/30 01:53:24 nygard Exp $
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

@interface TTSParser : NSObject
{
    unichar escapeCharacter;
}

- (id)init;

- (void)parseString:(NSString *)aString;
- (void)markModes:(NSString *)aString;
- (void)stripPunctuationFromString:(NSString *)aString;
- (void)expandWord:(NSString *)word tonic:(BOOL)isTonic;
- (NSString *)degenerateString:(NSString *)word;

@end
