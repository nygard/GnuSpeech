
#import <Foundation/NSObject.h>
#import "CategoryList.h"
//#import "PhoneList.h"
#import "FormulaExpression.h"
#import "FormulaTerminal.h"
#import "FormulaSymbols.h"
#import "SymbolList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface FormulaParser:NSObject
{
	int consumed;
	int stringIndex;
	const char *parseString;
	char symbolString[256];

	SymbolList *symbolList;

	id	errorText;
}

- init;

- (int) nextToken;
- (void)consumeToken;
- parseString:(const char *)string;
- continueParse:currentExpression;
- parseSymbol;


- setSymbolList:(SymbolList *)newSymbolList;
- symbolList;

- (int) scanNumber;
- (int) scanSymbol;

- addOperation:operand;
- subOperation:operand;
- multOperation:operand;
- divOperation:operand;

- leftParen;

- (void)setErrorOutput:aTextObject;
- (void)outputError:(const char *)outputText;
- (void)outputError:(const char *) outputText with: (const char *) symbol;


@end
