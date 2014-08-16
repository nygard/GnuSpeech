#import "GSTextParser.h"
#import "GSTextParser-Private.h"

#import "NSRegularExpression-GSExtensions.h"
#import "NSScanner-Extensions.h"
#import "NSString-Extensions.h"
#import "GSPronunciationDictionary.h"
#import "GSDBMPronunciationDictionary.h"
#import "GSSimplePronunciationDictionary.h"
#import "GSTextGroupBuilder.h"
#import "GSTextRun.h"
#import "GSTextGroup.h"

NSString *GSTextParserErrorDomain = @"GSTextParserErrorDomain";

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
        
        _pronunciationSourceOrder = @[ @(GSPronunciationSourceType_NumberParser),
                                       @(GSPronunciationSourceType_UserDictionary),
                                       @(GSPronunciationSourceType_ApplicationDictionary),
                                       @(GSPronunciationSourceType_MainDictionary),
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

- (NSString *)_pronunciationForWord:(NSString *)word fromSource:(GSPronunciationSourceType)source;
{
    switch (source) {
        case GSPronunciationSourceType_NumberParser:          return nil; // number_parser()
        case GSPronunciationSourceType_UserDictionary:        return [self.userDictionary pronunciationForWord:word];
        case GSPronunciationSourceType_ApplicationDictionary: return [self.applicationDictionary pronunciationForWord:word];
        case GSPronunciationSourceType_MainDictionary:        return [self.mainDictionary pronunciationForWord:word];
        case GSPronunciationSourceType_LetterToSound:         return nil; // letter_to_sound()
        default:
            break;
    }

    return nil;
}

- (NSString *)pronunciationForWord:(NSString *)word andReturnPronunciationSource:(GSPronunciationSourceType *)source;
{
    for (NSNumber *dictionarySource in self.pronunciationSourceOrder) {
        NSString *pronunciation = [self _pronunciationForWord:word fromSource:[dictionarySource unsignedIntegerValue]];

        if (pronunciation != nil) {
            if (source != NULL) *source = [dictionarySource unsignedIntegerValue];
            return pronunciation;
        }
    }

    // Fall back to letter-to-sound as a last resort, to guarantee pronunciation of some sort.
    NSString *pronunciation = [self _pronunciationForWord:word fromSource:GSPronunciationSourceType_LetterToSound];
    if (pronunciation != nil) {
        if (source != NULL) *source = GSPronunciationSourceType_LetterToSound;
        return pronunciation;
    }

    // Use degenerate_string() / GSPronunciationSource_LetterToSound.

    return nil;
}

- (NSString *)parseString:(NSString *)string error:(NSError **)error;
{
    NSString *str = [self _conditionInputString:string];
    GSTextGroup *textGroup = [self _markModesInString:string error:error];
    if (textGroup != nil) {
    } else {
        return nil;
    }

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
                                   @"currentMode"   : @(textGroupBuilder.currentMode), \
                                   @"popMode"       : @(m), \
                                   }; \
        *error = [NSError errorWithDomain:GSTextParserErrorDomain code:GSTextParserError_UnbalancedPop userInfo:userInfo]; \
    } \
}

