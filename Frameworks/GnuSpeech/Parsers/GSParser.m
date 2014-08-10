//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSParser.h"

#import "NSScanner-Extensions.h"

NSString *GSParserSyntaxErrorException = @"GSParserSyntaxErrorException";

@implementation GSParser
{
    __weak NSString *_parseString;
    NSScanner *_scanner;
    NSString *_symbolString;

    NSUInteger _startOfTokenLocation;
    NSRange _errorRange;
    NSMutableString *_errorMessage;
}

- (id)init;
{
    if ((self = [super init])) {
        _errorMessage = [[NSMutableString alloc] init];
    }

    return self;
}

#pragma mark -

- (id)parseString:(NSString *)aString;
{
    id result = nil;

    [_errorMessage setString:@""];

    _parseString = aString;
    _scanner = [[NSScanner alloc] initWithString:aString];
    [_scanner setCharactersToBeSkipped:nil];

    NS_DURING {
        result = [self beginParseString];
    } NS_HANDLER {
        if ([[localException name] isEqualToString:GSParserSyntaxErrorException]) {
            NSLog(@"Syntax Error: %@ while parsing: %@, remaining part: %@", [self errorMessage], aString, [aString substringFromIndex:_errorRange.location]);
            result = nil;
        } else {
            _parseString = nil;
            _scanner = nil;
            [localException raise];
        }
    } NS_ENDHANDLER;

    _parseString = nil;
    _scanner = nil;

    return result;
}

- (id)beginParseString;
{
    return nil;
}

#pragma mark - Error reporting

- (NSRange)errorRange;
{
    return _errorRange;
}

- (NSString *)errorMessage;
{
    // TODO (2004-03-03): Should we return a copy here, since it *is* mutable and used again?
    return _errorMessage;
}

- (void)appendErrorFormat:(NSString *)format, ...;
{
    va_list args;

    // TODO (2004-03-13): Probably need better control over this.  It should start at the beginning of the last token scanned.
    if ([_errorMessage length] == 0) {
        _errorRange.location = _startOfTokenLocation;
        _errorRange.length = [_scanner scanLocation] - _errorRange.location;
    }

    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    [_errorMessage appendString:str];
    [_errorMessage appendString:@"\n"];
}

@end
