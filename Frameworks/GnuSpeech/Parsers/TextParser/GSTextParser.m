#import "GSTextParser.h"

#import "GSPronunciationDictionary.h"
#import "GSDBMPronunciationDictionary.h"
#import "GSSimplePronunciationDictionary.h"

// <http://userguide.icu-project.org/strings/regexp>

@interface NSString (GSExtensions)
- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)set withString:(NSString *)str;
@end

@implementation NSString (GSExtensions)

- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)set withString:(NSString *)str;
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    NSMutableString *result = [[NSMutableString alloc] init];
    while (![scanner isAtEnd]) {
        NSString *str;
        if ([scanner scanUpToCharactersFromSet:set intoString:&str]) [result appendString:str];

        if ([scanner scanCharactersFromSet:set intoString:&str]) {
            // 2014-08-11: Strictly speaking, this method should append spaces of the same length, but one space should be good enough for my needs.
            [result appendString:@" "];
        }
    }
    return [result copy];
}

@end

@implementation GSTextParser
{
    GSPronunciationDictionary *_userDictionary;
    GSPronunciationDictionary *_applicationDictionary;
    GSPronunciationDictionary *_mainDictionary;
    GSPronunciationDictionary *_specialAcronymDictionary;

    NSArray *_pronunciationSourceOrder;
    NSString *_escapeCharacter;
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
    }

    return self;
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

// TODO: (2014-08-11) The regular expressions and character sets should not be created each time in this method.  Create them in init.

/// Convert all non-printable characters (except escape character) to blanks.
/// Also connect words hyphenated over a newline.
- (NSString *)_conditionInputString:(NSString *)str;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"str: '%@'", str);
    NSError *reError;
    NSRegularExpression *re_hyphenation = [[NSRegularExpression alloc] initWithPattern:@"([:alnum:])-[\t\v\f\r ]*\n[\t\v\f\r ]*" options:0 error:&reError];
    //NSLog(@"re_hyphenation: %@, error: %@", re_hyphenation, reError);
    NSString *s1 = [re_hyphenation stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"$1"];
    //NSLog(@"s1: '%@'", s1);

    NSMutableCharacterSet *printableAndEscape = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [printableAndEscape formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [printableAndEscape formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    NSParameterAssert([self.escapeCharacter length] == 1);
    [printableAndEscape addCharactersInString:self.escapeCharacter];
    [printableAndEscape addCharactersInString:@" "];

    // Keep escape character and printable characters, change everything else to a space.
    NSString *s2 = [s1 stringByReplacingCharactersInSet:[printableAndEscape invertedSet] withString:@" "];

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
    return s2;
}

@end
