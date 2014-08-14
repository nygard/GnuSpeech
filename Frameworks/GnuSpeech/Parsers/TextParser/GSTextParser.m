#import "GSTextParser.h"
#import "GSTextParser-Private.h"

#import "NSRegularExpression-GSExtensions.h"
#import "NSScanner-Extensions.h"
#import "NSString-Extensions.h"
#import "GSPronunciationDictionary.h"
#import "GSDBMPronunciationDictionary.h"
#import "GSSimplePronunciationDictionary.h"
#import "GSTextParserModeStack.h"

NSString *GSTextParserErrorDomain = @"GSTextParserErrorDomain";

/// Contains an NSNumber wrapping GSTextParserMode.  If this attribute isn't present, assume GSTextParserMode_Normal.
NSString *GSTextParserAttribute_Mode = @"GSTextParserAttribute_Mode";

/// Containers an NSNumber wrapping an NSInteger.
NSString *GSTextParserAttribute_TagValue = @"GSTextParserAttribute_TagValue";

/// Containers an NSNumber wrapping a double.
NSString *GSTextParserAttribute_SilenceValue = @"GSTextParserAttribute_SilenceValue";

// <http://userguide.icu-project.org/strings/regexp>

@implementation GSTextParser
{
    GSPronunciationDictionary *_userDictionary;
    GSPronunciationDictionary *_applicationDictionary;
    GSPronunciationDictionary *_mainDictionary;
    GSPronunciationDictionary *_specialAcronymDictionary;

    NSArray *_pronunciationSourceOrder;
    NSString *_escapeCharacter;

    NSRegularExpression *_re_condition_hyphenation;
    NSCharacterSet *_cs_condition_printableAndEscape_inverted;
}

- (id)init;
{
    if ((self = [super init])) {
        _mainDictionary           = [GSDBMPronunciationDictionary mainDictionary];
        _specialAcronymDictionary = [GSSimplePronunciationDictionary specialAcronymDictionary];
        
        _pronunciationSourceOrder = @[ @(GSPronunciationSource_NumberParser),
                                       @(GSPronunciationSource_UserDictionary),
                                       @(GSPronunciationSource_ApplicationDictionary),
                                       @(GSPronunciationSource_MainDictionary),
                                       ];
        _escapeCharacter = @"%";

        [self _setupRegularExpressionsAndCharacterSets];
    }

    return self;
}

- (void)_setupRegularExpressionsAndCharacterSets;
{
    NSError *error;
    _re_condition_hyphenation = [[NSRegularExpression alloc] initWithPattern:@"([:alnum:])-[\t\v\f\r ]*\n[\t\v\f\r ]*" options:0 error:&error];
    if (_re_condition_hyphenation == nil) {
        NSLog(@"_re_condition_hyphenation: %@, error: %@", _re_condition_hyphenation, error);
    }

    [self _regeneratePrintableAndEscape];
}

