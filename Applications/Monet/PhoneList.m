#import "PhoneList.h"

#import <Foundation/Foundation.h>
#import "MMPosture.h"

@implementation PhoneList

- (MMPosture *)findPhone:(NSString *)phone;
{
    int count, index;
    MMPosture *aPosture;

    count = [self count];
    for (index = 0; index < count; index++) {
        aPosture = [self objectAtIndex:index];
        if ([[aPosture symbol] isEqual:phone])
            return aPosture;
    }

    return nil;
}

@end
