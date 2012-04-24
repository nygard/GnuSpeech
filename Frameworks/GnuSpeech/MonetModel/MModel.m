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

NSString *MCategoryInUseException = @"MCategoryInUseException";

@interface MModel ()

- (void)_addDefaultRule;
- (void)_generateUniqueNameForObject:(MMNamedObject *)newObject existingObjects:(NSArray *)existingObjects;

- (void)_generateUniqueNameForPosture:(MMPosture *)newPosture;
- (void)_addStoredRule:(MMRule *)newRule;
- (void)_appendXMLForEquationsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_writeCategoriesToFile:(FILE *)fp;
- (void)_writeParametersToFile:(FILE *)fp;
- (void)_writeSymbolsToFile:(FILE *)fp;
- (void)_writePosturesToFile:(FILE *)fp;

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

- (void)removeCategory:(MMCategory *)category;
{
    if ([self isCategoryUsed:category]) {
        // TODO: Don't raise exception.  Return NO and an NSError
        [NSException raise:MCategoryInUseException format:@"Cannot remove category that is in use."];
    }

    [categories removeObject:category];
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

- (void)findList:(NSUInteger *)listIndex andIndex:(NSUInteger *)equationIndex ofEquation:(MMEquation *)anEquation;
{
    NSUInteger i, temp;

    for (i = 0 ; i < [equationGroups count]; i++) {
        temp = [[equationGroups objectAtIndex:i] indexOfObject:anEquation];
        if (temp != NSNotFound) {
            *listIndex = i;
            *equationIndex = temp;
            return;
        }
    }

    *listIndex = -1;
    // TODO (2004-03-06): This might be where/how the large list indexes were archived.
}

- (MMEquation *)findEquation:(NSUInteger)listIndex andIndex:(NSUInteger)equationIndex;
{
    //NSLog(@"-> %s, listIndex: %d, index: %d", _cmd, listIndex, index);
    if (listIndex > [equationGroups count]) {
        NSLog(@"%s: listIndex: %lu out of range.  count: %lu", __PRETTY_FUNCTION__, listIndex, [equationGroups count]);
        return nil;
    }

    return [[equationGroups objectAtIndex:listIndex] objectAtIndex:equationIndex];
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

- (void)findList:(NSUInteger *)listIndex andIndex:(NSUInteger *)transitionIndex ofTransition:(MMTransition *)aTransition;
{
    NSUInteger i, temp;

    for (i = 0 ; i < [transitionGroups count]; i++) {
        temp = [[transitionGroups objectAtIndex:i] indexOfObject:aTransition];
        if (temp != NSNotFound) {
            *listIndex = i;
            *transitionIndex = temp;
            return;
        }
    }

    *listIndex = -1;
}

- (MMTransition *)findTransition:(NSUInteger)listIndex andIndex:(NSUInteger)transitionIndex;
{
    //NSLog(@"Name: %@ (%d)\n", [[transitions objectAtIndex: listIndex] name], listIndex);
    //NSLog(@"\tCount: %d  index: %d  count: %d\n", [transitions count], index, [[transitions objectAtIndex: listIndex] count]);
    return [[transitionGroups objectAtIndex:listIndex] objectAtIndex:transitionIndex];
}

- (MMTransition *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
{
    NSUInteger i, j;

    for (i = 0 ; i < [specialTransitionGroups count]; i++) {
        MMGroup *currentGroup = [specialTransitionGroups objectAtIndex:i];
        if ([aListName isEqualToString:[currentGroup name]]) {
            for (j = 0; j < [currentGroup.objects count]; j++) {
                MMTransition *aTransition = [currentGroup.objects objectAtIndex:j];
                if ([aSpecialName isEqualToString:[aTransition name]])
                    return aTransition;
            }
        }
    }

    NSLog(@"Couldn't find special transition: %@/%@", aListName, aSpecialName);

    return nil;
}

- (void)findList:(NSUInteger *)listIndex andIndex:(NSUInteger *)specialIndex ofSpecial:(MMTransition *)aTransition;
{
    NSUInteger i, temp;

    for (i = 0 ; i < [specialTransitionGroups count]; i++) {
        temp = [[specialTransitionGroups objectAtIndex:i] indexOfObject:aTransition];
        if (temp != NSNotFound) {
            *listIndex = i;
            *specialIndex = temp;
            return;
        }
    }

    *listIndex = -1;
}

- (MMTransition *)findSpecial:(NSUInteger)listIndex andIndex:(NSUInteger)specialIndex;
{
    return [[specialTransitionGroups objectAtIndex:listIndex] objectAtIndex:specialIndex];
}

- (NSArray *)usageOfEquation:(MMEquation *)anEquation;
{
    NSUInteger count, index;

    NSMutableArray *array = [NSMutableArray array];
    count = [rules count];
    for (index = 0; index < count; index++) {
        MMRule *aRule = [rules objectAtIndex:index];
        if ([aRule isEquationUsed:anEquation]) {
            [array addObject:[NSString stringWithFormat:@"Rule: %lu", index + 1]];
        }
    }

    count = [transitionGroups count];
    for (index = 0; index < count; index++) {
        NSUInteger transitionCount, transitionIndex;

        MMGroup *group = [transitionGroups objectAtIndex:index];
        transitionCount = [group.objects count];
        for (transitionIndex = 0; transitionIndex < transitionCount; transitionIndex++) {
            MMTransition *aTransition = [group.objects objectAtIndex:transitionIndex];
            if ([aTransition isEquationUsed:anEquation]) {
                [array addObject:[NSString stringWithFormat:@"T:%@:%@", [[aTransition group] name], [aTransition name]]];
            }
        }
    }

    count = [specialTransitionGroups count];
    for (index = 0; index < count; index++) {
        NSUInteger transitionCount, transitionIndex;

        MMGroup *group = [specialTransitionGroups objectAtIndex:index];
        transitionCount = [group.objects count];
        for (transitionIndex = 0; transitionIndex < transitionCount; transitionIndex++) {
            MMTransition *aTransition = [group.objects objectAtIndex:transitionIndex];
            if ([aTransition isEquationUsed:anEquation]) {
                [array addObject:[NSString stringWithFormat:@"S:%@:%@", [[aTransition group] name], [aTransition name]]];
            }
        }
    }
    
    NSParameterAssert([array isKindOfClass:[NSArray class]]);

    return array;
}


- (NSArray *)usageOfTransition:(MMTransition *)aTransition;
{
    NSUInteger count, index;
    NSMutableArray *array = [NSMutableArray array];

    count = [rules count];
    for (index = 0; index < count; index++) {
        MMRule *aRule = [rules objectAtIndex:index];
        if ([aRule isTransitionUsed:aTransition]) {
            [array addObject:[NSString stringWithFormat:@"Rule: %lu", index + 1]];
        }
    }

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

//
// Archiving - Degas support
//

- (void)readDegasFileFormat:(FILE *)fp;
{
    [self readParametersFromDegasFile:fp];
    [self writeXMLToFile:@"/tmp/out.xml" comment:@"after reading Degas parameters"];
    [self readCategoriesFromDegasFile:fp];
    [self writeXMLToFile:@"/tmp/out.xml" comment:@"after reading Degas categories"];
    [self readPosturesFromDegasFile:fp];
    [self writeXMLToFile:@"/tmp/out.xml" comment:@"after reading Degas postures"];
    [self readRulesFromDegasFile:fp];
    [self writeXMLToFile:@"/tmp/out.xml" comment:@"after reading Degas rules"];
}

#define SYMBOL_LENGTH_MAX 12
- (void)readParametersFromDegasFile:(FILE *)fp;
{
    NSUInteger i, sampleSize, number_of_phones, number_of_parameters;
    float minValue, maxValue, defaultValue;
    char tempSymbol[SYMBOL_LENGTH_MAX + 1];

    /* READ SAMPLE SIZE FROM FILE  */
    fread((char *)&sampleSize, sizeof(sampleSize), 1, fp);

    /* READ PHONE SYMBOLS FROM FILE  */
    fread((char *)&number_of_phones, sizeof(number_of_phones), 1, fp);
    for (i = 0; i < number_of_phones; i++) {
        fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
    }

    /* READ PARAMETERS FROM FILE  */
    fread((char *)&number_of_parameters, sizeof(number_of_parameters), 1, fp);

    for (i = 0; i < number_of_parameters; i++) {
        bzero(tempSymbol, SYMBOL_LENGTH_MAX + 1);
        fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
        NSString *str = [NSString stringWithASCIICString:tempSymbol];

        fread(&minValue,     sizeof(float), 1, fp);
        fread(&maxValue,     sizeof(float), 1, fp);
        fread(&defaultValue, sizeof(float), 1, fp);

        MMParameter *newParameter = [[MMParameter alloc] init];
        [newParameter setName:str];
        [newParameter setMinimumValue:minValue];
        [newParameter setMaximumValue:maxValue];
        [newParameter setDefaultValue:defaultValue];
        [self addParameter:newParameter];
        [newParameter release];
    }
}

- (void)readCategoriesFromDegasFile:(FILE *)fp;
{
    int32_t count;

    /* Load in the count */
    fread(&count, sizeof(int32_t), 1, fp);

    for (NSUInteger i = 0; i < count; i++) {
        char symbolString[SYMBOL_LENGTH_MAX+1];
        fread(symbolString, SYMBOL_LENGTH_MAX+1, 1, fp);

        NSString *str = [NSString stringWithASCIICString:symbolString];
        MMCategory *newCategory = [[[MMCategory alloc] init] autorelease];
        [newCategory setName:str];
        [self addCategory:newCategory];
    }

    // TODO (2004-03-19): Make sure it's in the "phone" category
}

- (void)readPosturesFromDegasFile:(FILE *)fp;
{
    NSUInteger j, symbolIndex;

    MMSymbol *durationSymbol = [self symbolWithName:@"duration"];
    if (durationSymbol == nil) {
        MMSymbol *newSymbol = [[[MMSymbol alloc] init] autorelease];
        [newSymbol setName:@"duration"];
        [self addSymbol:newSymbol];
        symbolIndex = [symbols indexOfObject:newSymbol];
    } else
        symbolIndex = [symbols indexOfObject:durationSymbol];

    /* READ # OF PHONES AND TARGETS FROM FILE  */
    int32_t phoneCount, targetCount;
    fread(&phoneCount,  sizeof(int32_t), 1, fp);
    fread(&targetCount, sizeof(int32_t), 1, fp);

    /* READ PHONE DESCRIPTION FROM FILE  */
    for (NSUInteger i = 0; i < phoneCount; i++) {
        char tempSymbol[SYMBOL_LENGTH_MAX + 1];
        fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
        NSString *str = [NSString stringWithASCIICString:tempSymbol];

        MMPosture *newPhone = [[MMPosture alloc] initWithModel:self];
        [newPhone setName:str];
        [self addPosture:newPhone];

        int32_t tempDuration, tempType, tempFixed;
        float tempProp;
        /* READ SYMBOL AND DURATIONS FROM FILE  */
        fread(&tempDuration, sizeof(int32_t), 1, fp);
        fread(&tempType,     sizeof(int32_t), 1, fp);
        fread(&tempFixed,    sizeof(int32_t), 1, fp);
        fread(&tempProp,     sizeof(int32_t), 1, fp);

        MMTarget *tempTarget = [[newPhone symbolTargets] objectAtIndex:symbolIndex];
        [tempTarget setValue:(double)tempDuration isDefault:NO];

        /* READ TARGETS IN FROM FILE  */
        for (j = 0; j < targetCount; j++) {
            tempTarget = [[newPhone parameterTargets] objectAtIndex:j];

            int32_t tempDefault;
            float tempValue;
            /* READ IN DATA FROM FILE  */
            fread(&tempDefault, sizeof(int32_t), 1, fp);
            fread(&tempValue, sizeof(float), 1, fp);

            [tempTarget setValue:tempValue];
            [tempTarget setIsDefault:tempDefault];
        }

        /* READ IN CATEGORIES FROM FILE  */
        int32_t categoryCount;
        fread(&categoryCount, sizeof(int32_t), 1, fp);
        for (j = 0; j < categoryCount; j++) {
            /* READ IN DATA FROM FILE  */
            fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
            str = [NSString stringWithASCIICString:tempSymbol];

            MMCategory *tempCategory = [self categoryWithName:str];
            if (tempCategory != nil)
                [[newPhone categories] addObject:tempCategory];
        }

        [newPhone release];
    }
}

- (void)readRulesFromDegasFile:(FILE *)fp;
{
    NSUInteger numRules;
    NSUInteger i, j, k, l;
    NSUInteger j1, k1, l1;
    NSUInteger dummy;
    NSUInteger tempLength;
    char buffer[1024];
    char buffer1[1024];
    id temp, temp1;
    NSString *bufferStr, *buffer1Str;

    MMBooleanParser *boolParser = [[MMBooleanParser alloc] initWithModel:self];

    /* READ FROM FILE  */
    fread(&numRules, sizeof(int), 1, fp);
    for (i = 0; i < numRules; i++) {
        /* READ SPECIFIER CATEGORY #1 FROM FILE  */
        fread(&tempLength, sizeof(int), 1, fp);
        bzero(buffer, 1024);
        fread(buffer, tempLength + 1, 1, fp);
        bufferStr = [NSString stringWithASCIICString:buffer];
        //NSLog(@"i: %d", i);
        //NSLog(@"bufferStr: %@", bufferStr);
        temp = [boolParser parseString:bufferStr];

        /* READ SPECIFIER CATEGORY #2 FROM FILE  */
        fread(&tempLength, sizeof(int), 1, fp);
        bzero(buffer1, 1024);
        fread(buffer1, tempLength + 1, 1, fp);
        buffer1Str = [NSString stringWithASCIICString:buffer1];
        //NSLog(@"buffer1Str: %@", buffer1Str);
        temp1 = [boolParser parseString:buffer1Str];

        if (temp == nil || temp1 == nil)
            NSLog(@"Error parsing rule: %@ >> %@", bufferStr, buffer1Str);
        else {
            MMRule *newRule = [[[MMRule alloc] init] autorelease];
            [newRule setExpression:temp number:0];
            [newRule setExpression:temp1 number:1];
            [newRule setExpression:nil number:2];
            [newRule setExpression:nil number:3];
            [self addRule:newRule];
        }

        /* READ TRANSITION INTERVALS FROM FILE  */
        fread(&k1, sizeof(int), 1, fp);
        for (j = 0; j < k1; j++) {
            fread(&dummy, sizeof(short int), 1, fp);
            fread(&dummy, sizeof(short int), 1, fp);
            fread(&dummy, sizeof(int), 1, fp);
            fread(&dummy, sizeof(float), 1, fp);
            fread(&dummy, sizeof(float), 1, fp);
        }

        /* READ TRANSITION INTERVAL MODE FROM FILE  */
        fread(&dummy, sizeof(short int), 1, fp);

        /* READ SPLIT MODE FROM FILE  */
        fread(&dummy, sizeof(short int), 1, fp);

        /* READ SPECIAL EVENTS FROM FILE  */
        fread(&j1, sizeof(int), 1, fp);

        for (j = 0; j < j1; j++) {
            /* READ SPECIAL EVENT SYMBOL FROM FILE  */
            fread(buffer, SYMBOL_LENGTH_MAX + 1, 1, fp);

            /* READ SPECIAL EVENT INTERVALS FROM FILE  */
            for (k = 0; k < k1; k++) {

                /* READ SUB-INTERVALS FROM FILE  */
                fread(&l1, sizeof(int), 1, fp);
                for (l = 0; l < l1; l++) {
                    /* READ SUB-INTERVAL PARAMETERS FROM FILE  */
                    fread(&dummy, sizeof(short int), 1, fp);
                    fread(&dummy, sizeof(int), 1, fp);
                    fread(&dummy, sizeof(float), 1, fp);
                }
            }
        }

        /* READ DURATION RULE INFORMATION FROM FILE  */
        fread(&dummy, sizeof(int), 1, fp);
        fread(&dummy, sizeof(int), 1, fp);
    }

    [boolParser release];
}

- (void)writeDataToFile:(FILE *)fp;
{
    [self _writeCategoriesToFile:fp];
    [self _writeParametersToFile:fp];
    [self _writeSymbolsToFile:fp];
    [self _writePosturesToFile:fp];
}

- (void)_writeCategoriesToFile:(FILE *)fp;
{
    NSUInteger count, index;

    fprintf(fp, "Categories\n");
    count = [categories count];
    for (index = 0; index < count; index++) {
        MMCategory *aCategory = [categories objectAtIndex:index];
        fprintf(fp, "%s\n", [[aCategory name] UTF8String]);
        if ([aCategory comment])
            fprintf(fp, "%s\n", [[aCategory comment] UTF8String]);
        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");
}

- (void)_writeParametersToFile:(FILE *)fp;
{
    NSUInteger count, index;

    fprintf(fp, "Parameters\n");
    count = [parameters count];
    for (index = 0; index < count; index++) {
        MMParameter *aParameter = [parameters objectAtIndex:index];
        fprintf(fp, "%s\n", [[aParameter name] UTF8String]);
        fprintf(fp, "Min: %f  Max: %f  Default: %f\n",
                [aParameter minimumValue], [aParameter maximumValue], [aParameter defaultValue]);
        if ([aParameter comment])
            fprintf(fp,"%s\n", [[aParameter comment] UTF8String]);
        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");
}

- (void)_writeSymbolsToFile:(FILE *)fp;
{
    NSUInteger count, index;

    fprintf(fp, "Symbols\n");
    count = [symbols count];
    for (index = 0; index < count; index++) {
        MMSymbol *aSymbol = [symbols objectAtIndex:index];
        fprintf(fp, "%s\n", [[aSymbol name] UTF8String]);
        fprintf(fp, "Min: %f  Max: %f  Default: %f\n",
                [aSymbol minimumValue], [aSymbol maximumValue], [aSymbol defaultValue]);
        if ([aSymbol comment])
            fprintf(fp,"%s\n", [[aSymbol comment] UTF8String]);
        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");
}

- (void)_writePosturesToFile:(FILE *)fp;
{
    NSUInteger count, index;
    NSUInteger j;

    fprintf(fp, "Phones\n");
    count = [postures count];
    for (index = 0; index < count; index++) {
        MMPosture *aPhone = [postures objectAtIndex:index];
        fprintf(fp, "%s\n", [[aPhone name] UTF8String]);
        NSMutableArray *aCategoryList = [aPhone categories];
        for (j = 0; j < [aCategoryList count]; j++) {
            MMCategory *aCategory = [aCategoryList objectAtIndex:j];
            if ([aCategory isNative])
                fprintf(fp, "*%s ", [[aCategory name] UTF8String]);
            else
                fprintf(fp, "%s ", [[aCategory name] UTF8String]);
        }
        fprintf(fp, "\n\n");

        NSMutableArray *aParameterList = [aPhone parameterTargets];
        for (j = 0; j < [aParameterList count] / 2; j++) {
            MMTarget *aParameter = [aParameterList objectAtIndex:j];
            MMParameter *mainParameter = [parameters objectAtIndex:j];
            if ([aParameter isDefault])
                fprintf(fp, "\t%s: *%f\t\t", [[mainParameter name] UTF8String], [aParameter value]);
            else
                fprintf(fp, "\t%s: %f\t\t", [[mainParameter name] UTF8String], [aParameter value]);

            aParameter = [aParameterList objectAtIndex:j+8];
            mainParameter = [parameters objectAtIndex:j+8];
            if ([aParameter isDefault])
                fprintf(fp, "%s: *%f\n", [[mainParameter name] UTF8String], [aParameter value]);
            else
                fprintf(fp, "%s: %f\n", [[mainParameter name] UTF8String], [aParameter value]);
        }
        fprintf(fp, "\n\n");

        NSMutableArray *aSymbolList = [aPhone symbolTargets];
        for (j = 0; j < [aSymbolList count]; j++) {
            MMTarget *aSymbol = [aSymbolList objectAtIndex:j];
            MMSymbol *mainSymbol = [symbols objectAtIndex:j];
            if ([aSymbol isDefault])
                fprintf(fp, "%s: *%f ", [[mainSymbol name] UTF8String], [aSymbol value]);
            else
                fprintf(fp, "%s: %f ", [[mainSymbol name] UTF8String], [aSymbol value]);
        }
        fprintf(fp, "\n\n");

        if ([aPhone comment])
            fprintf(fp,"%s\n", [[aPhone comment] UTF8String]);

        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");
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