- (void)_regeneratePrintableAndEscape;
{
    NSMutableCharacterSet *printableAndEscape = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [printableAndEscape formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [printableAndEscape formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    NSParameterAssert([self.escapeCharacter length] == 1);
    [printableAndEscape addCharactersInString:self.escapeCharacter];
    [printableAndEscape addCharactersInString:@" "];
    _cs_condition_printableAndEscape_inverted = [printableAndEscape invertedSet];
}

#pragma mark -

- (void)setEscapeCharacter:(NSString *)escapeCharacter;
{
    NSParameterAssert([escapeCharacter length] == 1);
    _escapeCharacter = escapeCharacter;
    [self _regeneratePrintableAndEscape];
}

#pragma mark -

- (NSString *)_pronunciationForWord:(NSString *)word fromSource:(GSPronunciationSource)source;
{
    switch (source) {
        case GSPronunciationSource_NumberParser:          return nil; // number_parser()
        case GSPronunciationSource_UserDictionary:        return [self.userDictionary pronunciationForWord:word];
        case GSPronunciationSource_ApplicationDictionary: return [self.applicationDictionary pronunciationForWord:word];
        case GSPronunciationSource_MainDictionary:        return [self.mainDictionary pronunciationForWord:word];
        case GSPronunciationSource_LetterToSound:         return nil; // letter_to_sound()
        default:
            break;
    }

    return nil;
}

- (NSString *)pronunciationForWord:(NSString *)word andReturnPronunciationSource:(GSPronunciationSource *)source;
{
    for (NSNumber *dictionarySource in self.pronunciationSourceOrder) {
        NSString *pronunciation = [self _pronunciationForWord:word fromSource:[dictionarySource unsignedIntegerValue]];

        if (pronunciation != nil) {
            if (source != NULL) *source = [dictionarySource unsignedIntegerValue];
            return pronunciation;
        }
    }

    // Fall back to letter-to-sound as a last resort, to guarantee pronunciation of some sort.
    NSString *pronunciation = [self _pronunciationForWord:word fromSource:GSPronunciationSource_LetterToSound];
    if (pronunciation != nil) {
        if (source != NULL) *source = GSPronunciationSource_LetterToSound;
        return pronunciation;
    }

    // Use degenerate_string() / GSPronunciationSource_LetterToSound.

    return nil;
}

- (NSString *)parseString:(NSString *)string error:(NSError **)error;
{
    NSString *str = [self _conditionInputString:string];
    return str;
}

#pragma mark -

/// Convert all non-printable characters (except escape character) to blanks.
/// Also connect words hyphenated over a newline.
- (NSString *)_conditionInputString:(NSString *)str;
{
    NSString *s1 = [_re_condition_hyphenation stringByReplacingMatchesInString:str options:0 withTemplate:@"$1"];

    // Keep escape character and printable characters, change everything else to a space.
    NSString *s2 = [s1 stringByReplacingCharactersInSet:_cs_condition_printableAndEscape_inverted withString:@" "];

    return s2;
}

#define MM_SET_ERROR_FOR_POP(m) { \
    if (error != NULL) { \
        NSDictionary *userInfo = @{ \
                                   @"inputLocation" : @(scanner.scanLocation), \
                                   @"partialResult" : [resultString copy], \
                                   @"currentMode"   : @(modeStack.currentMode), \
                                   @"popMode"       : @(GSTextParserMode_Raw), \
                                   }; \
        *error = [NSError errorWithDomain:GSTextParserErrorDomain code:GSTextParserError_UnbalancedPop userInfo:userInfo]; \
    } \
}

- (NSAttributedString *)_markModesInString:(NSString *)str error:(NSError **)error;
{
    NSParameterAssert(str != nil);

    GSTextParserModeStack *modeStack = [[GSTextParserModeStack alloc] init];

    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] init];;

    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];

    while (![scanner isAtEnd]) {
        NSString *s1;
        if ([scanner scanUpToString:self.escapeCharacter intoString:&s1]) {
            NSDictionary *attrs = @{ GSTextParserAttribute_Mode : @(modeStack.currentMode) };
            NSAttributedString *astr = [[NSAttributedString alloc] initWithString:s1 attributes:attrs];
            [resultString appendAttributedString:astr];
        }
        if ([scanner scanString:self.escapeCharacter intoString:&s1]) {
            if (modeStack.currentMode == GSTextParserMode_Raw) {
                NSString *ignore;
                if ([scanner scanString:@"re" intoString:&ignore]) { // TODO: (2014-08-12) Should be case insensitive: re, rE, Re, RE -- raw end
                    if (![modeStack popMode:GSTextParserMode_Raw]) {
                        MM_SET_ERROR_FOR_POP(GSTextParserMode_Raw);
                        return nil;
                    }
                } else {
                    // Pass through escape character, if printable.
                    NSDictionary *attrs = @{ GSTextParserAttribute_Mode : @(modeStack.currentMode) };
                    NSAttributedString *astr = [[NSAttributedString alloc] initWithString:self.escapeCharacter attributes:attrs];
                    [resultString appendAttributedString:astr];
                }
            } else {
                // Check for double escape
                if ([scanner scanString:self.escapeCharacter intoString:&s1]) {
                    // Pass through escape character, if printable.
                    NSDictionary *attrs = @{ GSTextParserAttribute_Mode : @(modeStack.currentMode) };
                    NSAttributedString *astr = [[NSAttributedString alloc] initWithString:self.escapeCharacter attributes:attrs];
                    [resultString appendAttributedString:astr];
                } else {
                    NSString *remainingString = [scanner remainingString];
                    // Check for beginning of mode.
                    if ([remainingString length] >= 2 && [@"b" isEqualToString:[[remainingString substringWithRange:NSMakeRange(1, 1)] lowercaseString]]) {
                        NSString *modeString = [[remainingString substringWithRange:NSMakeRange(0, 1)] lowercaseString];
                        if ([modeString isEqualToString:@"r"]) {
                            scanner.scanLocation += 2;
                            [modeStack pushMode:GSTextParserMode_Raw];
                        } else if ([modeString isEqualToString:@"l"]) {
                            scanner.scanLocation += 2;
                            [modeStack pushMode:GSTextParserMode_Letter];
                        } else if ([modeString isEqualToString:@"e"]) {
                            scanner.scanLocation += 2;
                            [modeStack pushMode:GSTextParserMode_Emphasis];
                        } else if ([modeString isEqualToString:@"t"]) {
                            scanner.scanLocation += 2;
                            [modeStack pushMode:GSTextParserMode_Tagging];

                            NSCharacterSet *spaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
                            NSString *s2;
                            [scanner scanCharacterFromSet:spaceCharacterSet intoString:&s2]; // Skip leading whitespace
                            NSInteger value;
                            if ([scanner scanInteger:&value]) {
                                // Pass through escape character, if printable.
                                NSDictionary *attrs = @{
                                                        GSTextParserAttribute_Mode     : @(modeStack.currentMode),
                                                        GSTextParserAttribute_TagValue : @(value),
                                                        };
                                // Only need one character to store attributes.  Helps when multiple adjacent with same attributes.  Dot so I can see how many when logged (spaces not good).
                                // 2014-08-12: Is a special Unicode character we could use, like the text attachment character.
                                NSAttributedString *astr = [[NSAttributedString alloc] initWithString:@"." attributes:attrs];
                                [resultString appendAttributedString:astr];
                                [scanner scanCharacterFromSet:spaceCharacterSet intoString:&s2]; // Skip trailing whitespace
                            }
                            NSString *peekAtEndTag = [scanner remainingString];
                            if ([peekAtEndTag length] >= 3
                                && [peekAtEndTag hasPrefix:self.escapeCharacter]
                                && [@"te" isEqualToString:[[peekAtEndTag substringWithRange:NSMakeRange(1, 2)] lowercaseString]])
                            {
                                // This has an explicit end tag.
                            } else {
                                if (![modeStack popMode:GSTextParserMode_Tagging]) {
                                    MM_SET_ERROR_FOR_POP(GSTextParserMode_Tagging);
                                    return nil;
                                }
                            }
                        } else if ([modeString isEqualToString:@"s"]) {
                            scanner.scanLocation += 2;
                            [modeStack pushMode:GSTextParserMode_Silence];

                            NSCharacterSet *spaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
                            NSString *s2;
                            [scanner scanCharacterFromSet:spaceCharacterSet intoString:&s2]; // Skip leading whitespace
                            double value;
                            if ([scanner scanDouble:&value]) {
                                // Pass through escape character, if printable.
                                NSDictionary *attrs = @{
                                                        GSTextParserAttribute_Mode         : @(modeStack.currentMode),
                                                        GSTextParserAttribute_SilenceValue : @(value),
                                                        };
                                NSAttributedString *astr = [[NSAttributedString alloc] initWithString:@"." attributes:attrs];
                                [resultString appendAttributedString:astr];
                                [scanner scanCharacterFromSet:spaceCharacterSet intoString:&s2]; // Skip trailing whitespace
                            }
                            NSString *peekAtEndTag = [scanner remainingString];
                            if ([peekAtEndTag length] >= 3
                                && [peekAtEndTag hasPrefix:self.escapeCharacter]
                                && [@"se" isEqualToString:[[peekAtEndTag substringWithRange:NSMakeRange(1, 2)] lowercaseString]])
                            {
                                // This has an explicit end tag.
                            } else {
                                if (![modeStack popMode:GSTextParserMode_Silence]) {
                                    MM_SET_ERROR_FOR_POP(GSTextParserMode_Silence);
                                    return nil;
                                }
                            }
                        } else {
                            // Pass through escape character, if printable.
                            NSDictionary *attrs = @{ GSTextParserAttribute_Mode : @(modeStack.currentMode) };
                            NSAttributedString *astr = [[NSAttributedString alloc] initWithString:self.escapeCharacter attributes:attrs];
                            [resultString appendAttributedString:astr];
                        }
                    }
                    // Check for end of mode.
                    else if ([remainingString length] >= 2 && [@"e" isEqualToString:[remainingString substringWithRange:NSMakeRange(1, 1)]]) {
                        NSString *modeString = [remainingString substringWithRange:NSMakeRange(0, 1)];
                        if ([modeString isEqualToString:@"r"]) {
                            scanner.scanLocation += 2;
                            if (![modeStack popMode:GSTextParserMode_Raw]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Raw);
                                return nil;
                            }
                        } else if ([modeString isEqualToString:@"l"]) {
                            scanner.scanLocation += 2;
                            if (![modeStack popMode:GSTextParserMode_Letter]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Letter);
                                return nil;
                            }
                        } else if ([modeString isEqualToString:@"e"]) {
                            scanner.scanLocation += 2;
                            if (![modeStack popMode:GSTextParserMode_Emphasis]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Emphasis);
                                return nil;
                            }
                        } else if ([modeString isEqualToString:@"t"]) {
                            scanner.scanLocation += 2;
                            if (![modeStack popMode:GSTextParserMode_Tagging]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Tagging);
                                return nil;
                            }
                        } else if ([modeString isEqualToString:@"s"]) {
                            scanner.scanLocation += 2;
                            if (![modeStack popMode:GSTextParserMode_Silence]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Silence);
                                return nil;
                            }
                        } else {
                            // Pass through escape character, if printable.
                            NSDictionary *attrs = @{ GSTextParserAttribute_Mode : @(modeStack.currentMode) };
                            NSAttributedString *astr = [[NSAttributedString alloc] initWithString:self.escapeCharacter attributes:attrs];
                            [resultString appendAttributedString:astr];
                        }
                    } else {
                        // Pass through escape character, if printable.
                        NSDictionary *attrs = @{ GSTextParserAttribute_Mode : @(modeStack.currentMode) };
                        NSAttributedString *astr = [[NSAttributedString alloc] initWithString:self.escapeCharacter attributes:attrs];
                        [resultString appendAttributedString:astr];
                    }
                }
            }
        }
    }

    return resultString;
}

