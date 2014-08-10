//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MModel.h"

#import "NSArray-Extensions.h"
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMCategory.h"
#import "MMGroup.h"
#import "MMBooleanParser.h"
#import "MMEquation.h"
#import "MMParameter.h"
#import "MMPosture.h"
#import "MMRule.h"
#import "MMSymbol.h"
#import "MMSynthesisParameters.h"
#import "MMTarget.h"
#import "MMTransition.h"
#import "TRMData.h"

#import "MXMLParser.h"
#import "MXMLArrayDelegate.h"

@interface MModel ()
@end

#pragma mark -

@implementation MModel
{
    NSMutableArray *_categories; // Keep this list sorted by name
    NSMutableArray *_parameters;
    NSMutableArray *_metaParameters;
    NSMutableArray *_symbols;
    NSMutableArray *_postures; // Keep this list sorted by name

    NSMutableArray *_equationGroups;          // Of MMGroups of MMEquations
    NSMutableArray *_transitionGroups;        // Of MMGroups of MMTransitions
    NSMutableArray *_specialTransitionGroups; // Of MMGroups of MMTransitions

    NSMutableArray *_rules;
    NSUInteger _cacheTag;

    // This doesn't really belong here, but I'll put it here for now.
    MMSynthesisParameters *_synthesisParameters;
}

- (id)init;
{
    if ((self = [super init])) {
        _categories              = [[NSMutableArray alloc] init];
        _parameters              = [[NSMutableArray alloc] init];
        _metaParameters          = [[NSMutableArray alloc] init];
        _symbols                 = [[NSMutableArray alloc] init];
        _postures                = [[NSMutableArray alloc] init];
        _equationGroups          = [[NSMutableArray alloc] init];
        _transitionGroups        = [[NSMutableArray alloc] init];
        _specialTransitionGroups = [[NSMutableArray alloc] init];
        _rules                   = [[NSMutableArray alloc] init];
        _cacheTag                = 1;
        _synthesisParameters     = [[MMSynthesisParameters alloc] init];
    }

    return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"root" isEqualToString:element.name]);
    NSParameterAssert([@"1" isEqualToString:[[element attributeForName:@"version"] stringValue]]);

    if ((self = [super init])) {
        _categories              = [[NSMutableArray alloc] init];
        _parameters              = [[NSMutableArray alloc] init];
        _metaParameters          = [[NSMutableArray alloc] init];
        _symbols                 = [[NSMutableArray alloc] init];
        _postures                = [[NSMutableArray alloc] init];
        _equationGroups          = [[NSMutableArray alloc] init];
        _transitionGroups        = [[NSMutableArray alloc] init];
        _specialTransitionGroups = [[NSMutableArray alloc] init];
        _rules                   = [[NSMutableArray alloc] init];
        _cacheTag                = 1;
        _synthesisParameters     = [[MMSynthesisParameters alloc] init];

        if (![self _loadCategoriesFromXMLElement:        [[element elementsForName:@"categories"] firstObject]          error:error]) return nil;
        NSLog(@"categories: %@", _categories);
        if (![self _loadParametersFromXMLElement:        [[element elementsForName:@"parameters"] firstObject]          error:error]) return nil;
        NSLog(@"parameters: %@", _parameters);
        if (![self _loadMetaParametersFromXMLElement:    [[element elementsForName:@"meta-parameters"] firstObject]     error:error]) return nil;
        NSLog(@"meta parameters: %@", _metaParameters);
        if (![self _loadSymbolsFromXMLElement:           [[element elementsForName:@"symbols"] firstObject]             error:error]) return nil;
        NSLog(@"symbols: %@", _symbols);
        if (![self _loadPosturesFromXMLElement:          [[element elementsForName:@"postures"] firstObject]            error:error]) return nil;
        if (![self _loadEquationsFromXMLElement:         [[element elementsForName:@"equations"] firstObject]           error:error]) return nil;
        if (![self _loadTransitionsFromXMLElement:       [[element elementsForName:@"transitions"] firstObject]         error:error]) return nil;
        if (![self _loadSpecialTransitionsFromXMLElement:[[element elementsForName:@"special-transitions"] firstObject] error:error]) return nil;
        if (![self _loadRulesFromXMLElement:             [[element elementsForName:@"rules"] firstObject]               error:error]) return nil;
    }

    return self;
}

