#import "RuleList.h"

#import <Foundation/Foundation.h>
#import "MMRule.h"

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

@end