- (NSString *)_stripPunctuationFromString:(NSString *)str;
{
    // TODO: (2014-08-14) These are all wrong.  We can't do that across the whole string.  This can only be done for certain modes.
    str = [self punc1_replaceSingleCharacters:str];

    // Replace these characters with words, so we don't have to check again later if they are isolated.  We'll know all remaining ones are NOT isolated.
    str = [self replaceIsolatedCharacters:str];

    str = [self punc1_deleteSingleQuotes:str];
    str = [self punc1_deleteSingleCharacters:str];

    return str;
}

- (NSString *)punc1_replaceSingleCharacters:(NSString *)str;
{
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:@"("];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:@")"];

    return str;
}

// punc1 used to check for isolated characters and not delete them, and then check for them again in punc2 to replace them.
// I'm going to just replace them first, to save future checks.

/// Replace isolated + and - characters with words.  Isolated means surrounded by space, or beginning/end of string.
- (NSString *)replaceIsolatedCharacters:(NSString *)str;
{
    str = [str stringByReplacingOccurrencesOfString:@" + " withString:@" plus "];
    str = [str stringByReplacingOccurrencesOfString:@" - " withString:@" minus "];
    if ([str hasPrefix:@"+ "]) str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"plus "];
    if ([str hasPrefix:@"- "]) str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"minus "];
    if ([str hasSuffix:@" +"]) str = [str stringByReplacingCharactersInRange:NSMakeRange([str length] - 2, 2) withString:@" plus"];
    if ([str hasSuffix:@" -"]) str = [str stringByReplacingCharactersInRange:NSMakeRange([str length] - 2, 2) withString:@" minus"];
    return str;
}

