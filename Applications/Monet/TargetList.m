
#import "TargetList.h"

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the Target class.

===========================================================================*/

@implementation TargetList

- (void)addDefaultTargetWithValue:(double)newValue
{
Target *tempTarget;

	tempTarget = [[Target alloc] initWithValue: newValue isDefault:YES];
	[self addObject:tempTarget]; 
}


@end
