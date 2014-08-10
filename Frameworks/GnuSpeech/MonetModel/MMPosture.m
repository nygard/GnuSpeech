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

@interface MMPosture ()
@end

#pragma mark -

@implementation MMPosture
{
    NSMutableArray *_categories;           // Of MMCategorys (member of these categories)
    NSMutableArray *_parameterTargets;     // Of Targets
    NSMutableArray *_metaParameterTargets; // Of Targets
    NSMutableArray *_symbolTargets;        // Of Targets (symbol definitions)
    
    MMCategory *_nativeCategory;
}

- (id)init;
{
    return [self initWithModel:nil];
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super init])) {
        _categories           = [[NSMutableArray alloc] init];
        _parameterTargets     = [[NSMutableArray alloc] init];
        _metaParameterTargets = [[NSMutableArray alloc] init];
        _symbolTargets        = [[NSMutableArray alloc] init];
        
        _nativeCategory = [[MMCategory alloc] init];
        [_nativeCategory setIsNative:YES];
        [_categories addObject:_nativeCategory];
        
        self.model = model;
        [self _addDefaultValues];
    }

    return self;
}

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"posture" isEqualToString:element.name]);

    if ((self = [super initWithXMLElement:element error:error])) {
        _categories           = [[NSMutableArray alloc] init];
        _parameterTargets     = [[NSMutableArray alloc] init];
        _metaParameterTargets = [[NSMutableArray alloc] init];
        _symbolTargets        = [[NSMutableArray alloc] init];

        _nativeCategory = [[MMCategory alloc] init];
        [_nativeCategory setIsNative:YES];
        [_categories addObject:_nativeCategory];

        self.model = model;
//        [self _addDefaultValues]; // This needs a model.  But we don't need to add defaults, since we're loading.

        // TODO (2004-08-12): Rename attribute name from "symbol" to "name", so we can use the superclass implementation of this method.  Do this after we start supporting upgrading from previous versions.
        self.name = [[element attributeForName:@"symbol"] stringValue];

        if (![self _loadPostureCategoriesFromXMLElement:   [[element elementsForName:@"posture-categories"] firstObject]     error:error]) return nil;
        if (![self _loadParameterTargetsFromXMLElement:    [[element elementsForName:@"parameter-targets"] firstObject]      error:error]) return nil;
        if (![self _loadMetaParameterTargetsFromXMLElement:[[element elementsForName:@"meta-parameter-targets"] firstObject] error:error]) return nil;
        if (![self _loadSymbolTargetsFromXMLElement:       [[element elementsForName:@"symbol-targets"] firstObject]         error:error]) return nil;
    }
    
    return self;
}

- (BOOL)_loadPostureCategoriesFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"posture-categories" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"category-ref"]) {
        NSString *str = [[childElement attributeForName:@"name"] stringValue];
        [self addCategoryWithName:str];
    }

    return YES;
}

- (BOOL)_loadParameterTargetsFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"parameter-targets" isEqualToString:element.name]);

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    for (NSXMLElement *childElement in [element elementsForName:@"target"]) {
        NSString *str = [[childElement attributeForName:@"name"] stringValue];
        MMTarget *target = [[MMTarget alloc] initWithXMLElement:childElement error:error];
        dictionary[str] = target;
    }

    [self addParameterTargetsFromDictionary:dictionary];

    return YES;
}

- (BOOL)_loadMetaParameterTargetsFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    if (element == nil) return YES;
    NSParameterAssert([@"meta-parameter-targets" isEqualToString:element.name]);

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    for (NSXMLElement *childElement in [element elementsForName:@"target"]) {
        NSString *str = [[childElement attributeForName:@"name"] stringValue];
        MMTarget *target = [[MMTarget alloc] initWithXMLElement:childElement error:error];
        dictionary[str] = target;
    }

    [self addMetaParameterTargetsFromDictionary:dictionary];

    return YES;
}

- (BOOL)_loadSymbolTargetsFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"symbol-targets" isEqualToString:element.name]);

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    for (NSXMLElement *childElement in [element elementsForName:@"target"]) {
        NSString *str = [[childElement attributeForName:@"name"] stringValue];
        MMTarget *target = [[MMTarget alloc] initWithXMLElement:childElement error:error];
        dictionary[str] = target;
    }

    [self addSymbolTargetsFromDictionary:dictionary];

    return YES;
}

- (void)_addDefaultValues;
{
    [self addCategory:[self.model categoryWithName:@"phone"]];

    for (MMParameter *parameter in [self.model parameters]) {
        MMTarget *target = [[MMTarget alloc] initWithValue:[parameter defaultValue] isDefault:YES];
        [self.parameterTargets addObject:target];
    }

    for (MMParameter *parameter in [self.model metaParameters]) {
        MMTarget *target = [[MMTarget alloc] initWithValue:[parameter defaultValue] isDefault:YES];
        [self.metaParameterTargets addObject:target];
    }

    for (MMParameter *parameter in [self.model symbols]) {
        MMTarget *target = [[MMTarget alloc] initWithValue:[parameter defaultValue] isDefault:YES];
        [self.symbolTargets addObject:target];
    }
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@, categories: %@, parameterTargets: %@, metaParameterTargets: %@, symbolTargets: %@",
            NSStringFromClass([self class]), self,
            self.name, self.comment, self.categories, self.parameterTargets, self.metaParameterTargets, self.symbolTargets];
}

