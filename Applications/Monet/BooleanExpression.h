#import <Foundation/NSObject.h>

@class CategoryList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: BooleanExpression
	Purpose:  Non-leaf node in a boolean expression tree.

	Instance Variables:
		operation: (int) Defines the operation to be performed on the
			return values from the subexpression(s).  One of
			NO_OP, NOT_OP, OR_OP, AND_OP, or XOR_OP.

		numExpressions: (int) The number of sub-expressions.  NOT_OP
			requires only one sub-expression.

		maxExpressions: (int) Future enhancements will offer more than
			two sub-expressions.  This variable keeps track of
			how much space has been allocated for storing
			sub-expression id's.  If a sub-expression is added
			and there is no more room, this object will have
			to realloc and set a new value for maxExpressions.

		expressions: (id*) pointer to an array of sub-expressions.
			The length of this array is defined by the instance
			variable "maxExpressions".

	Import Files:

	"CategoryList.h":  In MONET, terminals are of the "CategoryNode"
		class.  The named object "mainCategoryList" is checked to
		ensure the existence of a selected category.

	NOTES:

	Optimizations are planned, but not yet implemented.

=============================================================================
*/

#define NO_OP	0
#define NOT_OP	1
#define OR_OP	2
#define AND_OP	3
#define XOR_OP	4

@interface BooleanExpression : NSObject
{
    int operation;

    NSMutableArray *expressions;
}

/* Init and free */
- (id)init;
- (void)dealloc;

/* Evaluate yourself.*/
- (int)evaluate:(CategoryList *)categories;

/* Access to instance variables */
- (int)operation;
- (void)setOperation:(int)newOperation;

- (void)addSubExpression:(BooleanExpression *)newExpression;
- (BooleanExpression *)operandOne;
- (BooleanExpression *)operandTwo;

/* Optimization methods.  Not yet implemented */
- (void)optimize;
- (void)optimizeSubExpressions;

/* General purpose methods */
- (int)maxExpressionLevels;
- (void)expressionString:(NSMutableString *)resultString;
- (NSString *)opString;

- (BOOL)isCategoryUsed:aCategory;

/* Archiving methods */
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
