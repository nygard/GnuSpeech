#import "SymbolList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMSymbol.h"

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the MMCategory class.

===========================================================================*/

@implementation SymbolList

- (MMSymbol *)findSymbol:(NSString *)searchSymbol;
{
    int count, index;

    count = [self count];
    for (index = 0; index < count; index++) {
        MMSymbol *aSymbol;

        aSymbol = [self objectAtIndex:index];
        if ([[aSymbol symbol] isEqual:searchSymbol] == YES)
            return aSymbol;
    }

    return nil;
}

@end
