//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MModel.h"

#import <Foundation/Foundation.h>
#import "NSArray-Extensions.h"
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "AppController.h"
#import "CategoryList.h"
#import "MMCategory.h"
#import "MonetList.h"
#import "NamedList.h"
#import "PhoneList.h"
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

#import "MUnarchiver.h"
#import "MXMLParser.h"
#import "MXMLArrayDelegate.h"

// For typedstream compatibility
#import "ParameterList.h"
#import "SymbolList.h"

NSString *MCategoryInUseException = @"MCategoryInUseException";

@implementation MModel

- (id)init;
{
    if ([super init] == nil)
        return nil;

    categories = [[CategoryList alloc] init];
    parameters = [[NSMutableArray alloc] init];
    metaParameters = [[NSMutableArray alloc] init];
    symbols = [[NSMutableArray alloc] init];
    postures = [[NSMutableArray alloc] init];

    equations = [[MonetList alloc] init];
    transitions = [[MonetList alloc] init];
    specialTransitions = [[MonetList alloc] init];

    rules = [[NSMutableArray alloc] init];
#if 0
    // And set up some default values:
    // TODO (2004-05-15): Just load these from a default .monet file
    {
        MMSymbol *newSymbol;
        MMCategory *newCategory;

        newSymbol = [[MMSymbol alloc] initWithSymbol:@"duration"];
        [self addSymbol:newSymbol];
        [newSymbol release];

        newCategory = [[MMCategory alloc] initWithSymbol:@"phone"];
        [newCategory setComment:@"This is the static phone category.  It cannot be changed or removed."];
        [self addCategory:newCategory];
        [newCategory release];

        [self _addDefaultRule];
    }
#endif
    cacheTag = 1;

    synthesisParameters = [[MMSynthesisParameters alloc] init];

    return self;
}

- (void)dealloc;
{
    [categories release];
    [parameters release];
    [metaParameters release];
    [symbols release];
    [postures release];
    [equations release];
    [transitions release];
    [specialTransitions release];
    [rules release];

    [synthesisParameters release];

    [super dealloc];
}

- (void)_addDefaultRule;
{
    MMRule *newRule;
    MMBooleanParser *boolParser;
    MMBooleanNode *expr1, *expr2;

    boolParser = [[MMBooleanParser alloc] initWithModel:self];

    expr1 = [boolParser parseString:@"phone"];
    expr2 = [boolParser parseString:@"phone"];

    [boolParser release];

    newRule = [[MMRule alloc] init];
    [newRule setExpression:expr1 number:0];
    [newRule setExpression:expr2 number:1];
    [newRule setDefaultsTo:[newRule numberExpressions]];
    [self addRule:newRule];
    [newRule release];
}

- (CategoryList *)categories;
{
    return categories;
}

- (NSMutableArray *)parameters;
{
    return parameters;
}

- (NSMutableArray *)metaParameters;
{
    return metaParameters;
}

- (NSMutableArray *)symbols;
{
    return symbols;
}

- (NSMutableArray *)postures;
{
    return postures;
}

- (MonetList *)equations;
{
    return equations;
}

- (MonetList *)transitions;
{
    return transitions;
}

- (MonetList *)specialTransitions;
{
    return specialTransitions;
}

- (NSMutableArray *)rules;
{
    return rules;
}

//
// Categories
//

- (void)addCategory:(MMCategory *)newCategory;
{
    if ([newCategory symbol] == nil)
        [newCategory setSymbol:@"untitled"];

    [self _uniqueNameForCategory:newCategory];

    [categories addObject:newCategory];
    //[categories sortUsingSelector:@selector(compareByAscendingName:)];
    // TODO (2004-03-18): And post notification of new category.
}

- (void)_uniqueNameForCategory:(MMCategory *)newCategory;
{
    NSMutableSet *names;
    int count, index;
    NSString *name, *basename;

    names = [[NSMutableSet alloc] init];
    count = [categories count];
    for (index = 0; index < count; index++) {
        name = [[categories objectAtIndex:index] symbol];
        if (name != nil)
            [names addObject:name];
    }

    name = basename = [newCategory symbol];
    index = 1;
    while ([names containsObject:name] == YES) {
        name = [NSString stringWithFormat:@"%@%d", basename, index++];
    }

    [newCategory setSymbol:name];

    [names release];
}

// TODO (2004-03-19): Is it used by rules, anyway.  Postures can also use categories.
- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    int count, index;

    count = [rules count];
    for (index = 0; index < count; index++) {
        if ([[rules objectAtIndex:index] isCategoryUsed:aCategory])
            return YES;
    }

    return NO;
}

- (void)removeCategory:(MMCategory *)aCategory;
{
    if ([self isCategoryUsed:aCategory] == YES) {
        [NSException raise:MCategoryInUseException format:@"Cannot remove category that is in use."];
    }

    [categories removeObject:aCategory];
}

// TODO (2004-03-19): We could store these in a dictionary for quick lookup by name.
- (MMCategory *)categoryWithName:(NSString *)aName;
{
    int count, index;
    MMCategory *aCategory;

    count = [categories count];
    for (index = 0; index < count; index++) {
        aCategory = [categories objectAtIndex:index];
        if ([[aCategory symbol] isEqual:aName])
            return aCategory;
    }

    return nil;
}

//
// Parameters
//

