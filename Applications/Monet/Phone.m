#import "Phone.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "AppController.h"
#import "CategoryNode.h"
#import "CategoryList.h"
#import "GSXMLFunctions.h"
#import "Parameter.h"
#import "ParameterList.h"
#import "Target.h"
#import "TargetList.h"
#import "SymbolList.h"

@implementation Phone

- (id)init;
{
    if ([super init] == nil)
        return nil;

    phoneSymbol = nil;
    comment = nil;

    categoryList = [[CategoryList alloc] initWithCapacity:15];
    parameterList = [[TargetList alloc] initWithCapacity:15];
    metaParameterList = [[TargetList alloc] initWithCapacity:15];
    symbolList = [[TargetList alloc] initWithCapacity:15];

    return self;
}

- (id)initWithSymbol:(NSString *)newSymbol;
{
    if ([self init] == nil)
        return nil;

    [self setSymbol:newSymbol];

    return self;
}

- (id)initWithSymbol:(NSString *)newSymbol parmeters:(ParameterList *)parms metaParameters:(ParameterList *)metaparms symbols:(SymbolList *)symbols;
{
    int count, index;
    Target *newTarget;

    if ([self init] == nil)
        return nil;

    [self setSymbol:newSymbol];

    count = [parms count];
    for (index = 0; index < count; index++) {
        newTarget = [[Target alloc] initWithValue:[[parms objectAtIndex:index] defaultValue] isDefault:YES];
        [parameterList addObject:newTarget];
        [newTarget release];
    }

    count = [metaparms count];
    for (index = 0; index < count; index++) {
        newTarget = [[Target alloc] initWithValue:[[metaparms objectAtIndex:index] defaultValue] isDefault:YES];
        [metaParameterList addObject:newTarget];
        [newTarget release];
    }

    count = [symbols count];
    for (index = 0; index < count; index++) {
        newTarget = [[Target alloc] initWithValue:[[symbols objectAtIndex:index] defaultValue] isDefault:YES];
        [symbolList addObject:newTarget];
        [newTarget release];
    }

    return self;
}

- (void)dealloc;
{
    [phoneSymbol release];
    [comment release];

    [categoryList release];
    [parameterList release];
    [metaParameterList release];
    [symbolList release];

    [super dealloc];
}

- (NSString *)symbol;
{
    return phoneSymbol;
}

- (void)setSymbol:(NSString *)newSymbol;
{
    int count, index;

    if (newSymbol == phoneSymbol)
        return;

    [phoneSymbol release];
    phoneSymbol = [newSymbol retain];

    count = [categoryList count];
    for (index = 0; index < count; index++) {
        CategoryNode *aCategory;

        aCategory = [categoryList objectAtIndex:index];
        if ([aCategory isNative]) {
            [aCategory setSymbol:newSymbol];
            return;
        }
    }
}

- (NSString *)comment;
{
    return comment;
}

- (void)setComment:(NSString *)newComment;
{
    if (newComment == comment)
        return;

    [comment release];
    comment = [newComment retain];
}

- (CategoryList *)categoryList;
{
    return categoryList;
}

- (void)addToCategoryList:(CategoryNode *)aCategory;
{
}

- (TargetList *)parameterList;
{
    return parameterList;
}

- (TargetList *)metaParameterList;
{
    return metaParameterList;
}

- (TargetList *)symbolList;
{
    return symbolList;
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int count, index;
    CategoryList *mainCategoryList;
    CategoryNode *temp1;
    char *c_phoneSymbol, *c_comment, *c_str;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    mainCategoryList = NXGetNamedObject(@"mainCategoryList", NSApp);

    [aDecoder decodeValuesOfObjCTypes:"**", &c_phoneSymbol, &c_comment];
    //NSLog(@"c_phoneSymbol: %s, c_comment: %s", c_phoneSymbol, c_comment);

    phoneSymbol = [[NSString stringWithASCIICString:c_phoneSymbol] retain];
    comment = [[NSString stringWithASCIICString:c_comment] retain];

    parameterList = [[aDecoder decodeObject] retain];
    metaParameterList = [[aDecoder decodeObject] retain];
    symbolList = [[aDecoder decodeObject] retain];

    assert(categoryList == nil);

    [aDecoder decodeValueOfObjCType:"i" at:&count];
    NSLog(@"TOTAL Categories for %@ = %d", phoneSymbol, count);

    categoryList = [[CategoryList alloc] initWithCapacity:count];

    for (index = 0; index < count; index++) {
        NSString *str;

        [aDecoder decodeValueOfObjCType:"*" at:&c_str];
        //NSLog(@"%d: c_str: %s", index, c_str);
        str = [NSString stringWithASCIICString:c_str];

        temp1 = [mainCategoryList findSymbol:str];
        if (temp1) {
            //NSLog(@"Read category: %@", str);
            [categoryList addObject:temp1];
        } else {
            //NSLog(@"Read NATIVE category: %@", str);
            if ([phoneSymbol isEqual:str] == NO) {
                NSLog(@"NATIVE Category Wrong... correcting: %@ -> %@", str, phoneSymbol);
                [categoryList addNativeCategory:phoneSymbol];
            } else
                [categoryList addNativeCategory:str];
        }
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
#ifdef PORTING
    int i;
    const char *temp;

//	printf("\tSaving %s\n", phoneSymbol);
    [aCoder encodeValuesOfObjCTypes:"**", &phoneSymbol, &comment];

//	printf("\tSaving parameter, meta, and symbolList\n", phoneSymbol);
    [aCoder encodeObject:parameterList];
    [aCoder encodeObject:metaParameterList];
    [aCoder encodeObject:symbolList];

//	printf("\tSaving categoryList\n", phoneSymbol);
    /* Here's the tricky one! */
    i = [categoryList count];

    [aCoder encodeValueOfObjCType:"i" at:&i];
    for(i = 0; i<[categoryList count]; i++)
    {
        temp = [[categoryList objectAtIndex:i] symbol];
        [aCoder encodeValueOfObjCType:"*" at:&temp];
    }
#endif
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: phoneSymbol: %@, comment: %@, categoryList: %@, parameterList: %@, metaParameterList: %@, symbolList: %@",
                     NSStringFromClass([self class]), self, phoneSymbol, comment, categoryList, parameterList, metaParameterList, symbolList];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<phone ptr=\"%p\" symbol=\"%@\"", self, GSXMLAttributeString(phoneSymbol, NO)];

    if (comment == nil && [categoryList count] == 0 && [parameterList count] == 0 && [metaParameterList count] == 0 && [symbolList count] == 0) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];

        if (comment != nil) {
            [resultString indentToLevel:level + 1];
            [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];
        }

        [categoryList appendXMLToString:resultString level:level + 1 useReferences:YES];
        [parameterList appendXMLToString:resultString elementName:@"parameters" level:level + 1];
        [metaParameterList appendXMLToString:resultString elementName:@"meta-parameters" level:level + 1];
        [symbolList appendXMLToString:resultString elementName:@"symbols" level:level + 1];

        [resultString indentToLevel:level];
        [resultString appendString:@"</phone>\n"];
    }
}

@end
