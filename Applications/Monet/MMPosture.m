#import "MMPosture.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMCategory.h"
#import "CategoryList.h"
#import "GSXMLFunctions.h"
#import "MMParameter.h"
#import "ParameterList.h"
#import "MMTarget.h"
#import "TargetList.h"
#import "MMSymbol.h"
#import "SymbolList.h"

#import "MModel.h"
#import "MUnarchiver.h"

@implementation MMPosture

// TODO (2004-03-19): Reject unused init method
#if 0
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

- (id)initWithSymbol:(NSString *)newSymbol parameters:(ParameterList *)parms metaParameters:(ParameterList *)metaparms symbols:(SymbolList *)symbols;
{
    int count, index;
    MMTarget *newTarget;

    if ([self init] == nil)
        return nil;

    [self setSymbol:newSymbol];

    count = [parms count];
    for (index = 0; index < count; index++) {
        newTarget = [[MMTarget alloc] initWithValue:[[parms objectAtIndex:index] defaultValue] isDefault:YES];
        [parameterList addObject:newTarget];
        [newTarget release];
    }

    count = [metaparms count];
    for (index = 0; index < count; index++) {
        newTarget = [[MMTarget alloc] initWithValue:[[metaparms objectAtIndex:index] defaultValue] isDefault:YES];
        [metaParameterList addObject:newTarget];
        [newTarget release];
    }

    count = [symbols count];
    for (index = 0; index < count; index++) {
        newTarget = [[MMTarget alloc] initWithValue:[[symbols objectAtIndex:index] defaultValue] isDefault:YES];
        [symbolList addObject:newTarget];
        [newTarget release];
    }

    return self;
}
#endif

- (id)initWithModel:(MModel *)aModel;
{
    if ([super init] == nil)
        return nil;

    phoneSymbol = nil;
    comment = nil;

    categoryList = [[CategoryList alloc] init];
    parameterList = [[TargetList alloc] init];
    metaParameterList = [[TargetList alloc] init];
    symbolList = [[TargetList alloc] init];

    nativeCategory = [[MMCategory alloc] init];
    [nativeCategory setIsNative:YES];
    [categoryList addObject:nativeCategory];

    [self setModel:aModel];
    [self _addDefaultValues];

    return self;
}

- (void)_addDefaultValues;
{
    int count, index;
    MMTarget *newTarget;
    ParameterList *mainParameters;
    SymbolList *mainSymbols;

    [self addCategory:[[self model] categoryWithName:@"phone"]];

    mainParameters = [[self model] parameters];
    count = [mainParameters count];
    for (index = 0; index < count; index++) {
        newTarget = [[MMTarget alloc] initWithValue:[[mainParameters objectAtIndex:index] defaultValue] isDefault:YES];
        [parameterList addObject:newTarget];
        [newTarget release];
    }

    mainParameters = [[self model] metaParameters];
    for (index = 0; index < count; index++) {
        newTarget = [[MMTarget alloc] initWithValue:[[mainParameters objectAtIndex:index] defaultValue] isDefault:YES];
        [metaParameterList addObject:newTarget];
        [newTarget release];
    }

    mainSymbols = [[self model] symbols];
    count = [mainSymbols count];
    for (index = 0; index < count; index++) {
        newTarget = [[MMTarget alloc] initWithValue:[[mainSymbols objectAtIndex:index] defaultValue] isDefault:YES];
        [symbolList addObject:newTarget];
        [newTarget release];
    }
}

- (void)dealloc;
{
    [phoneSymbol release];
    [comment release];

    [categoryList release];
    [parameterList release];
    [metaParameterList release];
    [symbolList release];
    [nativeCategory release];

    [super dealloc];
}

- (NSString *)symbol;
{
    return phoneSymbol;
}

