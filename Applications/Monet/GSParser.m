#import "GSParser.h"

#import <Foundation/Foundation.h>
#import "NSScanner-Extensions.h"

@implementation GSParser

- (id)init;
{
    if ([super init] == nil)
        return nil;

    errorMessages = [[NSMutableString alloc] init];

    return self;
}

- (void)dealloc;
{
    [scanner release];
    [symbolString release];
    [errorMessages release];

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

    [errorMessages setString:@""];
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

- (void)appendErrorFormat:(NSString *)format, ...;
{
    va_list args;

    va_start(args, format);
    [errorMessages appendFormat:format, args];
    [errorMessages appendString:@"\n"];
    va_end(args);

    //[nonretained_errorTextField setStringValue:str];
}

@end
