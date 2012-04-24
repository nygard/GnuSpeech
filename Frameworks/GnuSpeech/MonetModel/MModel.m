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

- (void)_addDefaultRule;
- (void)_generateUniqueNameForObject:(MMNamedObject *)newObject existingObjects:(NSArray *)existingObjects;

- (void)_generateUniqueNameForPosture:(MMPosture *)newPosture;
- (void)_addStoredRule:(MMRule *)newRule;
- (void)_appendXMLForEquationsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(NSUInteger)level;

@end

#pragma mark -

@implementation MModel
{
    NSMutableArray *categories; // Keep this list sorted by name
    NSMutableArray *parameters;
    NSMutableArray *metaParameters;
    NSMutableArray *symbols;
    NSMutableArray *postures; // Keep this list sorted by name
    
    NSMutableArray *equationGroups;          // Of MMGroups of MMEquations
    NSMutableArray *transitionGroups;        // Of MMGroups of MMTransitions
    NSMutableArray *specialTransitionGroups; // Of MMGroups of MMTransitions
    
    NSMutableArray *rules;
    NSUInteger cacheTag;
    
    // This doesn't really belong here, but I'll put it here for now.
    MMSynthesisParameters *synthesisParameters;
}

- (id)init;
{
    if ((self = [super init])) {
        categories = [[NSMutableArray alloc] init];
        parameters = [[NSMutableArray alloc] init];
        metaParameters = [[NSMutableArray alloc] init];
        symbols = [[NSMutableArray alloc] init];
        postures = [[NSMutableArray alloc] init];
        
        equationGroups = [[NSMutableArray alloc] init];
        transitionGroups = [[NSMutableArray alloc] init];
        specialTransitionGroups = [[NSMutableArray alloc] init];
        
        rules = [[NSMutableArray alloc] init];
#if 0
        // And set up some default values:
        // TODO (2004-05-15): Just load these from a default .monet file
        {
            MMSymbol *newSymbol;
            MMCategory *newCategory;
            
            newSymbol = [[MMSymbol alloc] init];
            [newSymbol setName:@"duration"];
            [self addSymbol:newSymbol];
            [newSymbol release];
            
            newCategory = [[MMCategory alloc] init];
            [newCategory setName:@"phone"];
            [newCategory setComment:@"This is the static phone category.  It cannot be changed or removed."];
            [self addCategory:newCategory];
            [newCategory release];
            
            [self _addDefaultRule];
        }
#endif
        cacheTag = 1;
        
        synthesisParameters = [[MMSynthesisParameters alloc] init];
    }

    return self;
}

- (void)dealloc;
{
    [categories release];
    [parameters release];
    [metaParameters release];
    [symbols release];
    [postures release];
    [equationGroups release];
    [transitionGroups release];
    [specialTransitionGroups release];
    [rules release];

    [synthesisParameters release];

    [super dealloc];
}

#pragma mark -

- (void)_addDefaultRule;
{
    MMBooleanParser *boolParser = [[[MMBooleanParser alloc] initWithModel:self] autorelease];
    MMBooleanNode *expr1 = [boolParser parseString:@"phone"];
    MMBooleanNode *expr2 = [boolParser parseString:@"phone"];

    MMRule *rule = [[[MMRule alloc] init] autorelease];
    [rule setExpression:expr1 number:0];
    [rule setExpression:expr2 number:1];
    [rule setDefaultsTo:[rule numberExpressions]];
    [self addRule:rule];
}

@synthesize categories, parameters, metaParameters, symbols, postures, equationGroups, transitionGroups, specialTransitionGroups, rules;

#pragma mark - Categories

- (void)addCategory:(MMCategory *)category;
{
    [self _generateUniqueNameForObject:category existingObjects:self.categories];

    [categories addObject:category];
    //[categories sortUsingSelector:@selector(compareByAscendingName:)];
    // TODO (2004-03-18): And post notification of new category.
}

// TODO (2004-03-19): Is it used by rules, anyway.  Postures can also use categories.
- (BOOL)isCategoryUsed:(MMCategory *)category;
{
    for (MMRule *rule in self.rules) {
        // TODO (2012-04-23): Rename usesCategory:
        if ([rule isCategoryUsed:category])
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

    [categories removeObject:category];
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
        MMTarget *target = [[[MMTarget alloc] initWithValue:parameter.defaultValue isDefault:YES] autorelease];
        [posture addParameterTarget:target];
    }

    // TODO (2012-04-23): Not sure about this, seems a little bit odd
    for (MMRule *rule in self.rules)
        [rule addDefaultTransitionForLastParameter];
}

- (void)_generateUniqueNameForObject:(MMNamedObject *)object existingObjects:(NSArray *)existingObjects;
{
    NSMutableSet *names = [[[NSMutableSet alloc] init] autorelease];
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
        MMTarget *target = [[[MMTarget alloc] initWithValue:parameter.defaultValue isDefault:YES] autorelease];
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

    [symbols addObject:symbol];
    symbol.model = self;
    
    // Add default symbol targets
    for (MMPosture *posture in self.postures) {
        MMTarget *target = [[[MMTarget alloc] initWithValue:symbol.defaultValue isDefault:YES] autorelease];
        [posture addSymbolTarget:target];
    }
}