/// Delete single quotes, except those that have an alpha character before and after.
- (NSString *)punc1_deleteSingleQuotes:(NSString *)str;
{
    NSError *error;

    NSRegularExpression *re_singleQuoteAtStartOrEnd   = [[NSRegularExpression alloc] initWithPattern:@"^'|'$"                     options:0 error:&error];
    NSRegularExpression *re_singleQuoteBeforeNonAlpha = [[NSRegularExpression alloc] initWithPattern:@"([:alpha:])'([:^alpha:])"  options:0 error:&error];
    NSRegularExpression *re_singleQuoteAfterNonAlpha  = [[NSRegularExpression alloc] initWithPattern:@"([:^alpha:])'([:alpha:])"  options:0 error:&error];
    NSRegularExpression *re_isolatedSingleQuote       = [[NSRegularExpression alloc] initWithPattern:@"([:^alpha:])'([:^alpha:])" options:0 error:&error];
    if (re_singleQuoteAtStartOrEnd == nil)   { NSLog(@"re1: error: %@", error); }
    if (re_singleQuoteBeforeNonAlpha == nil) { NSLog(@"re2: error: %@", error); }
    if (re_singleQuoteAfterNonAlpha == nil)  { NSLog(@"re3: error: %@", error); }
    if (re_isolatedSingleQuote == nil)       { NSLog(@"re4: error: %@", error); }

    // Remove the single quote in all matching cases.
    str = [re_singleQuoteAtStartOrEnd   stringByReplacingMatchesInString:str options:0 withTemplate:@""];
    str = [re_singleQuoteBeforeNonAlpha stringByReplacingMatchesInString:str options:0 withTemplate:@"$1$2"];
    str = [re_singleQuoteAfterNonAlpha  stringByReplacingMatchesInString:str options:0 withTemplate:@"$1$2"];
    str = [re_isolatedSingleQuote       stringByReplacingMatchesInString:str options:0 withTemplate:@"$1$2"];

    return str;
}

- (NSString *)punc1_deleteSingleCharacters:(NSString *)str;
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\"`#*\\^_|~{}"];

    str = [str stringByReplacingCharactersInSet:set withString:@""];

    return str;
}

@end
