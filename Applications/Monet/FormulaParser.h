#import "GSParser.h"

@class SymbolList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface FormulaParser : GSParser
{
    SymbolList *symbolList;
}

- (void)dealloc;

- (SymbolList *)symbolList;
- (void)setSymbolList:(SymbolList *)newSymbolList;

- (int)nextToken;
- (BOOL)scanNumber;

- (id)beginParseString;

- (id)continueParse:currentExpression;
- (id)parseSymbol;

- (id)addOperation:operand;
- (id)subOperation:operand;
- (id)multOperation:operand;
- (id)divOperation:operand;

- (id)leftParen;

@end
