#import <Foundation/NSObject.h>

@class SymbolList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface FormulaParser : NSObject
{
    BOOL consumed;
    NSString *nonretained_parseString;
    NSScanner *scanner;
    NSString *symbolString;

    SymbolList *symbolList;

    NSTextField *nonretained_errorTextField; // TODO (2004-03-01): Change this to an NSMutableString, and query it in the interface controller.
}

- (void)dealloc;

- (NSString *)symbolString;
- (void)setSymbolString:(NSString *)newString;

- (SymbolList *)symbolList;
- (void)setSymbolList:(SymbolList *)newSymbolList;

- (int)nextToken;
- (BOOL)scanNumber;

- (void)consumeToken;
- parseString:(NSString *)aString;
- beginParseString;
- continueParse:currentExpression;
- parseSymbol;

- addOperation:operand;
- subOperation:operand;
- multOperation:operand;
- divOperation:operand;

- leftParen;

- (void)setErrorOutput:(NSTextField *)aTextField;
- (void)outputError:(NSString *)errorText;
- (void)outputError:(NSString *)errorText with:(NSString *)symbol;

@end
