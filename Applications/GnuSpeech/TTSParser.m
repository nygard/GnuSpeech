//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "TTSParser.h"

#import <Foundation/Foundation.h>
#import "NSScanner-Extensions.h"
#import "NSString-Extensions.h"

#import "GSPronunciationDictionary.h"
#import "TTSNumberPronunciations.h"

#define TTS_CHUNK_BOUNDARY        @"/c"
#define TTS_TONE_GROUP_BOUNDARY   @"//"
#define TTS_FOOT_BEGIN            @"/_"
#define TTS_TONIC_BEGIN           @"/*"
#define TTS_SECONDARY_STRESS      @"/\""
#define TTS_LAST_WORD             @"/l"
#define TTS_TAG_BEGIN             @"/t"
#define TTS_WORD_BEGIN            @"/w"
#define TTS_UTTERANCE_BOUNDARY    @"#"
#define TTS_MEDIAL_PAUSE          @"^"
#define TTS_LONG_MEDIAL_PAUSE     @"^ ^ ^"
#define TTS_SILENCE_PHONE         @"^"

#define TG_UNDEFINED          @"/x"
#define TG_STATEMENT          @"/0"
#define TG_EXCLAMATION        @"/1"
#define TG_QUESTION           @"/2"
#define TG_CONTINUATION       @"/3"
#define TG_HALF_PERIOD        @"/4"

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

static NSDictionary *_specialAcronyms = nil;

@implementation TTSParser

+ (void)initialize;
{
    NSString *path;

    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SpecialAcronyms" ofType:@"plist"];
    NSLog(@"path: %@", path);

    _specialAcronyms = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSLog(@"_specialAcronyms: %@", [_specialAcronyms description]);
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    escapeCharacter = '%';

    mainDictionary = [[GSPronunciationDictionary mainDictionary] retain];

    return self;
}

- (void)dealloc;
{
    [mainDictionary release];

    [super dealloc];
}

