#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

extern NSString *GSParserSyntaxErrorException;

@interface GSParser : NSObject
{
    NSString *nonretained_parseString;
    NSScanner *scanner;
    NSString *symbolString;

    unsigned int startOfTokenLocation;
    NSRange errorRange;
    NSMutableString *errorMessage;
}

- (id)init;
- (void)dealloc;

- (NSString *)symbolString;
- (void)setSymbolString:(NSString *)newString;

- (id)parseString:(NSString *)aString;
- (id)beginParseString;

// Error reporting
- (NSRange)errorRange;
- (NSString *)errorMessage;
- (void)appendErrorFormat:(NSString *)format, ...;

@end
