#import "GSParser.h"

#import <Foundation/Foundation.h>
#import "NSScanner-Extensions.h"

@implementation GSParser

- (void)dealloc;
{
    [scanner release];
    [symbolString release];

    [super dealloc];
}

- (NSString *)symbolString;
{
    return symbolString;
}

- (void)setSymbolString:(NSString *)newString;
{
    if (newString == symbolString)
        return;

    [symbolString release];
    symbolString = [newString retain];
}

- (id)parseString:(NSString *)aString;
{
    id result;

    if (scanner != nil)
        [scanner release];

    [nonretained_errorTextField setStringValue:@""];

    nonretained_parseString = aString;
    scanner = [[NSScanner alloc] initWithString:aString];
    [scanner setCharactersToBeSkipped:nil];

    result = [self beginParseString];

    nonretained_parseString = nil;
    [scanner release];
    scanner = nil;

    return result;
}

- (id)beginParseString;
{
    return nil;
}

//
// Error reporting
//

- (void)setErrorOutput:(NSTextField *)aTextField;
{
    nonretained_errorTextField = aTextField;
}

- (void)outputError:(NSString *)errorText;
{
    NSString *str;

    str = [nonretained_errorTextField stringValue];
    if (str == nil)
        str = [NSString stringWithFormat:@"%@\n", errorText];
    else
        str = [str stringByAppendingFormat:@"\n%@", errorText];

    [nonretained_errorTextField setStringValue:str];
}

- (void)outputError:(NSString *)errorText with:(NSString *)symbol;
{
    NSString *str;

    str = [nonretained_errorTextField stringValue];
    if (str == nil)
        str = [NSString stringWithFormat:@"%@\n", errorText];
    else {
        str = [str stringByAppendingString:@"\n"];
        str = [str stringByAppendingFormat:errorText, symbol];
        str = [str stringByAppendingString:@"\n"];
    }

    [nonretained_errorTextField setStringValue:str];
}

@end
