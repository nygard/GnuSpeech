
#import <Foundation/NSObject.h>
#ifdef NeXT
#import <objc/typedstream.h>
#endif
#import "FormulaSymbols.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface FormulaExpression:NSObject
{
	int	operation;
	int	numExpressions;
	int	maxExpressions;
	int	precedence;
	id	*expressions;

	/* Cached evaluation */
	int	cacheTag;
	double	cacheValue;
}

- init;
- (void)dealloc;

- (double) evaluate: (double *) ruleSymbols phones: phones;
- (double) evaluate: (double *) ruleSymbols tempos: (double *) tempos phones: phones;

- (void)setOperation:(int)newOp;
- (int) operation;

- (void)setPrecedence:(int)newPrec;
- (int) precedence;

- (void)addSubExpression:newExpression;

- (void)setOperandOne:operand;
- operandOne;

- (void)setOperandTwo:operand;
- operandTwo;


- (void)optimize;
- (void)optimizeSubExpressions;

- (int) maxExpressionLevels;
- (int) maxPhone;
- expressionString:(char *)string;

- (char *) opString;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
