#import "GSParser.h"

@class MMFormulaTerminal, MMFormulaNode, SymbolList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface FormulaParser : GSParser
{
    SymbolList *symbolList;

    int lookahead;
}

- (void)dealloc;

- (SymbolList *)symbolList;
- (void)setSymbolList:(SymbolList *)newSymbolList;

- (int)nextToken;
- (BOOL)scanNumber;


- (void)match:(int)token;
- (MMFormulaNode *)parseExpression;
- (MMFormulaNode *)parseTerm;
- (MMFormulaNode *)parseFactor;

- (MMFormulaTerminal *)parseNumber;
- (MMFormulaNode *)parseSymbol;


- (id)beginParseString;

@end
