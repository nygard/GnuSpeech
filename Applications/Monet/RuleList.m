#import "RuleList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "AppController.h"
#import "BooleanParser.h"
#import "MMRule.h"

/*===========================================================================

===========================================================================*/


@implementation RuleList

- (void)seedListWith:(BooleanExpression *)expression1:(BooleanExpression *)expression2;
{
    MMRule *aRule;

    aRule = [[MMRule alloc] init];
    [aRule setExpression:expression1 number:0];
    [aRule setExpression:expression2 number:1];
    [aRule setDefaultsTo:[aRule numberExpressions]];
    [self addObject:aRule];
    [aRule release];
}

- (void)changeRuleAt:(int)index exp1:(BooleanExpression *)exp1 exp2:(BooleanExpression *)exp2 exp3:(BooleanExpression *)exp3 exp4:(BooleanExpression *)exp4;
{
    MMRule *aRule;
    int i;

    aRule = [self objectAtIndex:index];
    i = [aRule numberExpressions];

    [aRule setExpression:exp1 number:0];
    [aRule setExpression:exp2 number:1];
    [aRule setExpression:exp3 number:2];
    [aRule setExpression:exp4 number:3];

    if (i != [aRule numberExpressions])
        [aRule setDefaultsTo:[aRule numberExpressions]];
}

- (MMRule *)findRule:(MonetList *)categories index:(int *)index;
{
    int i;

    for (i = 0; i < [self count]; i++) {
        if ([(MMRule *)[self objectAtIndex:i] numberExpressions] <= [categories count])
            if ([(MMRule *)[self objectAtIndex:i] matchRule:categories]) {
                *index = i;
                return [self objectAtIndex:i];
            }
    }

    return [self lastObject];
}



- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    int count, index;

    count = [self count];
    for (index = 0; index < count; index++) {
        if ([[self objectAtIndex:index] isCategoryUsed:aCategory])
            return YES;
    }

    return NO;
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    int count, index;

    count = [self count];
    for (index = 0; index < count; index++) {
        if ([[self objectAtIndex:index] isEquationUsed:anEquation])
            return YES;
    }

    return NO;
}

- (BOOL)isTransitionUsed:(MMTransition *)aTransition;
{
    int count, index;

    count = [self count];
    for (index = 0; index < count; index++) {
        if ([[self objectAtIndex:index] isTransitionUsed:aTransition])
            return YES;
    }

    return NO;
}

- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;
{
    int count, index;
    MMRule *aRule;

    count = [self count];
    for (index = 0; index < count; index++) {
        aRule = [self objectAtIndex:index];
        if ([aRule isEquationUsed:anEquation]) {
            [aList addObject:aRule];
            break; // TODO (2004-03-22): This doesn't seem right: It would only find the first rule, not all rules.
        }
    }
}

- (void)findTemplate:(MMTransition *)aTemplate andPutIn:(MonetList *)aList;
{
    int count, index;
    MMRule *aRule;

    count = [self count];
    for (index = 0; index < count; index++) {
        aRule = [self objectAtIndex:index];
        if ([aRule isTransitionUsed:aTemplate])
            [aList addObject:aRule];
    }
}

@end
