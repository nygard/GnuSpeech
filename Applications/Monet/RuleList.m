#import "RuleList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "AppController.h"
#import "BooleanParser.h"
#import "MMRule.h"

/*===========================================================================

===========================================================================*/


@implementation RuleList

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
