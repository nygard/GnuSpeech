#import "PhoneList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "AppController.h" // To get NXGetNamedObject()
#import "MMCategory.h"
#import "CategoryList.h"
#import "MMParameter.h"
#import "ParameterList.h"
#import "MMPosture.h"
#import "MMSymbol.h"
#import "SymbolList.h"
#import "MMTarget.h"
#import "TargetList.h"
#import "TRMData.h"

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
