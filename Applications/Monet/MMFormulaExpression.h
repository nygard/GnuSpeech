#import "MMFormulaNode.h"

@class PhoneList;

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

- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones;
- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones tempos:(double *)tempos;

- (int)maxPhone;

- (void)expressionString:(NSMutableString *)resultString;

@end
