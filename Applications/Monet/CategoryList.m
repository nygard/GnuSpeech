#import "CategoryList.h"

#import "CategoryNode.h"

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the CategoryNode class.

===========================================================================*/

@implementation CategoryList

- (CategoryNode *)findSymbol:(NSString *)searchSymbol;
{
    int count, index;
    CategoryNode *aCategory;

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

- (CategoryNode *)addCategory:(NSString *)newCategoryName;
{
    CategoryNode *newCategory;

    newCategory = [[CategoryNode alloc] initWithSymbol:newCategoryName];
    [self addObject:newCategory];
    [newCategory release];

    return newCategory;
}

- (void)addNativeCategory:(NSString *)newCategoryName;
{
    CategoryNode *newCategory;

    newCategory = [[CategoryNode alloc] initWithSymbol:newCategoryName];
    [newCategory setIsNative:YES];
    [self addObject:newCategory];
    [newCategory release];
}

#ifdef PORTING
- (void)freeNativeCategories;
{
    [self makeObjectsPerform:@selector(freeIfNative)];
}
#endif

//
// BrowserManager List delegate Methods
//

- (void)addNewValue:(NSString *)newValue;
{
    [self addCategory:newValue];
}

- (id)findByName:(NSString *)name;
{
    return [self findSymbol:name];
}

- (void)changeSymbolOf:(id)temp to:(NSString *)name;
{
    [temp setSymbol:name];
}

#define SYMBOL_LENGTH_MAX 12
- (void)readDegasFileFormat:(FILE *)fp;
{
#warning Not yet ported
#ifdef PORTING
    int i, count;

    CategoryNode *currentNode;
    char tempString[SYMBOL_LENGTH_MAX+1];

    /* Load in the count */
    fread(&count, sizeof(int), 1, fp);

    for (i = 0; i < count; i++) {
        fread(tempString, SYMBOL_LENGTH_MAX+1, 1, fp);

        currentNode = [[CategoryNode alloc] initWithSymbol:tempString];
        [self addObject:currentNode];
    }

    if (![self findSymbol:"phone"])
        [self addCategory:"phone"];
#endif
}

- (void)printDataTo:(FILE *)fp;
{
#warning Not yet ported
#ifdef PORTING
    int i;

    fprintf(fp, "Categories\n");
    for (i = 0; i < [self count]; i++) {
        fprintf(fp, "%s\n", [[self objectAtIndex:i] symbol]);
        if ([[self objectAtIndex:i] comment])
            fprintf(fp, "%s\n", [[self objectAtIndex:i] comment]);
        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");
#endif
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: super: %@",
                     NSStringFromClass([self class]), self, [super description]];
}

@end