- (BOOL)_loadCategoriesFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"categories" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"category"]) {
        MMCategory *category = [[MMCategory alloc] initWithXMLElement:childElement error:error];
        if (category != nil)
            [self addCategory:category];
    }

    return YES;
}

- (BOOL)_loadParametersFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"parameters" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"parameter"]) {
        MMParameter *parameter = [[MMParameter alloc] initWithXMLElement:childElement error:error];
        if (parameter != nil)
            [self addParameter:parameter];
    }
    
    return YES;
}

- (BOOL)_loadMetaParametersFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    if (element == nil) return YES;
    NSParameterAssert([@"meta-parameters" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"parameter"]) {
        MMParameter *parameter = [[MMParameter alloc] initWithXMLElement:childElement error:error];
        if (parameter != nil)
            [self addMetaParameter:parameter];
    }
    
    return YES;
}

- (BOOL)_loadSymbolsFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"symbols" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"symbol"]) {
        MMSymbol *symbol = [[MMSymbol alloc] initWithXMLElement:childElement error:error];
        if (symbol != nil)
            [self addSymbol:symbol];
    }
    
    return YES;
}

- (BOOL)_loadPosturesFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"postures" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"posture"]) {
        MMPosture *posture = [[MMPosture alloc] initWithModel:self XMLElement:childElement error:error];
        if (posture != nil)
            [self addPosture:posture];
    }
    
    return YES;
}

- (BOOL)_loadEquationsFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"equations" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"equation-group"]) {
        MMGroup *group = [[MMGroup alloc] initWithModel:self XMLElement:childElement error:error];
        if (group != nil)
            [self addEquationGroup:group];
    }
    
    return YES;
}

- (BOOL)_loadTransitionsFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"transitions" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"transition-group"]) {
    }
    
    return YES;
}

- (BOOL)_loadSpecialTransitionsFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"special-transitions" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"transition-group"]) {
    }
    
    return YES;
}

- (BOOL)_loadRulesFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"rules" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"rule"]) {
    }
    
    return YES;
}

#pragma mark -

- (void)_addDefaultRule;
{
    MMBooleanParser *boolParser = [[MMBooleanParser alloc] initWithModel:self];
    MMBooleanNode *expr1 = [boolParser parseString:@"phone"];
    MMBooleanNode *expr2 = [boolParser parseString:@"phone"];

    MMRule *rule = [[MMRule alloc] init];
    [rule setExpression:expr1 number:0];
    [rule setExpression:expr2 number:1];
    [rule setDefaultsTo:[rule numberExpressions]];
    [self addRule:rule];
}

#pragma mark - Categories

- (void)addCategory:(MMCategory *)category;
{
    [self _generateUniqueNameForObject:category existingObjects:self.categories];

    [_categories addObject:category];
    //[categories sortUsingSelector:@selector(compareByAscendingName:)];
    // TODO (2004-03-18): And post notification of new category.
}

// TODO (2004-03-19): Is it used by rules, anyway.  Postures can also use categories.
- (BOOL)isCategoryUsed:(MMCategory *)category;
{
    for (MMRule *rule in self.rules) {
        if ([rule usesCategory:category])
            return YES;
    }

    return NO;
}

// Returns YES if the category was removed, or NO if the category is still being used.
- (BOOL)removeCategory:(MMCategory *)category;
{
    if ([self isCategoryUsed:category]) {
        return NO;
    }

    [_categories removeObject:category];
    return YES;
}

// TODO (2004-03-19): We could store these in a dictionary for quick lookup by name.
- (MMCategory *)categoryWithName:(NSString *)name;
{
    for (MMCategory *category in self.categories) {
        if ([[category name] isEqual:name])
            return category;
    }

    return nil;
}

#pragma mark - Parameters