// TODO (2004-03-19): Enforce unique names.
- (void)setSymbol:(NSString *)newSymbol;
{
    if (newSymbol == phoneSymbol)
        return;

    [phoneSymbol release];
    phoneSymbol = [newSymbol retain];

    [[self model] sortPostures];

    [nativeCategory setSymbol:newSymbol];
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

- (BOOL)hasComment;
{
    return comment != nil && [comment length] > 0;
}

- (CategoryList *)categoryList;
{
    return categoryList;
}

- (void)addCategory:(MMCategory *)aCategory;
{
    if (aCategory == nil)
        return;

    if ([categoryList containsObject:aCategory] == NO)
        [categoryList addObject:aCategory];
}

- (void)removeCategory:(MMCategory *)aCategory;
{
    [categoryList removeObject:aCategory];
}

- (BOOL)isMemberOfCategory:(MMCategory *)aCategory;
{
    return [categoryList containsObject:aCategory];
}

- (TargetList *)parameterTargets;
{
    return parameterList;
}

- (TargetList *)metaParameterTargets;
{
    return metaParameterList;
}

- (TargetList *)symbolList;
{
    return symbolList;
}

- (NSComparisonResult)compareByAscendingName:(MMPosture *)otherPosture;
{
    return [phoneSymbol compare:[otherPosture symbol]];
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int count, index;
    CategoryList *mainCategoryList;
    MMCategory *temp1;
    char *c_phoneSymbol, *c_comment, *c_str;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    mainCategoryList = [model categories];

    [aDecoder decodeValuesOfObjCTypes:"**", &c_phoneSymbol, &c_comment];
    //NSLog(@"c_phoneSymbol: %s, c_comment: %s", c_phoneSymbol, c_comment);

    phoneSymbol = [[NSString stringWithASCIICString:c_phoneSymbol] retain];
    comment = [[NSString stringWithASCIICString:c_comment] retain];

    parameterList = [[aDecoder decodeObject] retain];
    metaParameterList = [[aDecoder decodeObject] retain];
    symbolList = [[aDecoder decodeObject] retain];

    assert(categoryList == nil);

    [aDecoder decodeValueOfObjCType:"i" at:&count];
    //NSLog(@"TOTAL Categories for %@ = %d", phoneSymbol, count);

    categoryList = [[CategoryList alloc] initWithCapacity:count];

    nativeCategory = [[MMCategory alloc] initWithSymbol:[self symbol]];
    [nativeCategory setIsNative:YES];
    [categoryList addObject:nativeCategory];

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
    [resultString appendFormat:@"<posture symbol=\"%@\"", GSXMLAttributeString(phoneSymbol, NO)];

    if (comment == nil && [categoryList count] == 0 && [parameterList count] == 0 && [metaParameterList count] == 0 && [symbolList count] == 0) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];

        if (comment != nil) {
            [resultString indentToLevel:level + 1];
            [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];
        }

        [self _appendXMLForCategoriesToString:resultString level:level + 1];
        [self _appendXMLForParametersToString:resultString level:level + 1];
        [self _appendXMLForMetaParametersToString:resultString level:level + 1];
        [self _appendXMLForSymbolsToString:resultString level:level + 1];

        [resultString indentToLevel:level];
        [resultString appendString:@"</posture>\n"];
    }
}

- (void)_appendXMLForCategoriesToString:(NSMutableString *)resultString level:(int)level;
{
    int count, index;

    count = [categoryList count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<categories>\n"];

    for (index = 0; index < count; index++) {
        MMCategory *aCategory;

        aCategory = [categoryList objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<category name=\"%@\"/>\n", [aCategory symbol]];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</categories>\n"];
}

- (void)_appendXMLForParametersToString:(NSMutableString *)resultString level:(int)level;
{
    ParameterList *mainParameterList;
    int count, index;
    MMParameter *aParameter;
    MMTarget *aTarget;

    mainParameterList = [[self model] parameters];
    count = [mainParameterList count];
    assert(count == [parameterList count]);

    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<parameters>\n"];

    for (index = 0; index < count; index++) {
        aParameter = [mainParameterList objectAtIndex:index];
        aTarget = [parameterList objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<parameter name=\"%@\" value=\"%g\"", [aParameter symbol], [aTarget value]];
        if ([aTarget value] == [aParameter defaultValue])
            [resultString appendString:@" is-default=\"yes\""];
        [resultString appendString:@"/>\n"];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</parameters>\n"];
}

- (void)_appendXMLForMetaParametersToString:(NSMutableString *)resultString level:(int)level;
{
    ParameterList *mainMetaParameterList;
    int count, index;
    MMParameter *aParameter;
    MMTarget *aTarget;

    mainMetaParameterList = [[self model] metaParameters];
    count = [mainMetaParameterList count];
    if (count != [metaParameterList count])
        NSLog(@"%s, (%@) main meta count: %d, count: %d", _cmd, [self symbol], count, [metaParameterList count]);
    //assert(count == [metaParameterList count]);

    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<meta-parameters>\n"];

    for (index = 0; index < count; index++) {
        aParameter = [mainMetaParameterList objectAtIndex:index];
        aTarget = [metaParameterList objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<parameter name=\"%@\" value=\"%g\"", [aParameter symbol], [aTarget value]];
        if ([aTarget value] == [aParameter defaultValue])
            [resultString appendString:@" is-default=\"yes\""];
        [resultString appendString:@"/>\n"];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</meta-parameters>\n"];
}

- (void)_appendXMLForSymbolsToString:(NSMutableString *)resultString level:(int)level;
{
    SymbolList *mainSymbolList;
    int count, index;
    MMSymbol *aSymbol;
    MMTarget *aTarget;

    mainSymbolList = [[self model] symbols];
    count = [mainSymbolList count];
    assert(count == [symbolList count]);

    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<symbols>\n"];

    for (index = 0; index < count; index++) {
        aSymbol = [mainSymbolList objectAtIndex:index];
        aTarget = [symbolList objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<symbol name=\"%@\" value=\"%g\"", [aSymbol symbol], [aTarget value]];
        // "is-default" is redundant, but handy for browsing the XML file
        if ([aTarget value] == [aSymbol defaultValue])
            [resultString appendString:@" is-default=\"yes\""];
        [resultString appendString:@"/>\n"];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</symbols>\n"];
}

@end
