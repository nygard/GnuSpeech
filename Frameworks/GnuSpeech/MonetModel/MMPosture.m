//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMPosture.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMCategory.h"
#import "GSXMLFunctions.h"
#import "MMParameter.h"
#import "MMTarget.h"
#import "MMSymbol.h"

#import "MModel.h"

#import "MXMLParser.h"

#import "MXMLDictionaryDelegate.h"
#import "MXMLPCDataDelegate.h"
#import "MXMLReferenceArrayDelegate.h"

@interface MMPosture ()
- (void)_addDefaultValues;
- (void)addParameterTargetsFromDictionary:(NSDictionary *)dictionary;
- (void)addMetaParameterTargetsFromDictionary:(NSDictionary *)dictionary;
- (void)addSymbolTargetsFromDictionary:(NSDictionary *)dictionary;
- (void)_appendXMLForCategoriesToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForParametersToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForMetaParametersToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForSymbolsToString:(NSMutableString *)resultString level:(NSUInteger)level;
@end

#pragma mark -

@implementation MMPosture
{
    NSMutableArray *m_categories;           // Of MMCategorys (member of these categories)
    NSMutableArray *m_parameterTargets;     // Of Targets
    NSMutableArray *m_metaParameterTargets; // Of Targets
    NSMutableArray *m_symbolTargets;        // Of Targets (symbol definitions)
    
    MMCategory *m_nativeCategory;
}

// This is now used from -[MMNamedObject initWithXMLAttributes:context:]
- (id)init;
{
    return [self initWithModel:nil];
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super init])) {
        m_categories           = [[NSMutableArray alloc] init];
        m_parameterTargets     = [[NSMutableArray alloc] init];
        m_metaParameterTargets = [[NSMutableArray alloc] init];
        m_symbolTargets        = [[NSMutableArray alloc] init];
        
        m_nativeCategory = [[MMCategory alloc] init];
        [m_nativeCategory setIsNative:YES];
        [m_categories addObject:m_nativeCategory];
        
        self.model = model;
        [self _addDefaultValues];
    }

    return self;
}

- (void)_addDefaultValues;
{
    NSUInteger count, index;
    NSArray *mainParameters;

    [self addCategory:[self.model categoryWithName:@"phone"]];

    mainParameters = [self.model parameters];
    count = [mainParameters count];
    for (index = 0; index < count; index++) {
        MMTarget *newTarget = [[MMTarget alloc] initWithValue:[(MMParameter *)[mainParameters objectAtIndex:index] defaultValue] isDefault:YES];
        [self.parameterTargets addObject:newTarget];
        [newTarget release];
    }

    mainParameters = [self.model metaParameters];
    count = [mainParameters count];
    for (index = 0; index < count; index++) {
        MMTarget *newTarget = [[MMTarget alloc] initWithValue:[(MMParameter *)[mainParameters objectAtIndex:index] defaultValue] isDefault:YES];
        [self.metaParameterTargets addObject:newTarget];
        [newTarget release];
    }

    NSArray *mainSymbols = [self.model symbols];
    count = [mainSymbols count];
    for (index = 0; index < count; index++) {
        MMTarget *newTarget = [[MMTarget alloc] initWithValue:[(MMSymbol *)[mainSymbols objectAtIndex:index] defaultValue] isDefault:YES];
        [self.symbolTargets addObject:newTarget];
        [newTarget release];
    }
}

- (void)dealloc;
{
    [m_categories release];
    [m_parameterTargets release];
    [m_metaParameterTargets release];
    [m_symbolTargets release];
    [m_nativeCategory release];

    [super dealloc];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@, categories: %@, parameterTargets: %@, metaParameterTargets: %@, symbolTargets: %@",
            NSStringFromClass([self class]), self,
            self.name, self.comment, self.categories, self.parameterTargets, self.metaParameterTargets, self.symbolTargets];
}

#pragma mark -

// TODO (2004-03-19): Enforce unique names.
- (void)setName:(NSString *)newName;
{
    [super setName:newName];
    [self.model sortPostures];
    [self.nativeCategory setName:newName];
}

#pragma mark - Categories

@synthesize nativeCategory = m_nativeCategory;
@synthesize categories = m_categories;

- (void)addCategory:(MMCategory *)category;
{
    if (category == nil)
        return;

    if ([self.categories containsObject:category] == NO)
        [self.categories addObject:category];
}

- (void)removeCategory:(MMCategory *)category;
{
    [self.categories removeObject:category];
}

- (BOOL)isMemberOfCategory:(MMCategory *)category;
{
    return [self.categories containsObject:category];
}

- (BOOL)isMemberOfCategoryNamed:(NSString *)name;
{
    NSUInteger count, index;

    count = [self.categories count];
    for (index = 0; index < count; index++) {
        if ([[(MMNamedObject *)[self.categories objectAtIndex:index] name] isEqualToString:name])
            return YES;
    }

    return NO;
}