- (void)addParameter:(MMParameter *)parameter;
{
    if (parameter.name == nil) parameter.name = @"untitled";

    [self _generateUniqueNameForObject:parameter existingObjects:self.parameters];

    [self.parameters addObject:parameter];
    parameter.model = self;
    
    // Add default posture targets
    for (MMPosture *posture in self.postures) {
        MMTarget *target = [[MMTarget alloc] initWithValue:parameter.defaultValue isDefault:YES];
        [posture addParameterTarget:target];
    }

    // TODO (2012-04-23): Not sure about this, seems a little bit odd
    for (MMRule *rule in self.rules)
        [rule addDefaultTransitionForLastParameter];
}

- (void)_generateUniqueNameForObject:(MMNamedObject *)object existingObjects:(NSArray *)existingObjects;
{
    NSMutableSet *names = [[NSMutableSet alloc] init];
    for (MMNamedObject *namedObject in existingObjects) {
        if (namedObject.name != nil)
            [names addObject:namedObject.name];
    }

    NSString *basename = (object.name == nil) ? @"untitled" : object.name;
    NSString *name = basename;

    NSUInteger index = 1;
    while ([names containsObject:name]) {
        name = [NSString stringWithFormat:@"%@%lu", basename, index++];
    }

    object.name = name;
}

- (void)removeParameter:(MMParameter *)parameter;
{
    NSUInteger index  = [self.parameters indexOfObject:parameter];
    if (index != NSNotFound) {
        for (MMPosture *posture in self.postures)
            [posture removeParameterTargetAtIndex:index];

        for (MMRule *rule in self.rules)
            [rule removeParameterAtIndex:index];

        [self.parameters removeObject:parameter];
    }
}

#pragma mark - Meta Parameters

- (void)addMetaParameter:(MMParameter *)parameter;
{
    if (parameter.name == nil) parameter.name = @"untitled";

    [self _generateUniqueNameForObject:parameter existingObjects:self.metaParameters];

    [self.metaParameters addObject:parameter];
    parameter.model = self;

    // Add default posture targets
    for (MMPosture *posture in self.postures) {
        MMTarget *target = [[MMTarget alloc] initWithValue:parameter.defaultValue isDefault:YES];
        [posture addMetaParameterTarget:target];
    }
    
    // TODO (2012-04-23): It's not clear how these all interact.  It looks like this is adding a default _Transition_ for the new meta parameter to all the rules.
    // And this is just assuming that the new meta parameter was added at the end...
    for (MMRule *rule in self.rules)
        [rule addDefaultTransitionForLastMetaParameter];
}

- (void)removeMetaParameter:(MMParameter *)parameter;
{
    NSUInteger index  = [self.metaParameters indexOfObject:parameter];
    if (index != NSNotFound) {
        for (MMPosture *posture in self.postures)
            [posture removeMetaParameterTargetAtIndex:index];

        for (MMRule *rule in self.rules)
            [rule removeMetaParameterAtIndex:index];

        [self.metaParameters removeObject:parameter];
    }
}

#pragma mark - Symbols

- (void)addSymbol:(MMSymbol *)symbol;
{
    if (symbol.name == nil) symbol.name = @"untitled";

    [self _generateUniqueNameForObject:symbol existingObjects:self.symbols];

    [_symbols addObject:symbol];
    symbol.model = self;
    
    // Add default symbol targets
    for (MMPosture *posture in self.postures) {
        MMTarget *target = [[MMTarget alloc] initWithValue:symbol.defaultValue isDefault:YES];
        [posture addSymbolTarget:target];
    }
}

- (void)removeSymbol:(MMSymbol *)symbol;
{
    NSUInteger index = [_symbols indexOfObject:symbol];
    if (index != NSNotFound) {
        for (MMPosture *posture in _postures)
            [posture removeSymbolTargetAtIndex:index];

        [_symbols removeObject:symbol];
    }
}

- (MMSymbol *)symbolWithName:(NSString *)name;
{
    for (MMSymbol *symbol in _symbols) {
        if ([symbol.name isEqual:name])
            return symbol;
    }

    return nil;
}

