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
    int i, count;

    MMCategory *currentNode;
    char tempString[SYMBOL_LENGTH_MAX+1];
    NSString *str;

    /* Load in the count */
    fread(&count, sizeof(int), 1, fp);

    for (i = 0; i < count; i++) {
        fread(tempString, SYMBOL_LENGTH_MAX+1, 1, fp);

        str = [NSString stringWithASCIICString:tempString];
        currentNode = [[MMCategory alloc] initWithSymbol:str];
        [self addObject:currentNode];
    }

    if (![self findSymbol:@"phone"])
        [self addCategory:@"phone"];
}

- (void)printDataTo:(FILE *)fp;
{
    int i;

    fprintf(fp, "Categories\n");
    for (i = 0; i < [self count]; i++) {
        fprintf(fp, "%s\n", [[[self objectAtIndex:i] symbol] UTF8String]);
        if ([[self objectAtIndex:i] comment])
            fprintf(fp, "%s\n", [[[self objectAtIndex:i] comment] UTF8String]);
        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: super: %@",
                     NSStringFromClass([self class]), self, [super description]];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level useReferences:(BOOL)shouldUseReferences;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<categories>\n"];

    for (index = 0; index < count; index++) {
        MMCategory *aCategory;

        aCategory = [self objectAtIndex:index];
        [aCategory appendXMLToString:resultString level:level+1 useReferences:shouldUseReferences];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</categories>\n"];
}

@end