- (void)addCategoryWithName:(NSString *)name;
{
    MMCategory *category = [self.model categoryWithName:name];
    [self addCategory:category];
}

#pragma mark - Parameter Targets

@synthesize parameterTargets = m_parameterTargets;

- (void)addParameterTarget:(MMTarget *)target;
{
    [self.parameterTargets addObject:target];
}

- (void)removeParameterTargetAtIndex:(NSUInteger)index;
{
    [self.parameterTargets removeObjectAtIndex:index];
}

- (void)addParameterTargetsFromDictionary:(NSDictionary *)dictionary;
{
    NSUInteger count, index;

    NSArray *parameters = [self.model parameters];
    count = [parameters count];
    for (index = 0; index < count; index++) {
        MMParameter *currentParameter = [parameters objectAtIndex:index];
        MMTarget *currentTarget = [dictionary objectForKey:[currentParameter name]];
        if (currentTarget == nil) {
            NSLog(@"Warning: no target for parameter %@ in save file, adding default target.", [currentParameter name]);
            currentTarget = [[MMTarget alloc] initWithValue:[currentParameter defaultValue] isDefault:YES];
            [self addParameterTarget:currentTarget];
            [currentTarget release];
        } else {
            [self addParameterTarget:currentTarget];
        }

        // TODO (2004-04-22): Check for targets that were in the save file, but that don't have a matching parameter.
    }
}

#pragma mark - Meta-parameter Targets

@synthesize metaParameterTargets = m_metaParameterTargets;

- (void)addMetaParameterTarget:(MMTarget *)target;
{
    [self.metaParameterTargets addObject:target];
}

- (void)removeMetaParameterTargetAtIndex:(NSUInteger)index;
{
    [self.metaParameterTargets removeObjectAtIndex:index];
}

- (void)addMetaParameterTargetsFromDictionary:(NSDictionary *)dictionary;
{
    NSUInteger count, index;

    NSArray *parameters = [self.model metaParameters];
    count = [parameters count];
    for (index = 0; index < count; index++) {
        MMParameter *currentParameter = [parameters objectAtIndex:index];
        MMTarget *currentTarget = [dictionary objectForKey:[currentParameter name]];
        if (currentTarget == nil) {
            NSLog(@"Warning: no target for meta-parameter %@ in save file, adding default target.", [currentParameter name]);
            currentTarget = [[MMTarget alloc] initWithValue:[currentParameter defaultValue] isDefault:YES];
            [self addMetaParameterTarget:currentTarget];
            [currentTarget release];
        } else {
            [self addMetaParameterTarget:currentTarget];
        }

        // TODO (2004-04-22): Check for targets that were in the save file, but that don't have a matching parameter.
    }
}

#pragma mark - Symbol Targets

@synthesize symbolTargets = m_symbolTargets;

- (void)addSymbolTarget:(MMTarget *)target;
{
    [self.symbolTargets addObject:target];
}

- (void)removeSymbolTargetAtIndex:(NSUInteger)index;
{
    [self.symbolTargets removeObjectAtIndex:index];
}

- (void)addSymbolTargetsFromDictionary:(NSDictionary *)dictionary;
{
    NSUInteger count, index;

    NSArray *symbols = [self.model symbols];
    count = [symbols count];
    for (index = 0; index < count; index++) {
        MMSymbol *currentSymbol = [symbols objectAtIndex:index];
        MMTarget *currentTarget = [dictionary objectForKey:[currentSymbol name]];
        if (currentTarget == nil) {
            NSLog(@"Warning: no target for symbol %@ in save file, adding default target.", [currentSymbol name]);
            currentTarget = [[MMTarget alloc] initWithValue:[currentSymbol defaultValue] isDefault:YES];
            [self addSymbolTarget:currentTarget];
            [currentTarget release];
        } else {
            [self addSymbolTarget:currentTarget];
        }

        // TODO (2004-04-22): Check for targets that were in the save file, but that don't have a matching symbol.
    }
}

- (MMTarget *)targetForSymbol:(MMSymbol *)symbol;
{
    NSParameterAssert(self.model != nil);
    NSUInteger symbolIndex = [[self.model symbols] indexOfObject:symbol];
    if (symbolIndex == NSNotFound)
        NSLog(@"Warning: Couldn't find symbol %@ in posture %@", [symbol name], self.name);

    return [self.symbolTargets objectAtIndex:symbolIndex];
}

#pragma mark - Sorting

- (NSComparisonResult)compareByAscendingName:(MMPosture *)other;
{
    return [self.name compare:other.name];
}

