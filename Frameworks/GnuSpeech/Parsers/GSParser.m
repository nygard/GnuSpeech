//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSParser.h"

#import <Foundation/Foundation.h>
#import "NSScanner-Extensions.h"

NSString *GSParserSyntaxErrorException = @"GSParserSyntaxErrorException";

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
    id result = nil;

    if (scanner != nil)
        [scanner release];

    [errorMessage setString:@""];

    nonretained_parseString = aString;
    scanner = [[NSScanner alloc] initWithString:aString];
    [scanner setCharactersToBeSkipped:nil];

    NS_DURING {
        result = [self beginParseString];
    } NS_HANDLER {
        if ([[localException name] isEqualToString:GSParserSyntaxErrorException]) {
            NSLog(@"Syntax Error: %@ while parsing: %@, remaining part: %@", [self errorMessage], aString, [aString substringFromIndex:errorRange.location]);
            result = nil;
        } else {
            nonretained_parseString = nil;
            [scanner release];
            scanner = nil;
            [localException raise];
        }
    } NS_ENDHANDLER;

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
