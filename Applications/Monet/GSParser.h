#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface GSParser : NSObject
{
    NSString *nonretained_parseString;
    NSScanner *scanner;
    NSString *symbolString;

    NSMutableString *errorMessage;
}

- (void)dealloc;

- (NSString *)symbolString;
- (void)setSymbolString:(NSString *)newString;

- (id)parseString:(NSString *)aString;
- (id)beginParseString;

// Error reporting
- (NSString *)errorMessage;
- (void)appendErrorFormat:(NSString *)format, ...;

@end
