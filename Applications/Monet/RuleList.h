#import "MonetList.h"

@class BooleanExpression, MMCategory, MMEquation, MMTransition, MMRule;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface RuleList : MonetList
{
}

- (void)seedListWith:(BooleanExpression *)expression1:(BooleanExpression *)expression2;
- (void)addRuleExp1:(BooleanExpression *)exp1 exp2:(BooleanExpression *)exp2 exp3:(BooleanExpression *)exp3 exp4:(BooleanExpression *)exp4;
- (void)changeRuleAt:(int)index exp1:(BooleanExpression *)exp1 exp2:(BooleanExpression *)exp2 exp3:(BooleanExpression *)exp3 exp4:(BooleanExpression *)exp4;

- (MMRule *)findRule:(MonetList *)categories index:(int *)index;

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (BOOL)isTransitionUsed:(MMTransition *)aTransition;

- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;
- (void)findTemplate:(MMTransition *)aTemplate andPutIn:(MonetList *)aList;

@end
