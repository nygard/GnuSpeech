#import "ParameterList.h"

#import <Foundation/Foundation.h>
#import "MMParameter.h"

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the Phone class.

===========================================================================*/

@implementation ParameterList

- (MMParameter *)findParameter:(NSString *)symbol;
{
    int count, index;
    MMParameter *aParameter;

    count = [self count];
    for (index = 0; index < count; index++) {
        aParameter = [self objectAtIndex:index];
        if ([[aParameter symbol] isEqual:symbol] == YES)
            return aParameter;
    }

    return nil;
}

@end
