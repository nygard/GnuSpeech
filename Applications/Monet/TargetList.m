#import "TargetList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMTarget.h"

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the Target class.

===========================================================================*/

@implementation TargetList

- (void)addDefaultTargetWithValue:(double)newValue;
{
    MMTarget *newTarget;

    newTarget = [[MMTarget alloc] initWithValue:newValue isDefault:YES];
    [self addObject:newTarget];
    [newTarget release];
}

@end