- (void)parseString:(NSString *)aString;
{
    NSMutableString *resultString;

    NSLog(@" > %s", _cmd);

    NSLog(@"aString: %@", aString);
    //[self markModes:aString];

    resultString = [NSMutableString string];
    [self expandWord:aString tonic:NO resultString:resultString];

    NSLog(@"resultString: %@", resultString);

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

- (void)expandWord:(NSString *)word tonic:(BOOL)isTonic resultString:(NSMutableString *)resultString;
{
    BOOL possessive;
    NSString *pronunciation = nil;
    unsigned int last_foot_begin;

    // Strip of possessive if word ends with 's
    possessive = [word hasSuffix:@"'s"];
    if (possessive == YES)
        word = [word substringToIndex:[word length] - 2];

    if ([word length] == 1 && [word startsWithLetter] == YES) {
        if ([word isEqualToString:@"a"] == YES) {
            pronunciation = @"uh";
        } else {
            pronunciation = [self degenerateString:word];
        }
        // dictionary = TTS_LETTER_TO_SOUND;
    } else if ([word isAllUpperCase] == YES) {
        pronunciation = [_specialAcronyms objectForKey:word];
        if (pronunciation == nil)
            pronunciation = [self degenerateString:word];
        // dictionary = TTS_LETTER_TO_SOUND;
    } else {
        pronunciation = [mainDictionary pronunciationForWord:[word lowercaseString]];
        // TODO (2004-04-29): And that should set the dictionary
    }

    NSLog(@"pronunciation: %@", pronunciation);

    last_foot_begin = NSNotFound;
    if (/*isTonic && */[pronunciation containsPrimaryStress] == NO) {
        NSString *convertedStress;

        convertedStress = [pronunciation convertedStress];
        if (convertedStress != nil) {
            // For example, "saltwater"
            NSLog(@"Converted stress... from %@ to %@", pronunciation, convertedStress);
            pronunciation = convertedStress;
        } else {
            // For example, "times"
            NSLog(@"This other case...");
            last_foot_begin = [resultString length];
            [resultString appendString:TTS_FOOT_BEGIN];
        }
    }

    // And some more stuff....
}

// Returns a string which contains a character-by-character pronunciation for the string pointed at by the argument word.

- (NSString *)degenerateString:(NSString *)word;
{
    NSMutableString *resultString;
    unsigned int length, index;
    unichar ch;

    resultString = [NSMutableString string];
    length = [word length];
    for (index = 0; index < length; index++) {
        ch = [word characterAtIndex:index];
        switch (ch) {
          case ' ': [resultString appendString:PR_BLANK];                break;
          case '!': [resultString appendString:PR_EXCLAMATION_POINT];    break;
          case '"': [resultString appendString:PR_DOUBLE_QUOTE];         break;
          case '#': [resultString appendString:PR_NUMBER_SIGN];          break;
          case '$': [resultString appendString:PR_DOLLAR_SIGN];          break;
          case '%': [resultString appendString:PR_PERCENT_SIGN];         break;
          case '&': [resultString appendString:PR_AMPERSAND];            break;
          case '\'':[resultString appendString:PR_SINGLE_QUOTE];         break;
          case '(': [resultString appendString:PR_OPEN_PARENTHESIS];     break;
          case ')': [resultString appendString:PR_CLOSE_PARENTHESIS];    break;
          case '*': [resultString appendString:PR_ASTERISK];             break;
          case '+': [resultString appendString:PR_PLUS_SIGN];            break;
          case ',': [resultString appendString:PR_COMMA];                break;
          case '-': [resultString appendString:PR_HYPHEN];               break;
          case '.': [resultString appendString:PR_PERIOD];               break;
          case '/': [resultString appendString:PR_SLASH];                break;
          case '0': [resultString appendString:PR_ZERO];                 break;
          case '1': [resultString appendString:PR_ONE];                  break;
          case '2': [resultString appendString:PR_TWO];                  break;
          case '3': [resultString appendString:PR_THREE];                break;
          case '4': [resultString appendString:PR_FOUR];                 break;
          case '5': [resultString appendString:PR_FIVE];                 break;
          case '6': [resultString appendString:PR_SIX];                  break;
          case '7': [resultString appendString:PR_SEVEN];                break;
          case '8': [resultString appendString:PR_EIGHT];                break;
          case '9': [resultString appendString:PR_NINE];                 break;
          case ':': [resultString appendString:PR_COLON];                break;
          case ';': [resultString appendString:PR_SEMICOLON];            break;
          case '<': [resultString appendString:PR_OPEN_ANGLE_BRACKET];   break;
          case '=': [resultString appendString:PR_EQUAL_SIGN];           break;
          case '>': [resultString appendString:PR_CLOSE_ANGLE_BRACKET];  break;
          case '?': [resultString appendString:PR_QUESTION_MARK];        break;
          case '@': [resultString appendString:PR_AT_SIGN];              break;
          case 'A':
          case 'a': [resultString appendString:PR_A];                    break;
          case 'B':
          case 'b': [resultString appendString:PR_B];                    break;
          case 'C':
          case 'c': [resultString appendString:PR_C];                    break;
          case 'D':
          case 'd': [resultString appendString:PR_D];                    break;
          case 'E':
          case 'e': [resultString appendString:PR_E];                    break;
          case 'F':
          case 'f': [resultString appendString:PR_F];                    break;
          case 'G':
          case 'g': [resultString appendString:PR_G];                    break;
          case 'H':
          case 'h': [resultString appendString:PR_H];                    break;
          case 'I':
          case 'i': [resultString appendString:PR_I];                    break;
          case 'J':
          case 'j': [resultString appendString:PR_J];                    break;
          case 'K':
          case 'k': [resultString appendString:PR_K];                    break;
          case 'L':
          case 'l': [resultString appendString:PR_L];                    break;
          case 'M':
          case 'm': [resultString appendString:PR_M];                    break;
          case 'N':
          case 'n': [resultString appendString:PR_N];                    break;
          case 'O':
          case 'o': [resultString appendString:PR_O];                    break;
          case 'P':
          case 'p': [resultString appendString:PR_P];                    break;
          case 'Q':
          case 'q': [resultString appendString:PR_Q];                    break;
          case 'R':
          case 'r': [resultString appendString:PR_R];                    break;
          case 'S':
          case 's': [resultString appendString:PR_S];                    break;
          case 'T':
          case 't': [resultString appendString:PR_T];                    break;
          case 'U':
          case 'u': [resultString appendString:PR_U];                    break;
          case 'V':
          case 'v': [resultString appendString:PR_V];                    break;
          case 'W':
          case 'w': [resultString appendString:PR_W];                    break;
          case 'X':
          case 'x': [resultString appendString:PR_X];                    break;
          case 'Y':
          case 'y': [resultString appendString:PR_Y];                    break;
          case 'Z':
          case 'z': [resultString appendString:PR_Z];                    break;
          case '[': [resultString appendString:PR_OPEN_SQUARE_BRACKET];  break;
          case '\\':[resultString appendString:PR_BACKSLASH];            break;
          case ']': [resultString appendString:PR_CLOSE_SQUARE_BRACKET]; break;
          case '^': [resultString appendString:PR_CARET];                break;
          case '_': [resultString appendString:PR_UNDERSCORE];           break;
          case '`': [resultString appendString:PR_GRAVE_ACCENT];         break;
          case '{': [resultString appendString:PR_OPEN_BRACE];           break;
          case '|': [resultString appendString:PR_VERTICAL_BAR];         break;
          case '}': [resultString appendString:PR_CLOSE_BRACE];          break;
          case '~': [resultString appendString:PR_TILDE];                break;
          default:  [resultString appendString:PR_UNKNOWN];              break;
        }
    }

    return resultString;
}

@end