- (void)addParameter:(MMParameter *)newParameter;
{
    if ([newParameter symbol] == nil)
        [newParameter setSymbol:@"untitled"];

    [self _uniqueNameForParameter:newParameter inList:parameters];

    [parameters addObject:newParameter];
    [newParameter setModel:self];
    [self _addDefaultPostureTargetsForParameter:newParameter];
    [rules makeObjectsPerformSelector:@selector(addDefaultParameter)];
}

// TODO (2004-03-19): When MMParameter and MMSymbol are the same class, this can be shared
- (void)_uniqueNameForParameter:(MMParameter *)newParameter inList:(NSMutableArray *)aParameterList;
{
    NSMutableSet *names;
    int count, index;
    NSString *name, *basename;

    names = [[NSMutableSet alloc] init];
    count = [aParameterList count];
    for (index = 0; index < count; index++) {
        name = [[aParameterList objectAtIndex:index] symbol];
        if (name != nil)
            [names addObject:name];
    }

    name = basename = [newParameter symbol];
    index = 1;
    while ([names containsObject:name] == YES) {
        name = [NSString stringWithFormat:@"%@%d", basename, index++];
    }

    [newParameter setSymbol:name];

    [names release];
}

- (void)_addDefaultPostureTargetsForParameter:(MMParameter *)newParameter;
{
    unsigned int count, index;
    double value;

    value = [newParameter defaultValue];
    count = [postures count];
    for (index = 0; index < count; index++) {
        MMTarget *newTarget;

        newTarget = [[MMTarget alloc] initWithValue:value isDefault:YES];
        [[postures objectAtIndex:index] addParameterTarget:newTarget];
        [newTarget release];
    }
}

- (void)removeParameter:(MMParameter *)aParameter;
{
    unsigned int parameterIndex;

    parameterIndex  = [parameters indexOfObject:aParameter];
    if (parameterIndex != NSNotFound) {
        int count, index;

        count = [postures count];
        for (index = 0; index < count; index++)
            [[postures objectAtIndex:index] removeParameterTargetAtIndex:parameterIndex];

        count = [rules count];
        for (index = 0; index < count; index++)
            [[rules objectAtIndex:index] removeParameterAtIndex:parameterIndex];

        [parameters removeObject:aParameter];
    }
}

//
// Meta Parameters
//

- (void)addMetaParameter:(MMParameter *)newParameter;
{
    if ([newParameter symbol] == nil)
        [newParameter setSymbol:@"untitled"];

    [self _uniqueNameForParameter:newParameter inList:metaParameters];

    [metaParameters addObject:newParameter];
    [newParameter setModel:self];
    [self _addDefaultPostureTargetsForMetaParameter:newParameter];
    [rules makeObjectsPerformSelector:@selector(addDefaultMetaParameter)];
}

- (void)_addDefaultPostureTargetsForMetaParameter:(MMParameter *)newParameter;
{
    unsigned int count, index;
    double value;

    value = [newParameter defaultValue];
    count = [postures count];
    for (index = 0; index < count; index++) {
        MMTarget *newTarget;

        newTarget = [[MMTarget alloc] initWithValue:value isDefault:YES];
        [[postures objectAtIndex:index] addMetaParameterTarget:newTarget];
        [newTarget release];
    }
}

- (void)removeMetaParameter:(MMParameter *)aParameter;
{
    unsigned int parameterIndex;

    parameterIndex  = [metaParameters indexOfObject:aParameter];
    if (parameterIndex != NSNotFound) {
        int count, index;

        count = [postures count];
        for (index = 0; index < count; index++)
            [[postures objectAtIndex:index] removeMetaParameterTargetAtIndex:parameterIndex];

        count = [rules count];
        for (index = 0; index < count; index++)
            [[rules objectAtIndex:index] removeMetaParameterAtIndex:parameterIndex];

        [metaParameters removeObject:aParameter];
    }
}

//
// Symbols
//

- (void)addSymbol:(MMSymbol *)newSymbol;
{
    if ([newSymbol symbol] == nil)
        [newSymbol setSymbol:@"untitled"];

    [self _uniqueNameForSymbol:newSymbol];

    [symbols addObject:newSymbol];
    [newSymbol setModel:self];
    [self _addDefaultPostureTargetsForSymbol:newSymbol];
}

- (void)_uniqueNameForSymbol:(MMSymbol *)newSymbol;
{
    NSMutableSet *names;
    int count, index;
    NSString *name, *basename;

    names = [[NSMutableSet alloc] init];
    count = [symbols count];
    for (index = 0; index < count; index++) {
        name = [[symbols objectAtIndex:index] symbol];
        if (name != nil)
            [names addObject:name];
    }

    name = basename = [newSymbol symbol];
    index = 1;
    while ([names containsObject:name] == YES) {
        name = [NSString stringWithFormat:@"%@%d", basename, index++];
    }

    [newSymbol setSymbol:name];

    [names release];
}

- (void)_addDefaultPostureTargetsForSymbol:(MMSymbol *)newSymbol;
{
    unsigned int count, index;
    double value;

    value = [newSymbol defaultValue];
    count = [postures count];
    for (index = 0; index < count; index++) {
        MMTarget *newTarget;

        newTarget = [[MMTarget alloc] initWithValue:value isDefault:YES];
        [[postures objectAtIndex:index] addSymbolTarget:newTarget];
        [newTarget release];
    }
}