- (NSString *)shortDescription;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@",
            NSStringFromClass([self class]), self,
            self.name];
}

#pragma mark - Superclass methods

// TODO (2004-03-19): Enforce unique names.
// TODO (2012-04-21): Model should observe chanes to posture names and resort.
- (void)setName:(NSString *)name;
{
    [super setName:name];
    [self.model sortPostures];
    self.nativeCategory.name = name;
}

#pragma mark - Categories

- (void)addCategory:(MMCategory *)category;
{
    if (category != nil) {
        if ([self.categories containsObject:category] == NO)
            [self.categories addObject:category];
    }
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
    for (MMNamedObject *category in self.categories) {
        if ([category.name isEqualToString:name])
            return YES;
    }

    return NO;
}

- (void)addCategoryWithName:(NSString *)name;
{
    NSParameterAssert(self.model != nil);
    MMCategory *category = [self.model categoryWithName:name];
    [self addCategory:category];
}

#pragma mark - Parameter Targets

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
    for (MMParameter *parameter in self.model.parameters) {
        MMTarget *target = [dictionary objectForKey:parameter.name];
        if (target == nil) {
            NSLog(@"Warning: no target for parameter %@ in save file, adding default target.", parameter.name);
            target = [[MMTarget alloc] initWithValue:parameter.defaultValue isDefault:YES];
            [self addParameterTarget:target];
        } else {
            [self addParameterTarget:target];
        }

        // TODO (2004-04-22): Check for targets that were in the save file, but that don't have a matching parameter.
    }
}

#pragma mark - Meta-parameter Targets

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
    for (MMParameter *parameter in self.model.metaParameters) {
        MMTarget *target = [dictionary objectForKey:parameter.name];
        if (target == nil) {
            NSLog(@"Warning: no target for meta parameter %@ in save file, adding default target.", parameter.name);
            target = [[MMTarget alloc] initWithValue:parameter.defaultValue isDefault:YES];
            [self addMetaParameterTarget:target];
        } else {
            [self addMetaParameterTarget:target];
        }

        // TODO (2004-04-22): Check for targets that were in the save file, but that don't have a matching parameter.
    }
}

#pragma mark - Symbol Targets

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
    for (MMParameter *parameter in self.model.symbols) {
        MMTarget *target = [dictionary objectForKey:parameter.name];
        if (target == nil) {
            NSLog(@"Warning: no target for symbol %@ in save file, adding default target.", parameter.name);
            target = [[MMTarget alloc] initWithValue:parameter.defaultValue isDefault:YES];
            [self addSymbolTarget:target];
        } else {
            [self addSymbolTarget:target];
        }
        
        // TODO (2004-04-22): Check for targets that were in the save file, but that don't have a matching parameter.
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
    if ([self.categories count] > 0) {
        [resultString indentToLevel:level];
        [resultString appendString:@"<posture-categories>\n"];
        
        for (MMCategory *category in self.categories) {
            [resultString indentToLevel:level + 1];
            [resultString appendFormat:@"<category-ref name=\"%@\"/>\n", [category name]];
        }
        
        [resultString indentToLevel:level];
        [resultString appendString:@"</posture-categories>\n"];
    }
}

- (void)_appendXMLForParameters:(NSArray *)parameters targets:(NSArray *)targets elementName:(NSString *)elementName toString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSParameterAssert([parameters count] == [targets count]);
    
    if ([parameters count] > 0) {
        [resultString indentToLevel:level];
        [resultString appendFormat:@"<%@>\n", elementName];
        
        [parameters enumerateObjectsUsingBlock:^(MMParameter *parameter, NSUInteger index, BOOL *stop){
            MMTarget *target = [targets objectAtIndex:index];
            
            [resultString indentToLevel:level + 1];
            [resultString appendFormat:@"<target name=\"%@\" value=\"%g\"/>", parameter.name, target.value];
            if (target.value == parameter.defaultValue)
                [resultString appendString:@"<!-- default -->"];
            [resultString appendString:@"\n"];
        }];
        
        [resultString indentToLevel:level];
        [resultString appendFormat:@"</%@>\n", elementName];
    }
}

- (void)_appendXMLForParametersToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [self _appendXMLForParameters:self.model.parameters targets:self.parameterTargets elementName:@"parameter-targets" toString:resultString level:level];
}

- (void)_appendXMLForMetaParametersToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [self _appendXMLForParameters:self.model.metaParameters targets:self.metaParameterTargets elementName:@"meta-parameter-targets" toString:resultString level:level];
}

- (void)_appendXMLForSymbolsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [self _appendXMLForParameters:self.model.symbols targets:self.symbolTargets elementName:@"symbol-targets" toString:resultString level:level];
}

@end