#pragma mark - XML Archiving

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<posture symbol=\"%@\"", GSXMLAttributeString(self.name, NO)];

    if (self.comment == nil && [self.categories count] == 0 && [self.parameterTargets count] == 0 && [self.metaParameterTargets count] == 0 && [self.symbolTargets count] == 0) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];

        if (self.comment != nil) {
            [resultString indentToLevel:level + 1];
            [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(self.comment)];
        }

        [self _appendXMLForCategoriesToString:resultString level:level + 1];
        [self _appendXMLForParametersToString:resultString level:level + 1];
        [self _appendXMLForMetaParametersToString:resultString level:level + 1];
        [self _appendXMLForSymbolsToString:resultString level:level + 1];

        [resultString indentToLevel:level];
        [resultString appendString:@"</posture>\n"];
    }
}

- (void)_appendXMLForCategoriesToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger count, index;

    count = [self.categories count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<posture-categories>\n"];

    for (index = 0; index < count; index++) {
        MMCategory *category = [self.categories objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<category-ref name=\"%@\"/>\n", [category name]];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</posture-categories>\n"];
}

- (void)_appendXMLForParametersToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger count, index;

    NSArray *mainParameterList = [self.model parameters];
    count = [mainParameterList count];
    assert(count == [self.parameterTargets count]);

    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<parameter-targets>\n"];

    for (index = 0; index < count; index++) {
        MMParameter *parameter = [mainParameterList objectAtIndex:index];
        MMTarget *target = [self.parameterTargets objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<target name=\"%@\" value=\"%g\"/>", [parameter name], [target value]];
        if ([target value] == [parameter defaultValue])
            [resultString appendString:@"<!-- default -->"];
        [resultString appendString:@"\n"];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</parameter-targets>\n"];
}

- (void)_appendXMLForMetaParametersToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger count, index;

    NSArray *mainMetaParameterList = [self.model metaParameters];
    count = [mainMetaParameterList count];
    if (count != [self.metaParameterTargets count])
        NSLog(@"%s, (%@) main meta count: %lu, count: %lu", __PRETTY_FUNCTION__, self.name, count, [self.metaParameterTargets count]);
    //assert(count == [metaParameterTargets count]);

    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<meta-parameter-targets>\n"];

    for (index = 0; index < count; index++) {
        MMParameter *parameter = [mainMetaParameterList objectAtIndex:index];
        MMTarget *target = [self.metaParameterTargets objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<target name=\"%@\" value=\"%g\"/>", [parameter name], [target value]];
        if ([target value] == [parameter defaultValue])
            [resultString appendString:@"<!-- default -->"];
        [resultString appendString:@"\n"];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</meta-parameter-targets>\n"];
}

- (void)_appendXMLForSymbolsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger count, index;

    NSArray *mainSymbolList = [self.model symbols];
    count = [mainSymbolList count];
    assert(count == [self.symbolTargets count]);

    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<symbol-targets>\n"];

    for (index = 0; index < count; index++) {
        MMSymbol *symbol = [mainSymbolList objectAtIndex:index];
        MMTarget *target = [self.symbolTargets objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<target name=\"%@\" value=\"%g\"/>", [symbol name], [target value]];
        if ([target value] == [symbol defaultValue])
            [resultString appendString:@"<!-- default -->"];
        [resultString appendString:@"\n"];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</symbol-targets>\n"];
}

// TODO (2004-08-12): Rename attribute name from "symbol" to "name", so we can use the superclass implementation of this method.  Do this after we start supporting upgrading from previous versions.
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    if ((self = [self initWithModel:nil])) {
        self.name = [attributes objectForKey:@"symbol"];
    }

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"posture-categories"]) {
        MXMLReferenceArrayDelegate *newDelegate = [[MXMLReferenceArrayDelegate alloc] initWithChildElementName:@"category-ref" referenceAttribute:@"name" delegate:self addObjectSelector:@selector(addCategoryWithName:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"parameter-targets"]) {
        MXMLDictionaryDelegate *newDelegate = [[MXMLDictionaryDelegate alloc] initWithChildElementName:@"target" class:[MMTarget class] keyAttributeName:@"name" delegate:self addObjectsSelector:@selector(addParameterTargetsFromDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"meta-parameter-targets"]) {
        MXMLDictionaryDelegate *newDelegate = [[MXMLDictionaryDelegate alloc] initWithChildElementName:@"target" class:[MMTarget class] keyAttributeName:@"name" delegate:self addObjectsSelector:@selector(addMetaParameterTargetsFromDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"symbol-targets"]) {
        MXMLDictionaryDelegate *newDelegate = [[MXMLDictionaryDelegate alloc] initWithChildElementName:@"target" class:[MMTarget class] keyAttributeName:@"name" delegate:self addObjectsSelector:@selector(addSymbolTargetsFromDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else {
        [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
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
