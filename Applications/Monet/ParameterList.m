#import "ParameterList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import <string.h>
#import "GSXMLFunctions.h"
#import "MMParameter.h"

#define DEFAULT_MIN	100.0
#define DEFAULT_MAX	1000.0

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

- (int)findParameterIndex:(NSString *)symbol;
{
    int count, index;
    MMParameter *aParameter;

    count = [self count];
    for (index = 0; index < count; index++) {
        aParameter = [self objectAtIndex:index];
        if ([[aParameter symbol] isEqual:symbol] == YES)
            return index;
    }

    return -1;
}

/* BrowserManager List delegate Methods */

- (id)findByName:(NSString *)name;
{
    return [self findParameter:name];
}

- (void)changeSymbolOf:(id)temp to:(NSString *)name;
{
    [temp setSymbol:name];
}


@end
