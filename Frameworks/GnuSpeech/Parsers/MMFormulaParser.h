#import "GSParser.h"

@class MMFormulaTerminal, MMFormulaNode, MModel;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMFormulaParser : GSParser
{
    MModel *model;

    int lookahead;
}

+ (MMFormulaNode *)parsedExpressionFromString:(NSString *)aString model:(MModel *)aModel;
+ (NSString *)nameForToken:(int)aToken;

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

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
