#import "MonetList.h"

@class BooleanExpression, CategoryNode, ProtoEquation, ProtoTemplate, Rule;

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

- (Rule *)findRule:(MonetList *)categories index:(int *)index;
- (void)readDegasFileFormat:(FILE *)fp;

- (BOOL)isCategoryUsed:(CategoryNode *)aCategory;
- (BOOL)isEquationUsed:(ProtoEquation *)anEquation;
- (BOOL)isTransitionUsed:(ProtoTemplate *)aTransition;

- (void)findEquation:(ProtoEquation *)anEquation andPutIn:(MonetList *)aList;
- (void)findTemplate:(ProtoTemplate *)aTemplate andPutIn:(MonetList *)aList;

@end
