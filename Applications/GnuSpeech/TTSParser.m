//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "TTSParser.h"

#import <Foundation/Foundation.h>
#import "NSScanner-Extensions.h"
#import "NSString-Extensions.h"

TTSInputMode TTSInputModeFromString(NSString *str)
{
    if ([str isEqualToString:@"r"] || [str isEqualToString:@"R"]) {
        return TTSInputModeRaw;
    } else if ([str isEqualToString:@"l"] || [str isEqualToString:@"L"]) {
        return TTSInputModeLetter;
    } else if ([str isEqualToString:@"e"] || [str isEqualToString:@"E"]) {
        return TTSInputModeEmphasis;
    } else if ([str isEqualToString:@"t"] || [str isEqualToString:@"T"]) {
        return TTSInputModeTagging;
    } else if ([str isEqualToString:@"s"] || [str isEqualToString:@"S"]) {
        return TTSInputModeSilence;
    }

    return TTSInputModeUnknown;
}

@implementation TTSParser

- (id)init;
{
    if ([super init] == nil)
        return nil;

    escapeCharacter = '%';

    return self;
}

- (void)parseString:(NSString *)aString;
{
    NSLog(@" > %s", _cmd);

    NSLog(@"aString: %@", aString);
    //[self markModes:aString];

    NSLog(@"<  %s", _cmd);
}

// TODO (2004-04-28): This wants to embed special characters (-1 through -11) in the output string...  We may need to do this differently, since we want to deal with characters, not bytes.
- (void)markModes:(NSString *)aString;
{
    NSMutableArray *modeStack;
    NSScanner *scanner;
    NSCharacterSet *escapeCharacterSet;
    NSMutableString *resultString;
    NSString *str;
    TTSInputMode currentMode;

    escapeCharacterSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithUnichar:escapeCharacter]];
    resultString = [NSMutableString string];

    modeStack = [[NSMutableArray alloc] init];
    currentMode = TTSInputModeNormal;
    [modeStack addObject:[NSNumber numberWithInt:currentMode]];

    scanner = [[NSScanner alloc] initWithString:aString];
    while ([scanner isAtEnd] == NO) {
        if ([scanner scanUpToCharactersFromSet:escapeCharacterSet intoString:&str] == YES)
            [resultString appendString:str];

        if ([scanner scanCharacterFromSet:escapeCharacterSet intoString:NULL] == YES) {
            if (currentMode == TTSInputModeRaw) {
                NSLog(@"Raw mode, do something...");
            } else {
                if ([scanner scanCharacterFromSet:escapeCharacterSet intoString:NULL] == YES) {
                    [resultString appendString:[NSString stringWithUnichar:escapeCharacter]];
                } else {
                    NSString *modeString;

                    if ([scanner scanCharacterIntoString:&modeString] == YES) {
                        TTSInputMode aMode;

                        NSLog(@"scanned mode: '%@'", modeString);
                        aMode = TTSInputModeFromString(modeString);
                        if (aMode == TTSInputModeUnknown) {
                            NSLog(@"Unknown mode, skipping...");
                        } else {
                            if ([scanner scanCharacterFromString:@"bB" intoString:NULL] == YES) {
                                NSLog(@"begin mode.");
                            } else if ([scanner scanCharacterFromString:@"eE" intoString:NULL] == YES) {
                                NSLog(@"end mode.");
                            } else {
                                NSLog(@"neither begin nor end mode.");
                            }
                        }
                    } else {
                        NSLog(@"End of string...");
                    }
                }
            }
        }
        break;
    }

    [scanner release];
    [modeStack release];

    NSLog(@"result string: '%@'", resultString);
}

- (void)stripPunctuationFromString:(NSString *)aString;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)expandWord:(NSString *)word tonic:(BOOL)isTonic;
{
    BOOL possessive;
    NSString *pronunciation;

    // Strip of possessive if word ends with 's
    possessive = [word hasSuffix:@"'s"];
    if (possessive == YES)
        word = [word substringToIndex:[word length] - 2];

    if ([word length] == 1 && [[NSCharacterSet letterCharacterSet] characterIsMember:[word characterAtIndex:0]] == YES) {
        if ([word isEqualToString:@"a"] == YES) {
            pronunciation = @"uh";
        } else {
            pronunciation = [self degenerateString:word];
        }
    }

}

- (NSString *)degenerateString:(NSString *)word;
{
    NSMutableString *resultString;

    resultString = [NSMutableString string];

    return resultString;
}

@end
