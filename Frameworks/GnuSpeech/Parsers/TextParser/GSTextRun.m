#import "GSTextRun.h"

#import "NSRegularExpression-GSExtensions.h"
#import "NSString-Extensions.h"

@implementation GSTextRun
{
    GSTextParserMode _mode;
    NSMutableString *_string;
}

- (id)initWithMode:(GSTextParserMode)mode;
{
    if ((self = [super init])) {
        _mode = mode;
        _string = [[NSMutableString alloc] init];
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> mode: %@, string: '%@'",
            NSStringFromClass([self class]), self,
            [GSTextParserModeDescription(self.mode) stringByPaddingToLength:8 withString:@" " startingAtIndex:0], self.string];
}

#pragma mark -

- (void)stripPunctuation;
{
    if (self.mode == GSTextParserMode_Normal || self.mode == GSTextParserMode_Emphasis) {
        _string = [[self _stripPunctuationFromString:_string] mutableCopy];
    }
}

- (NSString *)_stripPunctuationFromString:(NSString *)str;
{
    str = [self _punc1_replaceSingleCharacters:str];

    // Replace these characters with words, so we don't have to check again later if they are isolated.  We'll know all remaining ones are NOT isolated.
    str = [self _replaceIsolatedCharacters:str];

    str = [self _punc1_deleteSingleQuotes:str];
    str = [self _punc1_deleteSingleCharacters:str];

    return str;
}

- (NSString *)_punc1_replaceSingleCharacters:(NSString *)str;
{
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:@"("];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:@")"];

    return str;
}

// punc1 used to check for isolated characters and not delete them, and then check for them again in punc2 to replace them.
// I'm going to just replace them first, to save future checks.

/// Replace isolated + and - characters with words.  Isolated means surrounded by space, or beginning/end of string.
- (NSString *)_replaceIsolatedCharacters:(NSString *)str;
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
- (NSString *)_punc1_deleteSingleQuotes:(NSString *)str;
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

- (NSString *)_punc1_deleteSingleCharacters:(NSString *)str;
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\"`#*\\^_|~{}"];

    str = [str stringByReplacingCharactersInSet:set withString:@""];
    
    return str;
}

@end
