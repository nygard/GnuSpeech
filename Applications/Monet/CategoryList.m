#import "CategoryList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "MMCategory.h"
#import "GSXMLFunctions.h"

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the MMCategory class.

===========================================================================*/

@implementation CategoryList

- (MMCategory *)findSymbol:(NSString *)searchSymbol;
{
    int count, index;
    MMCategory *aCategory;

    //NSLog(@"CategoryList searching for: %@\n", searchSymbol);

    count = [self count];
    for (index = 0; index < count; index++) {
        aCategory = [self objectAtIndex:index];
        if ([[aCategory symbol] isEqual:searchSymbol] == YES) {
            //NSLog(@"Found: %@\n", searchSymbol);
            return aCategory;
        }
    }

    //NSLog(@"Could not find: %@\n", searchSymbol);
    return nil;
}

- (MMCategory *)addCategory:(NSString *)newCategoryName;
{
    MMCategory *newCategory;

    newCategory = [[MMCategory alloc] initWithSymbol:newCategoryName];
    [self addObject:newCategory];
    [newCategory release];

    return newCategory;
}

- (void)addNativeCategory:(NSString *)newCategoryName;
{
    MMCategory *newCategory;

    newCategory = [[MMCategory alloc] initWithSymbol:newCategoryName];
    [newCategory setIsNative:YES];
    [self addObject:newCategory];
    [newCategory release];
}

#ifdef PORTING
- (void)freeNativeCategories;
{
    [self makeObjectsPerformSelector:@selector(freeIfNative)];
}
#endif

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: super: %@",
                     NSStringFromClass([self class]), self, [super description]];
}

@end