#pragma mark - Postures

- (void)addPosture:(MMPosture *)posture;
{
    posture.model = self;
    [self _generateUniqueNameForPosture:posture];

    [_postures addObject:posture];
    [self sortPostures];
}

- (void)_generateUniqueNameForPosture:(MMPosture *)newPosture;
{
    NSMutableSet *names = [[NSMutableSet alloc] init];
    for (MMPosture *posture in self.postures) {
        if (posture.name != nil)
            [names addObject:posture.name];
    }

    NSUInteger index = 1;
    NSString *basename = (newPosture.name == nil) ? @"untitled" : newPosture.name;
    NSString *name = basename;
    BOOL isUsed = [names containsObject:name];

    if (isUsed) {
        for (char ch1 = 'A'; isUsed && ch1 <= 'Z'; ch1++) {
            name = [NSString stringWithFormat:@"%@%c", basename, ch1];
            isUsed = [names containsObject:name];
        }

        for (char ch1 = 'A'; isUsed && ch1 <= 'Z'; ch1++) {
            for (char ch2 = 'A'; isUsed && ch2 <= 'Z'; ch2++) {
                name = [NSString stringWithFormat:@"%@%c%c", basename, ch1, ch2];
                isUsed = [names containsObject:name];
            }
        }
    }

    while ([names containsObject:name]) {
        name = [NSString stringWithFormat:@"%@%lu", basename, index++];
    }

    newPosture.name = name;
}

- (void)removePosture:(MMPosture *)posture;
{
    [_postures removeObject:posture];

    // TODO (2004-03-20): Make sure it isn't used by any rules?
}

- (void)sortPostures;
{
    [_postures sortUsingSelector:@selector(compareByAscendingName:)];
}

- (MMPosture *)postureWithName:(NSString *)name;
{
    for (MMPosture *posture in self.postures) {
        if ([posture.name isEqual:name])
            return posture;
    }

    return nil;
}

- (void)addEquationGroup:(MMGroup *)group;
{
    [_equationGroups addObject:group];
    group.model = self;
}

- (void)addTransitionGroup:(MMGroup *)group;
{
    [_transitionGroups addObject:group];
    group.model = self;
}

- (void)addSpecialTransitionGroup:(MMGroup *)group;
{
    [_specialTransitionGroups addObject:group];
    group.model = self;
}

// This will require that all the equation names be unique.  Otherwise we'll need to store the group in the XML file as well.
- (MMEquation *)findEquationWithName:(NSString *)name;
{
    for (MMGroup *group in self.equationGroups) {
        MMEquation *equation = [group objectWithName:name];
        if (equation != nil)
            return equation;
    }

    return nil;
}

- (MMTransition *)findTransitionWithName:(NSString *)name;
{
    for (MMGroup *group in self.transitionGroups) {
        MMTransition *transition = [group objectWithName:name];
        if (transition != nil)
            return transition;
    }

    return nil;
}

- (MMTransition *)findSpecialTransitionWithName:(NSString *)name;
{
    for (MMGroup *group in self.specialTransitionGroups) {
        MMTransition *transition = [group objectWithName:name];
        if (transition != nil)
            return transition;
    }

    return nil;
}

- (MMEquation *)findEquationWithName:(NSString *)equationName inGroupWithName:(NSString *)groupName;
{
    for (MMGroup *group in self.equationGroups) {
        if ([groupName isEqualToString:group.name]) {
            MMEquation *equation = [group objectWithName:equationName];
            if (equation != nil)
                return equation;
        }
    }

    NSLog(@"Couldn't find equation: %@/%@", groupName, equationName);

    return nil;
}


- (MMTransition *)findTransitionWithName:(NSString *)transitionName inGroupWithName:(NSString *)groupName;
{
    for (MMGroup *group in self.transitionGroups) {
        if ([groupName isEqualToString:group.name]) {
            MMTransition *transition = [group objectWithName:transitionName];
            if (transition != nil)
                return transition;
        }
    }

    NSLog(@"Couldn't find transition: %@/%@", groupName, transitionName);

    return nil;
}

