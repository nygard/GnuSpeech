#import "RuleList.h"

#import <Foundation/Foundation.h>
#import "MMRule.h"

@implementation RuleList

// categories is a list of lists of categories
- (MMRule *)findRule:(MonetList *)categories index:(int *)indexPtr;
{
    unsigned int count, index;

    count = [self count];
    assert(count > 0);
    for (index = 0; index < count; index++) {
        MMRule *rule;

        rule = [self objectAtIndex:index];
        if ([rule numberExpressions] <= [categories count])
            if ([rule matchRule:categories]) {
                if (indexPtr != NULL)
                    *indexPtr = index;
                return rule;
            }
    }

    // This assumes that the last object will always be the "phone >> phone" rule, but that should have been matched above.
    // TODO (2004-08-01): But what if there are no rules?
    if (indexPtr != NULL)
        *indexPtr = count - 1;
    return [self lastObject];
}

@end
