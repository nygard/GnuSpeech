#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface FormulaExpression : NSObject
{
    int operation;
    int precedence;
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

// Methods common to "FormulaNode" -- for both FormulaExpression, FormulaTerminal
- (int)precedence;
- (void)setPrecedence:(int)newPrec;

- (double)evaluate:(double *)ruleSymbols phones:phones;
- (double)evaluate:(double *)ruleSymbols tempos:(double *)tempos phones:phones;

- (void)optimize;
- (void)optimizeSubExpressions;

- (int)maxExpressionLevels;
- (int)maxPhone;

- (void)expressionString:(NSMutableString *)resultString;

// Archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