// Returns strings idicatig which rules, transitions, and special transitions use this equation.
- (NSArray *)usageOfEquation:(MMEquation *)equation;
{
    NSMutableArray *array = [NSMutableArray array];
    
    [self.rules enumerateObjectsUsingBlock:^(MMRule *rule, NSUInteger index, BOOL *stop) {
        if ([rule usesEquation:equation]) {
            [array addObject:[NSString stringWithFormat:@"Rule: %lu", index + 1]];
        }
    }];

    for (MMGroup *group in self.transitionGroups) {
        for (MMTransition *transition in group.objects) {
            if ([transition isEquationUsed:equation]) {
                [array addObject:[NSString stringWithFormat:@"T:%@:%@", transition.group.name, transition.name]];
            }
        }
    }

    for (MMGroup *group in self.specialTransitionGroups) {
        for (MMTransition *transition in group.objects) {
            if ([transition isEquationUsed:equation]) {
                [array addObject:[NSString stringWithFormat:@"S:%@:%@", transition.group.name, transition.name]];
            }
        }
    }

    return array;
}

// Returns strings indicating which rules use this transition.
- (NSArray *)usageOfTransition:(MMTransition *)transition;
{
    NSMutableArray *array = [NSMutableArray array];

    [self.rules enumerateObjectsUsingBlock:^(MMRule *rule, NSUInteger index, BOOL *stop) {
        if ([rule usesTransition:transition]) {
            [array addObject:[NSString stringWithFormat:@"Rule: %lu", index + 1]];
        }
    }];

    return array;
}

#pragma mark - Rules

- (void)addRule:(MMRule *)newRule;
{
    [newRule setModel:self];
    [newRule setDefaultsTo:[newRule numberExpressions]]; // TODO (2004-05-15): Try moving this to the init method.
    if ([_rules count] > 0)
        [_rules insertObject:newRule atIndex:[_rules count] - 1];
    else
        [_rules addObject:newRule];
}

// Used when loading from stored file.
- (void)_addStoredRule:(MMRule *)newRule;
{
    [newRule setModel:self];
    [_rules addObject:newRule];
}

// categoryLists is a list of lists of categories.
- (MMRule *)findRuleMatchingCategories:(NSArray *)categoryLists ruleIndex:(NSInteger *)indexPtr;
{
    __block MMRule *matchingRule = nil;
    __block NSUInteger matchingIndex = 0;
    
    [self.rules enumerateObjectsUsingBlock:^(MMRule *rule, NSUInteger index, BOOL *stop){
        if ([rule numberExpressions] <= [categoryLists count])
            if ([rule matchRule:categoryLists]) {
                matchingRule = rule;
                matchingIndex = index;
                *stop = YES;
            }
    }];
    
    if (matchingRule != nil && indexPtr != NULL)
        *indexPtr = matchingIndex;

    return matchingRule;
}

#pragma mark - Archiving - XML

- (BOOL)writeXMLToFile:(NSString *)aFilename comment:(NSString *)comment;
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    [resultString appendString:@"<?xml version='1.0' encoding='utf-8'?>\n"];
    [resultString appendString:@"<!DOCTYPE root PUBLIC \"\" \"monet-v1.dtd\">\n"];
    if (comment != nil)
        [resultString appendFormat:@"<!-- %@ -->\n", comment];
    [resultString appendString:@"<root version='1'>\n"];

    [_categories appendXMLToString:resultString elementName:@"categories" level:1];

    [_parameters appendXMLToString:resultString elementName:@"parameters" level:1];
    [_metaParameters appendXMLToString:resultString elementName:@"meta-parameters" level:1];
    [_symbols appendXMLToString:resultString elementName:@"symbols" level:1];
    [_postures appendXMLToString:resultString elementName:@"postures" level:1];

    [self _appendXMLForEquationsToString:resultString level:1];
    [self _appendXMLForTransitionsToString:resultString level:1];
    [self _appendXMLForProtoSpecialsToString:resultString level:1];
    [_rules appendXMLToString:resultString elementName:@"rules" level:1 numberCommentPrefix:@"Rule"];

    [resultString appendString:@"</root>\n"];

    //NSLog(@"xml: \n%@", resultString);
    //[[resultString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:@"/tmp/out.xml" atomically:YES];
    BOOL result = [[resultString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:aFilename atomically:YES];

    return result;
}

