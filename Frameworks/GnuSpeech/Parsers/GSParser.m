////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  GSParser.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

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
