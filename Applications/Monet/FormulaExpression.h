#import <Foundation/NSObject.h>

#import "FormulaSymbols.h"

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

- (int)precedence;
- (void)setPrecedence:(int)newPrec;

- (double)evaluate:(double *)ruleSymbols phones:phones;
- (double)evaluate:(double *)ruleSymbols tempos:(double *)tempos phones:phones;

- (void)addSubExpression:newExpression;

- operandOne;
- (void)setOperandOne:operand;

- operandTwo;
- (void)setOperandTwo:operand;


- (void)optimize;
- (void)optimizeSubExpressions;

- (int)maxExpressionLevels;
- (int)maxPhone;

- (void)expressionString:(NSMutableString *)resultString;
- (NSString *)opString;

//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