- (void)_appendXMLForEquationsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendString:@"<equations>\n"];
    for (MMGroup *group in self.equationGroups) {
        [group appendXMLToString:resultString elementName:@"equation-group" level:level + 1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</equations>\n"];
}

- (void)_appendXMLForTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendString:@"<transitions>\n"];
    for (MMGroup *group in self.transitionGroups) {
        [group appendXMLToString:resultString elementName:@"transition-group" level:level + 1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</transitions>\n"];
}

- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendString:@"<special-transitions>\n"];
    for (MMGroup *group in self.specialTransitionGroups) {
        [group appendXMLToString:resultString elementName:@"transition-group" level:level + 1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</special-transitions>\n"];
}

- (NSUInteger)nextCacheTag;
{
    return ++_cacheTag;
}

- (void)parameter:(MMParameter *)parameter willChangeDefaultValue:(double)newDefaultValue;
{
    double oldDefaultValue = [parameter defaultValue];

    NSUInteger parameterIndex = [self.parameters indexOfObject:parameter];
    if (parameterIndex != NSNotFound) {
        for (MMPosture *posture in self.postures) {
            [[posture.parameterTargets objectAtIndex:parameterIndex] changeDefaultValueFrom:oldDefaultValue to:newDefaultValue];
        }
    }

    parameterIndex = [self.metaParameters indexOfObject:parameter];
    if (parameterIndex != NSNotFound) {
        for (MMPosture *posture in self.postures) {
            [[posture.metaParameterTargets objectAtIndex:parameterIndex] changeDefaultValueFrom:oldDefaultValue to:newDefaultValue];
        }
    }
}

- (void)symbol:(MMSymbol *)symbol willChangeDefaultValue:(double)newDefaultValue;
{
    NSUInteger symbolIndex = [self.symbols indexOfObject:symbol];
    if (symbolIndex != NSNotFound) {
        double oldDefaultValue = symbol.defaultValue;
        for (MMPosture *posture in self.postures) {
            [[posture.symbolTargets objectAtIndex:symbolIndex] changeDefaultValueFrom:oldDefaultValue to:newDefaultValue];
        }
    }
}

#if 0
#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"categories"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"category" class:[MMCategory class] delegate:self addObjectSelector:@selector(addCategory:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
    } else if ([elementName isEqualToString:@"parameters"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"parameter" class:[MMParameter class] delegate:self addObjectSelector:@selector(addParameter:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
    } else if ([elementName isEqualToString:@"meta-parameters"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"parameter" class:[MMParameter class] delegate:self addObjectSelector:@selector(addMetaParameter:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
    } else if ([elementName isEqualToString:@"symbols"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"symbol" class:[MMSymbol class] delegate:self addObjectSelector:@selector(addSymbol:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
    } else if ([elementName isEqualToString:@"postures"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"posture" class:[MMPosture class] delegate:self addObjectSelector:@selector(addPosture:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
    } else if ([elementName isEqualToString:@"equations"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"equation-group" class:[MMGroup class] delegate:self addObjectSelector:@selector(addEquationGroup:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
    } else if ([elementName isEqualToString:@"transitions"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"transition-group" class:[MMGroup class] delegate:self addObjectSelector:@selector(addTransitionGroup:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
    } else if ([elementName isEqualToString:@"special-transitions"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"transition-group" class:[MMGroup class] delegate:self addObjectSelector:@selector(addSpecialTransitionGroup:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
    } else if ([elementName isEqualToString:@"rules"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"rule" class:[MMRule class] delegate:self addObjectSelector:@selector(_addStoredRule:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
    } else {
        NSLog(@"starting unknown element: '%@'", elementName);
        [(MXMLParser *)parser skipTree];
    }
}
#endif

@end