- (GSTextGroup *)_markModesInString:(NSString *)str error:(NSError **)error;
{
    NSParameterAssert(str != nil);

    GSTextGroupBuilder *textGroupBuilder = [[GSTextGroupBuilder alloc] init];

    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];

    while (![scanner isAtEnd]) {
        NSString *s1;
        if ([scanner scanUpToString:self.escapeCharacter intoString:&s1]) {
            [textGroupBuilder.currentTextRun.string appendString:s1];
        }
        if ([scanner scanString:self.escapeCharacter intoString:&s1]) {
            if (textGroupBuilder.currentMode == GSTextParserMode_Raw) {
                NSString *ignore;
                if ([scanner scanString:@"re" intoString:&ignore]) { // TODO: (2014-08-12) Should be case insensitive: re, rE, Re, RE -- raw end
                    if (![textGroupBuilder popMode:GSTextParserMode_Raw]) {
                        MM_SET_ERROR_FOR_POP(GSTextParserMode_Raw);
                        return nil;
                    }
                } else {
                    // Pass through escape character, if printable.
                    [textGroupBuilder.currentTextRun.string appendString:self.escapeCharacter];
                }
            } else {
                // Check for double escape
                if ([scanner scanString:self.escapeCharacter intoString:&s1]) {
                    // Pass through escape character, if printable.
                    [textGroupBuilder.currentTextRun.string appendString:self.escapeCharacter];
                } else {
                    NSString *remainingString = [scanner remainingString];
                    // Check for beginning of mode.
                    if ([remainingString length] >= 2 && [@"b" isEqualToString:[[remainingString substringWithRange:NSMakeRange(1, 1)] lowercaseString]]) {
                        NSString *modeString = [[remainingString substringWithRange:NSMakeRange(0, 1)] lowercaseString];
                        if ([modeString isEqualToString:@"r"]) {
                            scanner.scanLocation += 2;
                            [textGroupBuilder pushMode:GSTextParserMode_Raw];
                        } else if ([modeString isEqualToString:@"l"]) {
                            scanner.scanLocation += 2;
                            [textGroupBuilder pushMode:GSTextParserMode_Letter];
                        } else if ([modeString isEqualToString:@"e"]) {
                            scanner.scanLocation += 2;
                            [textGroupBuilder pushMode:GSTextParserMode_Emphasis];
                        } else if ([modeString isEqualToString:@"t"]) {
                            scanner.scanLocation += 2;
                            [textGroupBuilder pushMode:GSTextParserMode_Tagging];

                            NSCharacterSet *spaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
                            NSString *s2;
                            [scanner scanCharacterFromSet:spaceCharacterSet intoString:&s2]; // Skip leading whitespace
                            NSInteger value;
                            if ([scanner scanInteger:&value]) {
                                [textGroupBuilder.currentTextRun.string appendString:[NSString stringWithFormat:@"%ld", value]];
                                [scanner scanCharacterFromSet:spaceCharacterSet intoString:&s2]; // Skip trailing whitespace
                            }
                            NSString *peekAtEndTag = [scanner remainingString];
                            if ([peekAtEndTag length] >= 3
                                && [peekAtEndTag hasPrefix:self.escapeCharacter]
                                && [@"te" isEqualToString:[[peekAtEndTag substringWithRange:NSMakeRange(1, 2)] lowercaseString]])
                            {
                                // This has an explicit end tag.
                            } else {
                                if (![textGroupBuilder popMode:GSTextParserMode_Tagging]) {
                                    MM_SET_ERROR_FOR_POP(GSTextParserMode_Tagging);
                                    return nil;
                                }
                            }
                        } else if ([modeString isEqualToString:@"s"]) {
                            scanner.scanLocation += 2;
                            [textGroupBuilder pushMode:GSTextParserMode_Silence];

                            NSCharacterSet *spaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
                            NSString *s2;
                            [scanner scanCharacterFromSet:spaceCharacterSet intoString:&s2]; // Skip leading whitespace
                            double value;
                            if ([scanner scanDouble:&value]) {
                                [textGroupBuilder.currentTextRun.string appendString:[NSString stringWithFormat:@"%g", value]];
                                [scanner scanCharacterFromSet:spaceCharacterSet intoString:&s2]; // Skip trailing whitespace
                            }
                            NSString *peekAtEndTag = [scanner remainingString];
                            if ([peekAtEndTag length] >= 3
                                && [peekAtEndTag hasPrefix:self.escapeCharacter]
                                && [@"se" isEqualToString:[[peekAtEndTag substringWithRange:NSMakeRange(1, 2)] lowercaseString]])
                            {
                                // This has an explicit end tag.
                            } else {
                                if (![textGroupBuilder popMode:GSTextParserMode_Silence]) {
                                    MM_SET_ERROR_FOR_POP(GSTextParserMode_Silence);
                                    return nil;
                                }
                            }
                        } else {
                            // Pass through escape character, if printable.
                            [textGroupBuilder.currentTextRun.string appendString:self.escapeCharacter];
                        }
                    }
                    // Check for end of mode.
                    else if ([remainingString length] >= 2 && [@"e" isEqualToString:[remainingString substringWithRange:NSMakeRange(1, 1)]]) {
                        NSString *modeString = [remainingString substringWithRange:NSMakeRange(0, 1)];
                        if ([modeString isEqualToString:@"r"]) {
                            scanner.scanLocation += 2;
                            if (![textGroupBuilder popMode:GSTextParserMode_Raw]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Raw);
                                return nil;
                            }
                        } else if ([modeString isEqualToString:@"l"]) {
                            scanner.scanLocation += 2;
                            if (![textGroupBuilder popMode:GSTextParserMode_Letter]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Letter);
                                return nil;
                            }
                        } else if ([modeString isEqualToString:@"e"]) {
                            scanner.scanLocation += 2;
                            if (![textGroupBuilder popMode:GSTextParserMode_Emphasis]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Emphasis);
                                return nil;
                            }
                        } else if ([modeString isEqualToString:@"t"]) {
                            scanner.scanLocation += 2;
                            if (![textGroupBuilder popMode:GSTextParserMode_Tagging]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Tagging);
                                return nil;
                            }
                        } else if ([modeString isEqualToString:@"s"]) {
                            scanner.scanLocation += 2;
                            if (![textGroupBuilder popMode:GSTextParserMode_Silence]) {
                                MM_SET_ERROR_FOR_POP(GSTextParserMode_Silence);
                                return nil;
                            }
                        } else {
                            // Pass through escape character, if printable.
                            [textGroupBuilder.currentTextRun.string appendString:self.escapeCharacter];
                        }
                    } else {
                        // Pass through escape character, if printable.
                        [textGroupBuilder.currentTextRun.string appendString:self.escapeCharacter];
                    }
                }
            }
        }
    }

    // (2014-08-14) Or just finish lazily in -textGroup, but that would break intermediate logging.
    [textGroupBuilder finish];

    NSLog(@"%s, textGroup: %@", __PRETTY_FUNCTION__, textGroupBuilder.textGroup);

    return textGroupBuilder.textGroup;
}

@end
