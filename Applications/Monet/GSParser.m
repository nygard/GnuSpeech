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

- (NSRange)errorRange;
{
    return errorRange;
}

- (NSString *)errorMessage;
{
    // TODO (2004-03-03): Should we return a copy here, since it *is* mutable and used again?
    return errorMessage;
}

- (void)appendErrorFormat:(NSString *)format, ...;
{
    NSString *str;
    va_list args;

    // TODO (2004-03-13): Probably need better control over this.  It should start at the beginning of the last token scanned.
    if ([errorMessage length] == 0) {
        errorRange.location = startOfTokenLocation;
        errorRange.length = [scanner scanLocation] - errorRange.location;
    }

    va_start(args, format);
    str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    [errorMessage appendString:str];
    [errorMessage appendString:@"\n"];

    [str release];
}

@end
