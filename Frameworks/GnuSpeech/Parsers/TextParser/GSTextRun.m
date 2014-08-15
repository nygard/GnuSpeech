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
        [self _punc1_replaceSingleCharacters];

        // Replace these characters with words, so we don't have to check again later if they are isolated.  We'll know all remaining ones are NOT isolated.
        [self _replaceIsolatedCharacters];

        [self _punc1_deleteSingleQuotes];
        [self _punc1_deleteSingleCharacters];
    }
}

- (void)_punc1_replaceSingleCharacters;
{
    [_string replaceOccurrencesOfString:@"[" withString:@"(" options:0];
    [_string replaceOccurrencesOfString:@"]" withString:@")" options:0];
}

// punc1 used to check for isolated characters and not delete them, and then check for them again in punc2 to replace them.
// I'm going to just replace them first, to save future checks.

/// Replace isolated + and - characters with words.  Isolated means surrounded by space, or beginning/end of string.
- (void)_replaceIsolatedCharacters;
{
    [_string replaceOccurrencesOfString:@" + " withString:@" plus "  options:0];
    [_string replaceOccurrencesOfString:@" - " withString:@" minus " options:0];

    if ([_string hasPrefix:@"+ "]) [_string replaceCharactersInRange:NSMakeRange(0, 2) withString:@"plus "];
    if ([_string hasPrefix:@"- "]) [_string replaceCharactersInRange:NSMakeRange(0, 2) withString:@"minus "];

    if ([_string hasSuffix:@" +"]) [_string replaceCharactersInRange:NSMakeRange([_string length] - 2, 2) withString:@" plus"];
    if ([_string hasSuffix:@" -"]) [_string replaceCharactersInRange:NSMakeRange([_string length] - 2, 2) withString:@" minus"];
}

/// Delete single quotes, except those that have an alpha character before and after.
- (void)_punc1_deleteSingleQuotes;
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
    [re_singleQuoteAtStartOrEnd   replaceMatchesInString:_string options:0 withTemplate:@""];
    [re_singleQuoteBeforeNonAlpha replaceMatchesInString:_string options:0 withTemplate:@"$1$2"];
    [re_singleQuoteAfterNonAlpha  replaceMatchesInString:_string options:0 withTemplate:@"$1$2"];
    [re_isolatedSingleQuote       replaceMatchesInString:_string options:0 withTemplate:@"$1$2"];}

- (void)_punc1_deleteSingleCharacters;
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\"`#*\\^_|~{}"];

    [_string deleteCharactersInSet:set];
}

@end