- (void)removeSymbol:(MMSymbol *)aSymbol;
{
    unsigned int symbolIndex;

    symbolIndex = [symbols indexOfObject:aSymbol];
    if (symbolIndex != NSNotFound) {
        unsigned int count, index;

        count = [postures count];
        for (index = 0; index < count; index++)
            [[postures objectAtIndex:index] removeSymbolTargetAtIndex:symbolIndex];

        [symbols removeObject:aSymbol];
    }
}

- (MMSymbol *)symbolWithName:(NSString *)aName;
{
    unsigned int count, index;

    count = [symbols count];
    for (index = 0; index < count; index++) {
        MMSymbol *aSymbol;

        aSymbol = [symbols objectAtIndex:index];
        if ([[aSymbol symbol] isEqual:aName] == YES)
            return aSymbol;
    }

    return nil;
}

//
// Postures
//

- (void)addPosture:(MMPosture *)newPosture;
{
    if ([newPosture symbol] == nil)
        [newPosture setSymbol:@"untitled"];

    [newPosture setModel:self];
    [self _uniqueNameForPosture:newPosture];

    [postures addObject:newPosture];
    [self sortPostures];
}

- (void)_uniqueNameForPosture:(MMPosture *)newPosture;
{
    NSMutableSet *names;
    int count, index;
    NSString *name, *basename;
    BOOL isUsed;

    names = [[NSMutableSet alloc] init];
    count = [postures count];
    for (index = 0; index < count; index++) {
        name = [[postures objectAtIndex:index] symbol];
        if (name != nil)
            [names addObject:name];
    }

    index = 1;
    name = basename = [newPosture symbol];
    isUsed = [names containsObject:name];

    if (isUsed == YES) {
        char ch1, ch2;

        for (ch1 = 'A'; isUsed == YES && ch1 <= 'Z'; ch1++) {
            name = [NSString stringWithFormat:@"%@%c", basename, ch1];
            isUsed = [names containsObject:name];
        }

        for (ch1 = 'A'; isUsed == YES && ch1 <= 'Z'; ch1++) {
            for (ch2 = 'A'; isUsed == YES && ch2 <= 'Z'; ch2++) {
                name = [NSString stringWithFormat:@"%@%c%c", basename, ch1, ch2];
                isUsed = [names containsObject:name];
            }
        }
    }

    while ([names containsObject:name] == YES) {
        name = [NSString stringWithFormat:@"%@%d", basename, index++];
    }

    [newPosture setSymbol:name];

    [names release];
}

- (void)removePosture:(MMPosture *)aPosture;
{
    [postures removeObject:aPosture];

    // TODO (2004-03-20): Make sure it isn't used by any rules?
}

- (void)sortPostures;
{
    [postures sortUsingSelector:@selector(compareByAscendingName:)];
}

- (MMPosture *)postureWithName:(NSString *)aName;
{
    int count, index;
    MMPosture *aPosture;

    count = [postures count];
    for (index = 0; index < count; index++) {
        aPosture = [postures objectAtIndex:index];
        if ([[aPosture symbol] isEqual:aName])
            return aPosture;
    }

    return nil;
}

- (void)addEquationGroup:(NamedList *)newGroup;
{
    [equations addObject:newGroup];
    [newGroup setModel:self];
}

- (void)addTransitionGroup:(NamedList *)newGroup;
{
    [transitions addObject:newGroup];
    [newGroup setModel:self];
}

- (void)addSpecialTransitionGroup:(NamedList *)newGroup;
{
    [specialTransitions addObject:newGroup];
    [newGroup setModel:self];
}

// This will require that all the equation names be unique.  Otherwise we'll need to store the group in the XML file as well.
- (MMEquation *)findEquationWithName:(NSString *)anEquationName;
{
    unsigned int groupCount, groupIndex;
    unsigned int count, index;

    groupCount = [equations count];
    for (groupIndex = 0; groupIndex < groupCount; groupIndex++) {
        NamedList *currentGroup;

        currentGroup = [equations objectAtIndex:groupIndex];
        count = [currentGroup count];
        for (index = 0; index < count; index++) {
            MMEquation *anEquation;

            anEquation = [currentGroup objectAtIndex:index];
            if ([anEquationName isEqualToString:[anEquation name]])
                return anEquation;
        }
    }

    return nil;
}

- (MMTransition *)findTransitionWithName:(NSString *)aTransitionName;
{
    unsigned int groupCount, groupIndex;
    unsigned int count, index;

    groupCount = [transitions count];
    for (groupIndex = 0; groupIndex < groupCount; groupIndex++) {
        NamedList *currentGroup;

        currentGroup = [transitions objectAtIndex:groupIndex];
        count = [currentGroup count];
        for (index = 0; index < count; index++) {
            MMTransition *aTransition;

            aTransition = [currentGroup objectAtIndex:index];
            if ([aTransitionName isEqualToString:[aTransition name]])
                return aTransition;
        }
    }

    return nil;
}

