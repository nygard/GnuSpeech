#import "MMFormulaNode.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMFormulaExpression : MMFormulaNode
{
    int operation;
    MMFormulaNode *left;
    MMFormulaNode *right;
}

- (id)init;
- (void)dealloc;

- (int)operation;
- (void)setOperation:(int)newOp;

- (id)operandOne;
- (void)setOperandOne:(id)operand;

- (id)operandTwo;
- (void)setOperandTwo:(id)operand;

- (NSString *)opString;

// Methods overridden from MMFormulaNode
- (int)precedence;

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols phones:(NSArray *)phones;
- (double)evaluate:(MMFRuleSymbols *)ruleSymbols phones:(NSArray *)phones tempos:(double *)tempos;

- (int)maxPhone;

- (void)expressionString:(NSMutableString *)resultString;

@end
