#import "TargetList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "Target.h"

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the Target class.

===========================================================================*/

@implementation TargetList

- (void)addDefaultTargetWithValue:(double)newValue;
{
    Target *newTarget;

    newTarget = [[Target alloc] initWithValue:newValue isDefault:YES];
    [self addObject:newTarget];
    [newTarget release];
}

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", elementName];

    for (index = 0; index < count; index++) {
        Target *aTarget;

        aTarget = [self objectAtIndex:index];
        [aTarget appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

@end