- (MMTransition *)findSpecialTransitionWithName:(NSString *)aTransitionName;
{
    unsigned int groupCount, groupIndex;
    unsigned int count, index;

    groupCount = [specialTransitions count];
    for (groupIndex = 0; groupIndex < groupCount; groupIndex++) {
        NamedList *currentGroup;

        currentGroup = [specialTransitions objectAtIndex:groupIndex];
        count = [currentGroup count];
        for (index = 0; index < count; index++) {
            MMTransition *aTransition;

            aTransition = [currentGroup objectAtIndex:index];
            if ([aTransitionName isEqualToString:[aTransition name]])
                return aTransition;
        }
    }

    return nil;
}

// TODO (2004-03-06): Find equation named "named" in list named "list"
// Change to findEquationNamed:(NSString *)anEquationName inList:(NSString *)aListName;
// TODO (2004-03-06): Merge these three sets of methods, since they're practically identical.
- (MMEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
{
    int i, j;

    for (i = 0 ; i < [equations count]; i++) {
        NamedList *currentList;

        currentList = [equations objectAtIndex:i];
        if ([aListName isEqualToString:[currentList name]]) {
            for (j = 0; j < [currentList count]; j++) {
                MMEquation *anEquation;

                anEquation = [currentList objectAtIndex:j];
                if ([anEquationName isEqualToString:[anEquation name]])
                    return anEquation;
            }
        }
    }

    NSLog(@"Couldn't find equation: %@/%@", aListName, anEquationName);

    return nil;
}

- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(MMEquation *)anEquation;
{
    int i, temp;

    for (i = 0 ; i < [equations count]; i++) {
        temp = [[equations objectAtIndex:i] indexOfObject:anEquation];
        if (temp != NSNotFound) {
            *listIndex = i;
            *equationIndex = temp;
            return;
        }
    }

    *listIndex = -1;
    // TODO (2004-03-06): This might be where/how the large list indexes were archived.
}

- (MMEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;
{
    //NSLog(@"-> %s, listIndex: %d, index: %d", _cmd, listIndex, index);
    if (listIndex < 0 || listIndex > [equations count]) {
        NSLog(@"-[%@ %s]: listIndex: %d out of range.  index: %d", NSStringFromClass([self class]), _cmd, listIndex, index);
        return nil;
    }

    return [[equations objectAtIndex:listIndex] objectAtIndex:equationIndex];
}

- (MMTransition *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
{
    int i, j;

    for (i = 0 ; i < [transitions count]; i++) {
        NamedList *currentList;

        currentList = [transitions objectAtIndex:i];
        if ([aListName isEqualToString:[currentList name]]) {
            for (j = 0; j < [currentList count]; j++) {
                MMTransition *aTransition;

                aTransition = [currentList objectAtIndex:j];
                if ([aTransitionName isEqualToString:[aTransition name]])
                    return aTransition;
            }
        }
    }

    NSLog(@"Couldn't find transition: %@/%@", aListName, aTransitionName);

    return nil;
}

- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(MMTransition *)aTransition;
{
    int i, temp;

    for (i = 0 ; i < [transitions count]; i++) {
        temp = [[transitions objectAtIndex:i] indexOfObject:aTransition];
        if (temp != NSNotFound) {
            *listIndex = i;
            *transitionIndex = temp;
            return;
        }
    }

    *listIndex = -1;
}

- (MMTransition *)findTransition:(int)listIndex andIndex:(int)transitionIndex;
{
    //NSLog(@"Name: %@ (%d)\n", [[transitions objectAtIndex: listIndex] name], listIndex);
    //NSLog(@"\tCount: %d  index: %d  count: %d\n", [transitions count], index, [[transitions objectAtIndex: listIndex] count]);
    return [[transitions objectAtIndex:listIndex] objectAtIndex:transitionIndex];
}

- (MMTransition *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
{
    int i, j;

    for (i = 0 ; i < [specialTransitions count]; i++) {
        NamedList *currentList;

        currentList = [specialTransitions objectAtIndex:i];
        if ([aListName isEqualToString:[currentList name]]) {
            for (j = 0; j < [currentList count]; j++) {
                MMTransition *aTransition;

                aTransition = [currentList objectAtIndex:j];
                if ([aSpecialName isEqualToString:[aTransition name]])
                    return aTransition;
            }
        }
    }

    NSLog(@"Couldn't find special transition: %@/%@", aListName, aSpecialName);

    return nil;
}

- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(MMTransition *)aTransition;
{
    int i, temp;

    for (i = 0 ; i < [specialTransitions count]; i++) {
        temp = [[specialTransitions objectAtIndex:i] indexOfObject:aTransition];
        if (temp != NSNotFound) {
            *listIndex = i;
            *specialIndex = temp;
            return;
        }
    }

    *listIndex = -1;
}

- (MMTransition *)findSpecial:(int)listIndex andIndex:(int)specialIndex;
{
    return [[specialTransitions objectAtIndex:listIndex] objectAtIndex:specialIndex];
}

- (NSArray *)usageOfEquation:(MMEquation *)anEquation;
{
    NSMutableArray *array;
    int count, index;
    MMRule *aRule;
    NamedList *aGroup;
    MMTransition *aTransition;

    array = [NSMutableArray array];
    count = [rules count];
    for (index = 0; index < count; index++) {
        aRule = [rules objectAtIndex:index];
        if ([aRule isEquationUsed:anEquation]) {
            [array addObject:[NSString stringWithFormat:@"Rule: %d", index + 1]];
        }
    }

    count = [transitions count];
    for (index = 0; index < count; index++) {
        unsigned transitionCount, transitionIndex;

        aGroup = [transitions objectAtIndex:index];
        transitionCount = [aGroup count];
        for (transitionIndex = 0; transitionIndex < transitionCount; transitionIndex++) {
            aTransition = [aGroup objectAtIndex:transitionIndex];
            if ([aTransition isEquationUsed:anEquation]) {
                [array addObject:[NSString stringWithFormat:@"T:%@:%@", [[aTransition group] name], [aTransition name]]];
            }
        }
    }

    count = [specialTransitions count];
    for (index = 0; index < count; index++) {
        unsigned transitionCount, transitionIndex;

        aGroup = [specialTransitions objectAtIndex:index];
        transitionCount = [aGroup count];
        for (transitionIndex = 0; transitionIndex < transitionCount; transitionIndex++) {
            aTransition = [aGroup objectAtIndex:transitionIndex];
            if ([aTransition isEquationUsed:anEquation]) {
                [array addObject:[NSString stringWithFormat:@"S:%@:%@", [[aTransition group] name], [aTransition name]]];
            }
        }
    }

    return array;
}


- (NSArray *)usageOfTransition:(MMTransition *)aTransition;
{
    NSMutableArray *array;
    unsigned int count, index;
    MMRule *aRule;

    array = [NSMutableArray array];

    count = [rules count];
    for (index = 0; index < count; index++) {
        aRule = [rules objectAtIndex:index];
        if ([aRule isTransitionUsed:aTransition]) {
            [array addObject:[NSString stringWithFormat:@"Rule: %d", index + 1]];
        }
    }

    return array;
}

//
// Rules
//

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
- (MMRule *)findRuleMatchingCategories:(NSArray *)categoryLists ruleIndex:(int *)indexPtr;
{
    unsigned int count, index;

    count = [rules count];
    assert(count > 0);
    for (index = 0; index < count; index++) {
        MMRule *rule;

        rule = [rules objectAtIndex:index];
        if ([rule numberExpressions] <= [categoryLists count])
            if ([rule matchRule:categoryLists]) {
                if (indexPtr != NULL)
                    *indexPtr = index;
                return rule;
            }
    }

    // This assumes that the last object will always be the "phone >> phone" rule, but that should have been matched above.
    // TODO (2004-08-01): But what if there are no rules?
    if (indexPtr != NULL)
        *indexPtr = count - 1;
    return [rules lastObject];
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    [(MUnarchiver *)aDecoder setUserInfo:self];

    /* Category list must be named immediately */
    categories = [[aDecoder decodeObject] retain];
    //[categories sortUsingSelector:@selector(compareByAscendingName:)];

    //NSLog(@"categories: %@", categories);
    //NSLog(@"categories: %d", [categories count]);

    {
        SymbolList *archivedSymbols;

        archivedSymbols = [aDecoder decodeObject];
        symbols = [[NSMutableArray alloc] init];
        [symbols addObjectsFromArray:[archivedSymbols allObjects]];
    }
    //NSLog(@"symbols: %@", symbols);
    //NSLog(@"symbols: %d", [symbols count]);
    [symbols makeObjectsPerformSelector:@selector(setModel:) withObject:self];

    {
        ParameterList *archivedParameters;

        archivedParameters = [aDecoder decodeObject];
        parameters = [[NSMutableArray alloc] init];
        [parameters addObjectsFromArray:[archivedParameters allObjects]];
    }
    //NSLog(@"parameters: %@", parameters);
    //NSLog(@"parameters: %d", [parameters count]);
    [parameters makeObjectsPerformSelector:@selector(setModel:) withObject:self];

    {
        ParameterList *archivedMetaParameters;

        archivedMetaParameters = [aDecoder decodeObject];
        metaParameters = [[NSMutableArray alloc] init];
        [metaParameters addObjectsFromArray:[archivedMetaParameters allObjects]];
    }
    //NSLog(@"metaParameters: %@", metaParameters);
    //NSLog(@"metaParameters: %d", [metaParameters count]);
    [metaParameters makeObjectsPerformSelector:@selector(setModel:) withObject:self];

    {
        PhoneList *archivedPostures;

        archivedPostures = [aDecoder decodeObject];
        postures = [[NSMutableArray alloc] init];
        [postures addObjectsFromArray:[archivedPostures allObjects]];
    }
    //NSLog(@"postures: %@", postures);
    //NSLog(@"postures: %d", [postures count]);
    [postures makeObjectsPerformSelector:@selector(setModel:) withObject:self];

    equations = [[aDecoder decodeObject] retain];
    //NSLog(@"equations: %d", [equations count]);

    transitions = [[aDecoder decodeObject] retain];
    //NSLog(@"transitions: %d", [transitions count]);

    specialTransitions = [[aDecoder decodeObject] retain];
    //NSLog(@"specialTransitions: %d", [specialTransitions count]);

    {
        MonetList *archivedRules;

        archivedRules = [aDecoder decodeObject];
        rules = [[NSMutableArray alloc] init];
        [rules addObjectsFromArray:[archivedRules allObjects]];
    }
    //NSLog(@"rules: %d", [rules count]);
    [rules makeObjectsPerformSelector:@selector(setModel:) withObject:self];

    synthesisParameters = [[MMSynthesisParameters alloc] init];

    return self;
}

// TODO (2004-03-18): Replace with xml file that contains complete info
- (void)readPrototypes:(NSCoder *)aDecoder;
{
    [equations release];
    equations = [[aDecoder decodeObject] retain];

    [transitions release];
    transitions = [[aDecoder decodeObject] retain];

    [specialTransitions release];
    specialTransitions = [[aDecoder decodeObject] retain];
}

- (BOOL)importPostureNamed:(NSString *)postureName fromTRMData:(NSCoder *)aDecoder;
{
    TRMData *trmData;
    MMPosture *newPosture;
    NSMutableArray *parameterTargets;

    trmData = [[TRMData alloc] init];
    if ([trmData readFromCoder:aDecoder] == NO) {
        [trmData release];
        return NO;
    }

    newPosture = [[MMPosture alloc] initWithModel:self];
    [newPosture setSymbol:postureName];
    [self addPosture:newPosture];

    parameterTargets = [newPosture parameterTargets];

    // TODO (2004-03-25): These used to set the default flag as well, but I plan to remove that flag.
    // TODO (2004-03-25): Look up parameter indexes by name, so this will still work if they get rearranged in the Monet file.
    [[parameterTargets objectAtIndex:0] setValue:[trmData glotPitch]];
    [[parameterTargets objectAtIndex:1] setValue:[trmData glotVol]];
    [[parameterTargets objectAtIndex:2] setValue:[trmData aspVol]];
    [[parameterTargets objectAtIndex:3] setValue:[trmData fricVol]];
    [[parameterTargets objectAtIndex:4] setValue:[trmData fricPos]];
    [[parameterTargets objectAtIndex:5] setValue:[trmData fricCF]];
    [[parameterTargets objectAtIndex:6] setValue:[trmData fricBW]];
    [[parameterTargets objectAtIndex:7] setValue:[trmData r1]];
    [[parameterTargets objectAtIndex:8] setValue:[trmData r2]];
    [[parameterTargets objectAtIndex:9] setValue:[trmData r3]];
    [[parameterTargets objectAtIndex:10] setValue:[trmData r4]];
    [[parameterTargets objectAtIndex:11] setValue:[trmData r5]];
    [[parameterTargets objectAtIndex:12] setValue:[trmData r6]];
    [[parameterTargets objectAtIndex:13] setValue:[trmData r7]];
    [[parameterTargets objectAtIndex:14] setValue:[trmData r8]];
    [[parameterTargets objectAtIndex:15] setValue:[trmData velum]];

    NSLog(@"Imported posture \"%@\"", [newPosture symbol]);
    [newPosture release];
    [trmData release];

    return YES;
}

//
// Archiving - XML
//

- (BOOL)writeXMLToFile:(NSString *)aFilename comment:(NSString *)aComment;
{
    NSMutableString *resultString;
    BOOL result;

    resultString = [[NSMutableString alloc] init];
    [resultString appendString:@"<?xml version='1.0' encoding='utf-8'?>\n"];
    [resultString appendString:@"<!DOCTYPE root PUBLIC \"\" \"monet-v1.dtd\">\n"];
    if (aComment != nil)
        [resultString appendFormat:@"<!-- %@ -->\n", aComment];
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
    result = [[resultString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:aFilename atomically:YES];

    [resultString release];

    return result;
}

- (void)_appendXMLForEquationsToString:(NSMutableString *)resultString level:(int)level;
{
    NamedList *namedList;
    int count, index;

    [resultString indentToLevel:level];
    [resultString appendString:@"<equations>\n"];
    count = [equations count];
    for (index = 0; index < count; index++) {
        namedList = [equations objectAtIndex:index];
        [namedList appendXMLToString:resultString elementName:@"equation-group" level:level + 1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</equations>\n"];
}

- (void)_appendXMLForTransitionsToString:(NSMutableString *)resultString level:(int)level;
{
    NamedList *namedList;
    int count, index;

    [resultString indentToLevel:level];
    [resultString appendString:@"<transitions>\n"];
    count = [transitions count];
    for (index = 0; index < count; index++) {
        namedList = [transitions objectAtIndex:index];
        [namedList appendXMLToString:resultString elementName:@"transition-group" level:level + 1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</transitions>\n"];
}

- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(int)level;
{
    NamedList *namedList;
    int count, index;

    [resultString indentToLevel:level];
    [resultString appendString:@"<special-transitions>\n"];
    count = [specialTransitions count];
    for (index = 0; index < count; index++) {
        namedList = [specialTransitions objectAtIndex:index];
        [namedList appendXMLToString:resultString elementName:@"transition-group" level:level + 1];
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
    int i, sampleSize, number_of_phones, number_of_parameters;
    float minValue, maxValue, defaultValue;
    char tempSymbol[SYMBOL_LENGTH_MAX + 1];
    NSString *str;

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
        MMParameter *newParameter;

        bzero(tempSymbol, SYMBOL_LENGTH_MAX + 1);
        fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
        str = [NSString stringWithASCIICString:tempSymbol];

        fread(&minValue, sizeof(float), 1, fp);
        fread(&maxValue, sizeof(float), 1, fp);
        fread(&defaultValue, sizeof(float), 1, fp);

        newParameter = [[MMParameter alloc] initWithSymbol:str];
        [newParameter setMinimumValue:minValue];
        [newParameter setMaximumValue:maxValue];
        [newParameter setDefaultValue:defaultValue];
        [self addParameter:newParameter];
        [newParameter release];
    }
}

- (void)readCategoriesFromDegasFile:(FILE *)fp;
{
    int i, count;

    MMCategory *newCategory;
    char symbolString[SYMBOL_LENGTH_MAX+1];
    NSString *str;

    /* Load in the count */
    fread(&count, sizeof(int), 1, fp);

    for (i = 0; i < count; i++) {
        fread(symbolString, SYMBOL_LENGTH_MAX+1, 1, fp);

        str = [NSString stringWithASCIICString:symbolString];
        newCategory = [[MMCategory alloc] initWithSymbol:str];
        [self addCategory:newCategory];
        [newCategory release];
    }

    // TODO (2004-03-19): Make sure it's in the "phone" category
}

- (void)readPosturesFromDegasFile:(FILE *)fp;
{
    int i, j, symbolIndex;
    int phoneCount, targetCount, categoryCount;

    int tempDuration, tempType, tempFixed;
    float tempProp;

    int tempDefault;
    float tempValue;

    MMPosture *newPhone;
    MMCategory *tempCategory;
    MMTarget *tempTarget;
    char tempSymbol[SYMBOL_LENGTH_MAX + 1];
    NSString *str;
    MMSymbol *durationSymbol;

    durationSymbol = [self symbolWithName:@"duration"];
    if (durationSymbol == nil) {
        MMSymbol *newSymbol;

        newSymbol = [[MMSymbol alloc] initWithSymbol:@"duration"];
        [self addSymbol:newSymbol];
        symbolIndex = [symbols indexOfObject:newSymbol];
        [newSymbol release];
    } else
        symbolIndex = [symbols indexOfObject:durationSymbol];

    /* READ # OF PHONES AND TARGETS FROM FILE  */
    fread(&phoneCount, sizeof(int), 1, fp);
    fread(&targetCount, sizeof(int), 1, fp);

    /* READ PHONE DESCRIPTION FROM FILE  */
    for (i = 0; i < phoneCount; i++) {
        fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
        str = [NSString stringWithASCIICString:tempSymbol];

        newPhone = [[MMPosture alloc] initWithModel:self];
        [newPhone setSymbol:str];
        [self addPosture:newPhone];

        /* READ SYMBOL AND DURATIONS FROM FILE  */
        fread(&tempDuration, sizeof(int), 1, fp);
        fread(&tempType, sizeof(int), 1, fp);
        fread(&tempFixed, sizeof(int), 1, fp);
        fread(&tempProp, sizeof(int), 1, fp);

        tempTarget = [[newPhone symbolTargets] objectAtIndex:symbolIndex];
        [tempTarget setValue:(double)tempDuration isDefault:NO];

        /* READ TARGETS IN FROM FILE  */
        for (j = 0; j < targetCount; j++) {
            tempTarget = [[newPhone parameterTargets] objectAtIndex:j];

            /* READ IN DATA FROM FILE  */
            fread(&tempDefault, sizeof(int), 1, fp);
            fread(&tempValue, sizeof(float), 1, fp);

            [tempTarget setValue:tempValue];
            [tempTarget setIsDefault:tempDefault];
        }

        /* READ IN CATEGORIES FROM FILE  */
        fread(&categoryCount, sizeof(int), 1, fp);
        for (j = 0; j < categoryCount; j++) {
            /* READ IN DATA FROM FILE  */
            fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
            str = [NSString stringWithASCIICString:tempSymbol];

            tempCategory = [self categoryWithName:str];
            if (tempCategory != nil)
                [[newPhone categories] addObject:tempCategory];
        }

        [newPhone release];
    }
}

- (void)readRulesFromDegasFile:(FILE *)fp;
{
    int numRules;
    int i, j, k, l;
    int j1, k1, l1;
    int dummy;
    int tempLength;
    char buffer[1024];
    char buffer1[1024];
    MMBooleanParser *boolParser;
    id temp, temp1;
    NSString *bufferStr, *buffer1Str;

    boolParser = [[MMBooleanParser alloc] initWithModel:self];

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
            MMRule *newRule;

            newRule = [[MMRule alloc] init];
            [newRule setExpression:temp number:0];
            [newRule setExpression:temp1 number:1];
            [newRule setExpression:nil number:2];
            [newRule setExpression:nil number:3];
            [self addRule:newRule];
            [newRule release];
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
    unsigned count, index;

    fprintf(fp, "Categories\n");
    count = [categories count];
    for (index = 0; index < count; index++) {
        MMCategory *aCategory;

        aCategory = [categories objectAtIndex:index];
        fprintf(fp, "%s\n", [[aCategory symbol] UTF8String]);
        if ([aCategory comment])
            fprintf(fp, "%s\n", [[aCategory comment] UTF8String]);
        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");
}

- (void)_writeParametersToFile:(FILE *)fp;
{
    unsigned count, index;

    fprintf(fp, "Parameters\n");
    count = [parameters count];
    for (index = 0; index < count; index++) {
        MMParameter *aParameter;

        aParameter = [parameters objectAtIndex:index];
        fprintf(fp, "%s\n", [[aParameter symbol] UTF8String]);
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
    unsigned count, index;

    fprintf(fp, "Symbols\n");
    count = [symbols count];
    for (index = 0; index < count; index++) {
        MMSymbol *aSymbol;

        aSymbol = [symbols objectAtIndex:index];
        fprintf(fp, "%s\n", [[aSymbol symbol] UTF8String]);
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
    unsigned count, index;
    int j;

    fprintf(fp, "Phones\n");
    count = [postures count];
    for (index = 0; index < count; index++) {
        MMPosture *aPhone;
        CategoryList *aCategoryList;
        NSMutableArray *aParameterList, *aSymbolList;

        aPhone = [postures objectAtIndex:index];
        fprintf(fp, "%s\n", [[aPhone symbol] UTF8String]);
        aCategoryList = [aPhone categories];
        for (j = 0; j < [aCategoryList count]; j++) {
            MMCategory *aCategory;

            aCategory = [aCategoryList objectAtIndex:j];
            if ([aCategory isNative])
                fprintf(fp, "*%s ", [[aCategory symbol] UTF8String]);
            else
                fprintf(fp, "%s ", [[aCategory symbol] UTF8String]);
        }
        fprintf(fp, "\n\n");

        aParameterList = [aPhone parameterTargets];
        for (j = 0; j < [aParameterList count] / 2; j++) {
            MMParameter *mainParameter;
            MMTarget *aParameter;

            aParameter = [aParameterList objectAtIndex:j];
            mainParameter = [parameters objectAtIndex:j];
            if ([aParameter isDefault])
                fprintf(fp, "\t%s: *%f\t\t", [[mainParameter symbol] UTF8String], [aParameter value]);
            else
                fprintf(fp, "\t%s: %f\t\t", [[mainParameter symbol] UTF8String], [aParameter value]);

            aParameter = [aParameterList objectAtIndex:j+8];
            mainParameter = [parameters objectAtIndex:j+8];
            if ([aParameter isDefault])
                fprintf(fp, "%s: *%f\n", [[mainParameter symbol] UTF8String], [aParameter value]);
            else
                fprintf(fp, "%s: %f\n", [[mainParameter symbol] UTF8String], [aParameter value]);
        }
        fprintf(fp, "\n\n");

        aSymbolList = [aPhone symbolTargets];
        for (j = 0; j < [aSymbolList count]; j++) {
            MMSymbol *mainSymbol;
            MMTarget *aSymbol;

            aSymbol = [aSymbolList objectAtIndex:j];
            mainSymbol = [symbols objectAtIndex:j];
            if ([aSymbol isDefault])
                fprintf(fp, "%s: *%f ", [[mainSymbol symbol] UTF8String], [aSymbol value]);
            else
                fprintf(fp, "%s: %f ", [[mainSymbol symbol] UTF8String], [aSymbol value]);
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

- (void)parameter:(MMParameter *)aParameter willChangeDefaultValue:(double)newDefaultValue;
{
    double oldDefaultValue;
    unsigned int count, index;
    unsigned int parameterIndex;

    oldDefaultValue = [aParameter defaultValue];
    count = [postures count];

    parameterIndex = [parameters indexOfObject:aParameter];
    if (parameterIndex != NSNotFound) {
        for (index = 0; index < count; index++) {
            [[[[postures objectAtIndex:index] parameterTargets] objectAtIndex:parameterIndex] changeDefaultValueFrom:oldDefaultValue to:newDefaultValue];
        }
    }

    parameterIndex = [metaParameters indexOfObject:aParameter];
    if (parameterIndex != NSNotFound) {
        for (index = 0; index < count; index++) {
            [[[[postures objectAtIndex:index] metaParameterTargets] objectAtIndex:parameterIndex] changeDefaultValueFrom:oldDefaultValue to:newDefaultValue];
        }
    }
}

- (void)symbol:(MMSymbol *)aSymbol willChangeDefaultValue:(double)newDefaultValue;
{
    double oldDefaultValue;
    unsigned int count, index;
    unsigned int symbolIndex;

    oldDefaultValue = [aSymbol defaultValue];
    count = [postures count];

    symbolIndex = [symbols indexOfObject:aSymbol];
    if (symbolIndex != NSNotFound) {
        for (index = 0; index < count; index++) {
            [[[[postures objectAtIndex:index] symbolTargets] objectAtIndex:symbolIndex] changeDefaultValueFrom:oldDefaultValue to:newDefaultValue];
        }
    }
}

//
// Other
//

- (MMSynthesisParameters *)synthesisParameters;
{
    return synthesisParameters;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"categories"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"category" class:[MMCategory class] delegate:self addObjectSelector:@selector(addCategory:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"parameters"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"parameter" class:[MMParameter class] delegate:self addObjectSelector:@selector(addParameter:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"meta-parameters"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"parameter" class:[MMParameter class] delegate:self addObjectSelector:@selector(addMetaParameter:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"symbols"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"symbol" class:[MMSymbol class] delegate:self addObjectSelector:@selector(addSymbol:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"postures"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"posture" class:[MMPosture class] delegate:self addObjectSelector:@selector(addPosture:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"equations"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"equation-group" class:[NamedList class] delegate:self addObjectSelector:@selector(addEquationGroup:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"transitions"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"transition-group" class:[NamedList class] delegate:self addObjectSelector:@selector(addTransitionGroup:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"special-transitions"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"transition-group" class:[NamedList class] delegate:self addObjectSelector:@selector(addSpecialTransitionGroup:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"rules"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"rule" class:[MMRule class] delegate:self addObjectSelector:@selector(_addStoredRule:)];
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
