#import "GSParser.h"

#import <Foundation/Foundation.h>
#import "NSScanner-Extensions.h"

@implementation GSParser

- (id)init;
{
    if ([super init] == nil)
        return nil;

    errorMessage = [[NSMutableString alloc] init];

    return self;
}

- (void)dealloc;
{
    [scanner release];
    [symbolString release];
    [errorMessage release];

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

    [errorMessage setString:@""];

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

- (NSString *)errorMessage;
{
    // TODO (2004-03-03): Should we return a copy here, since it *is* mutable and used again?
    return errorMessage;
}

- (void)appendErrorFormat:(NSString *)format, ...;
{
    va_list args;

    va_start(args, format);
    [errorMessage appendFormat:format, args];
    [errorMessage appendString:@"\n"];
    va_end(args);
}

@end
