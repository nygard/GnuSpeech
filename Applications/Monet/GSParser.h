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

    NSTextField *nonretained_errorTextField; // TODO (2004-03-01): Change this to an NSMutableString, and query it in the interface controller.
}

- (void)dealloc;

- (NSString *)symbolString;
- (void)setSymbolString:(NSString *)newString;

- (id)parseString:(NSString *)aString;
- (id)beginParseString;

// Error reporting
- (void)setErrorOutput:(NSTextField *)aTextField;
- (void)outputError:(NSString *)errorText;
- (void)outputError:(NSString *)errorText with:(NSString *)symbol;

@end
