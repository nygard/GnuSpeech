#import "MMFormulaNode.h"

@class PhoneList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface FormulaExpression : MMFormulaNode
{
    int operation;
    NSMutableArray *expressions;

    /* Cached evaluation */
    int cacheTag;
    double cacheValue;
}

- (id)init;
- (void)dealloc;

- (int)operation;
- (void)setOperation:(int)newOp;

- (void)addSubExpression:newExpression;

- (id)operandOne;
- (void)setOperandOne:(id)operand;

- (id)operandTwo;
- (void)setOperandTwo:(id)operand;

- (NSString *)opString;

// Methods common to "MMFormulaNode" -- for both FormulaExpression, FormulaTerminal
- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones;
- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones tempos:(double *)tempos;

- (int)maxPhone;

- (void)expressionString:(NSMutableString *)resultString;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

@end
