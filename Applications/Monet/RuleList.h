
#import "MonetList.h"
#import "Rule.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/
@interface RuleList:MonetList
{
}

//- findRule:(const char *) searchSymbol;

- addRuleExp1: exp1 exp2: exp2 exp3: exp3 exp4: exp4;
- changeRuleAt: (int) index exp1: exp1 exp2: exp2 exp3: exp3 exp4: exp4;
- (void)readDegasFileFormat:(FILE *)fp;
- seedListWith: expression1 : expression2;
- findRule: categories index:(int *) index;

- (BOOL) isCategoryUsed: aCategory;
- (BOOL) isEquationUsed: anEquation;
- (BOOL) isTransitionUsed: aTransition;

- findEquation: anEquation andPutIn: aList;
- findTemplate: aTemplate andPutIn: aList;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
