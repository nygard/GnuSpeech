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

#import "MXMLParser.h"

#import "MXMLDictionaryDelegate.h"
#import "MXMLPCDataDelegate.h"
#import "MXMLReferenceArrayDelegate.h"

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

- (BOOL)isMemberOfCategoryNamed:(NSString *)aCategoryName;
{
    unsigned int count, index;

    count = [categoryList count];
    for (index = 0; index < count; index++) {
        if ([[[categoryList objectAtIndex:index] symbol] isEqualToString:aCategoryName] == YES)
            return YES;
    }

    return NO;
}

- (void)addCategoryWithName:(NSString *)aCategoryName;
{
    MMCategory *category;

    category = [[self model] categoryWithName:aCategoryName];
    [self addCategory:category];
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

- (void)addParameterTarget:(MMTarget *)newTarget;
{
    [parameterList addObject:newTarget];
}

- (void)removeParameterTargetAtIndex:(unsigned int)index;
{
    [parameterList removeObjectAtIndex:index];
}

- (void)addParameterTargetsFromDictionary:(NSDictionary *)aDictionary;
{
    ParameterList *parameters;
    unsigned int count, index;

    parameters = [[self model] parameters];
    count = [parameters count];
    for (index = 0; index < count; index++) {
        MMParameter *currentParameter;
        MMTarget *currentTarget;

        currentParameter = [parameters objectAtIndex:index];
        currentTarget = [aDictionary objectForKey:[currentParameter symbol]];
        if (currentTarget == nil) {
            NSLog(@"Warning: no target for parameter %@ in save file, adding default target.", [currentParameter symbol]);
            currentTarget = [[MMTarget alloc] initWithValue:[currentParameter defaultValue] isDefault:YES];
            [self addParameterTarget:currentTarget];
            [currentTarget release];
        } else {
            [self addParameterTarget:currentTarget];
        }

        // TODO (2004-04-22): Check for targets that were in the save file, but that don't have a matching parameter.
    }
}

- (void)addMetaParameterTarget:(MMTarget *)newTarget;
{
    [metaParameterList addObject:newTarget];
}

- (void)removeMetaParameterTargetAtIndex:(unsigned int)index;
{
    [metaParameterList removeObjectAtIndex:index];
}

- (void)addMetaParameterTargetsFromDictionary:(NSDictionary *)aDictionary;
{
    ParameterList *parameters;
    unsigned int count, index;

    parameters = [[self model] metaParameters];
    count = [parameters count];
    for (index = 0; index < count; index++) {
        MMParameter *currentParameter;
        MMTarget *currentTarget;

        currentParameter = [parameters objectAtIndex:index];
        currentTarget = [aDictionary objectForKey:[currentParameter symbol]];
        if (currentTarget == nil) {
            NSLog(@"Warning: no target for meta-parameter %@ in save file, adding default target.", [currentParameter symbol]);
            currentTarget = [[MMTarget alloc] initWithValue:[currentParameter defaultValue] isDefault:YES];
            [self addMetaParameterTarget:currentTarget];
            [currentTarget release];
        } else {
            [self addMetaParameterTarget:currentTarget];
        }

        // TODO (2004-04-22): Check for targets that were in the save file, but that don't have a matching parameter.
    }
}

- (void)addSymbolTarget:(MMTarget *)newTarget;
{
    [symbolList addObject:newTarget];
}

- (void)removeSymbolTargetAtIndex:(unsigned int)index;
{
    [symbolList removeObjectAtIndex:index];
}

- (void)addSymbolTargetsFromDictionary:(NSDictionary *)aDictionary;
{
    SymbolList *symbols;
    unsigned int count, index;

    symbols = [[self model] symbols];
    count = [symbols count];
    for (index = 0; index < count; index++) {
        MMSymbol *currentSymbol;
        MMTarget *currentTarget;

        currentSymbol = [symbols objectAtIndex:index];
        currentTarget = [aDictionary objectForKey:[currentSymbol symbol]];
        if (currentTarget == nil) {
            NSLog(@"Warning: no target for symbol %@ in save file, adding default target.", [currentSymbol symbol]);
            currentTarget = [[MMTarget alloc] initWithValue:[currentSymbol defaultValue] isDefault:YES];
            [self addSymbolTarget:currentTarget];
            [currentTarget release];
        } else {
            [self addSymbolTarget:currentTarget];
        }

        // TODO (2004-04-22): Check for targets that were in the save file, but that don't have a matching symbol.
    }
}

- (MMTarget *)targetForSymbol:(MMSymbol *)aSymbol;
{
    int symbolIndex;

    assert([self model] != nil);
    symbolIndex = [[[self model] symbols] indexOfObject:aSymbol];
    if (symbolIndex == NSNotFound)
        NSLog(@"Warning: Couldn't find symbol %@ in posture %@", [aSymbol symbol], phoneSymbol);

    return [symbolList objectAtIndex:symbolIndex];
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
    [resultString appendString:@"<posture-categories>\n"];

    for (index = 0; index < count; index++) {
        MMCategory *aCategory;

        aCategory = [categoryList objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<category-ref name=\"%@\"/>\n", [aCategory symbol]];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</posture-categories>\n"];
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
    [resultString appendFormat:@"<parameter-targets>\n"];

    for (index = 0; index < count; index++) {
        aParameter = [mainParameterList objectAtIndex:index];
        aTarget = [parameterList objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<target name=\"%@\" value=\"%g\"", [aParameter symbol], [aTarget value]];
        if ([aTarget value] == [aParameter defaultValue])
            [resultString appendString:@" is-default=\"yes\""];
        [resultString appendString:@"/>\n"];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</parameter-targets>\n"];
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
    [resultString appendFormat:@"<meta-parameter-targets>\n"];

    for (index = 0; index < count; index++) {
        aParameter = [mainMetaParameterList objectAtIndex:index];
        aTarget = [metaParameterList objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<target name=\"%@\" value=\"%g\"", [aParameter symbol], [aTarget value]];
        if ([aTarget value] == [aParameter defaultValue])
            [resultString appendString:@" is-default=\"yes\""];
        [resultString appendString:@"/>\n"];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</meta-parameter-targets>\n"];
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
    [resultString appendFormat:@"<symbol-targets>\n"];

    for (index = 0; index < count; index++) {
        aSymbol = [mainSymbolList objectAtIndex:index];
        aTarget = [symbolList objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<target name=\"%@\" value=\"%g\"", [aSymbol symbol], [aTarget value]];
        // "is-default" is redundant, but handy for browsing the XML file
        if ([aTarget value] == [aSymbol defaultValue])
            [resultString appendString:@" is-default=\"yes\""];
        [resultString appendString:@"/>\n"];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</symbol-targets>\n"];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes;
{
    if ([self initWithModel:nil] == nil)
        return nil;

    [self setSymbol:[attributes objectForKey:@"symbol"]];

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"comment"]) {
        MXMLPCDataDelegate *newDelegate;

        newDelegate = [[MXMLPCDataDelegate alloc] initWithElementName:elementName delegate:self setSelector:@selector(setComment:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"posture-categories"]) {
        MXMLReferenceArrayDelegate *newDelegate;

        newDelegate = [[MXMLReferenceArrayDelegate alloc] initWithChildElementName:@"category-ref" referenceAttribute:@"name" delegate:self addObjectSelector:@selector(addCategoryWithName:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"parameter-targets"]) {
        MXMLDictionaryDelegate *newDelegate;

        newDelegate = [[MXMLDictionaryDelegate alloc] initWithChildElementName:@"target" class:[MMTarget class] keyAttributeName:@"name" delegate:self addObjectsSelector:@selector(addParameterTargetsFromDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"meta-parameter-targets"]) {
        MXMLDictionaryDelegate *newDelegate;

        newDelegate = [[MXMLDictionaryDelegate alloc] initWithChildElementName:@"target" class:[MMTarget class] keyAttributeName:@"name" delegate:self addObjectsSelector:@selector(addMetaParameterTargetsFromDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"symbol-targets"]) {
        MXMLDictionaryDelegate *newDelegate;

        newDelegate = [[MXMLDictionaryDelegate alloc] initWithChildElementName:@"target" class:[MMTarget class] keyAttributeName:@"name" delegate:self addObjectsSelector:@selector(addSymbolTargetsFromDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else {
        NSLog(@"Warning: %@, Unknown element: '%@', skipping", [self shortDescription], elementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"posture"])
        [(MXMLParser *)parser popDelegate];
    else
        [NSException raise:@"Unknown close tag" format:@"Unknown closing tag (%@) in %@", elementName, NSStringFromClass([self class])];
}

@end