- (void)removeSymbol:(MMSymbol *)symbol;
{
    NSUInteger index = [symbols indexOfObject:symbol];
    if (index != NSNotFound) {
        for (MMPosture *posture in postures)
            [posture removeSymbolTargetAtIndex:index];

        [symbols removeObject:symbol];
    }
}

- (MMSymbol *)symbolWithName:(NSString *)name;
{
    for (MMSymbol *symbol in symbols) {
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

    [postures addObject:posture];
    [self sortPostures];
}

- (void)_generateUniqueNameForPosture:(MMPosture *)newPosture;
{
    NSMutableSet *names = [[[NSMutableSet alloc] init] autorelease];
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
    [postures removeObject:posture];

    // TODO (2004-03-20): Make sure it isn't used by any rules?
}

- (void)sortPostures;
{
    [postures sortUsingSelector:@selector(compareByAscendingName:)];
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
    [equationGroups addObject:group];
    group.model = self;
}

- (void)addTransitionGroup:(MMGroup *)group;
{
    [transitionGroups addObject:group];
    group.model = self;
}

- (void)addSpecialTransitionGroup:(MMGroup *)group;
{
    [specialTransitionGroups addObject:group];
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

// TODO (2004-03-06): Find equation named "named" in list named "list"
// Change to findEquationNamed:(NSString *)anEquationName inList:(NSString *)aListName;
// TODO (2004-03-06): Merge these three sets of methods, since they're practically identical.
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


- (MMTransition *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
{
    NSUInteger i, j;

    for (i = 0 ; i < [transitionGroups count]; i++) {
        MMGroup *currentGroup = [transitionGroups objectAtIndex:i];
        if ([aListName isEqualToString:[currentGroup name]]) {
            for (j = 0; j < [currentGroup.objects count]; j++) {
                MMTransition *aTransition;

                aTransition = [currentGroup.objects objectAtIndex:j];
                if ([aTransitionName isEqualToString:[aTransition name]])
                    return aTransition;
            }
        }
    }

    NSLog(@"Couldn't find transition: %@/%@", aListName, aTransitionName);

    return nil;
}

// Returns strings idicatig which rules, transitions, and special transitions use this equation.
- (NSArray *)usageOfEquation:(MMEquation *)equation;
{
    NSMutableArray *array = [NSMutableArray array];
    
    [self.rules enumerateObjectsUsingBlock:^(MMRule *rule, NSUInteger index, BOOL *stop) {
        if ([rule isEquationUsed:equation]) {
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
        if ([rule isTransitionUsed:transition]) {
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
    if ([rules count] > 0)
        [rules insertObject:newRule atIndex:[rules count] - 1];
    else
        [rules addObject:newRule];
}

// Used when loading from stored file.
- (void)_addStoredRule:(MMRule *)newRule;
{
    [newRule setModel:self];
    [rules addObject:newRule];
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

    [categories appendXMLToString:resultString elementName:@"categories" level:1];

    [parameters appendXMLToString:resultString elementName:@"parameters" level:1];
    [metaParameters appendXMLToString:resultString elementName:@"meta-parameters" level:1];
    [symbols appendXMLToString:resultString elementName:@"symbols" level:1];
    [postures appendXMLToString:resultString elementName:@"postures" level:1];

    [self _appendXMLForEquationsToString:resultString level:1];
    [self _appendXMLForTransitionsToString:resultString level:1];
    [self _appendXMLForProtoSpecialsToString:resultString level:1];
    [rules appendXMLToString:resultString elementName:@"rules" level:1 numberCommentPrefix:@"Rule"];

    [resultString appendString:@"</root>\n"];

    //NSLog(@"xml: \n%@", resultString);
    //[[resultString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:@"/tmp/out.xml" atomically:YES];
    BOOL result = [[resultString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:aFilename atomically:YES];

    [resultString release];

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

- (int)nextCacheTag;
{
    return ++cacheTag;
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

#pragma mark - Other

@synthesize synthesisParameters;

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"categories"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"category" class:[MMCategory class] delegate:self addObjectSelector:@selector(addCategory:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"parameters"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"parameter" class:[MMParameter class] delegate:self addObjectSelector:@selector(addParameter:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"meta-parameters"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"parameter" class:[MMParameter class] delegate:self addObjectSelector:@selector(addMetaParameter:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"symbols"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"symbol" class:[MMSymbol class] delegate:self addObjectSelector:@selector(addSymbol:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"postures"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"posture" class:[MMPosture class] delegate:self addObjectSelector:@selector(addPosture:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"equations"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"equation-group" class:[MMGroup class] delegate:self addObjectSelector:@selector(addEquationGroup:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"transitions"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"transition-group" class:[MMGroup class] delegate:self addObjectSelector:@selector(addTransitionGroup:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"special-transitions"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"transition-group" class:[MMGroup class] delegate:self addObjectSelector:@selector(addSpecialTransitionGroup:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"rules"]) {
        MXMLArrayDelegate *arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"rule" class:[MMRule class] delegate:self addObjectSelector:@selector(_addStoredRule:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else {
        NSLog(@"starting unknown element: '%@'", elementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    //NSLog(@"closing element: '%@'", elementName);
}

@end
