//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MModel.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "AppController.h"
#import "BooleanParser.h"
#import "CategoryList.h"
#import "MMCategory.h"
#import "MonetList.h"
#import "NamedList.h"
#import "ParameterList.h"
#import "PhoneList.h"
#import "MMEquation.h"
#import "MMParameter.h"
#import "MMPosture.h"
#import "MMSymbol.h"
#import "MMTarget.h"
#import "MMTransition.h"
#import "RuleList.h"
#import "SymbolList.h"
#import "TargetList.h"

#import "MUnarchiver.h"

NSString *MCategoryInUseException = @"MCategoryInUseException";

@implementation MModel

- (id)init;
{
    MMSymbol *newSymbol;

    if ([super init] == nil)
        return nil;

    categories = [[CategoryList alloc] init];
    parameters = [[ParameterList alloc] init];
    metaParameters = [[ParameterList alloc] init];
    symbols = [[SymbolList alloc] init];
    postures = [[PhoneList alloc] init];

    equations = [[MonetList alloc] init];
    transitions = [[MonetList alloc] init];
    specialTransitions = [[MonetList alloc] init];

    rules = [[RuleList alloc] init];

    // And set up some default values:
    newSymbol = [[MMSymbol alloc] initWithSymbol:@"duration"];
    [self addSymbol:newSymbol];
    [newSymbol release];

    [[categories addCategory:@"phone"] setComment:@"This is the static phone category.  It cannot be changed or removed."];

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

    [super dealloc];
}

- (CategoryList *)categories;
{
    return categories;
}

- (ParameterList *)parameters;
{
    return parameters;
}

- (ParameterList *)metaParameters;
{
    return metaParameters;
}

- (SymbolList *)symbols;
{
    return symbols;
}

- (PhoneList *)postures;
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

- (RuleList *)rules;
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
    return [rules isCategoryUsed:aCategory];
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
    [postures addParameter];
    [rules makeObjectsPerformSelector:@selector(addDefaultParameter)];
}

// TODO (2004-03-19): When MMParameter and MMSymbol are the same class, this can be shared
- (void)_uniqueNameForParameter:(MMParameter *)newParameter inList:(ParameterList *)aParameterList;
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

- (void)removeParameter:(MMParameter *)aParameter;
{
    unsigned int parameterIndex;

    parameterIndex  = [parameters indexOfObject:aParameter];
    if (parameterIndex != NSNotFound) {
        int count, index;

        [postures removeParameterAtIndex:parameterIndex];
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
    [postures addMetaParameter];
    [rules makeObjectsPerformSelector:@selector(addDefaultMetaParameter)];
}

- (void)removeMetaParameter:(MMParameter *)aParameter;
{
    unsigned int parameterIndex;

    parameterIndex  = [metaParameters indexOfObject:aParameter];
    if (parameterIndex != NSNotFound) {
        int count, index;

        [postures removeMetaParameterAtIndex:parameterIndex];
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
    [postures addSymbol];
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

- (void)removeSymbol:(MMSymbol *)aSymbol;
{
    unsigned int index;

    index = [symbols indexOfObject:aSymbol];
    if (index != NSNotFound) {
        [postures removeSymbol:index]; // TODO (2004-03-19): Rename, to at "AtIndex"
        [symbols removeObject:aSymbol];
    }
}

//
// Postures
//

- (void)addPosture:(MMPosture *)newPosture;
{
    if ([newPosture symbol] == nil)
        [newPosture setSymbol:@"untitled"];

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
    NSLog(@"%s, name: %@, isUsed: %d", _cmd, name, isUsed);

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

- (MMEquation *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
{
    int i, j;

    for (i = 0 ; i < [transitions count]; i++) {
        NamedList *currentList;

        currentList = [transitions objectAtIndex:i];
        if ([aListName isEqualToString:[currentList name]]) {
            for (j = 0; j < [currentList count]; j++) {
                MMEquation *anEquation;

                anEquation = [currentList objectAtIndex:j];
                if ([aTransitionName isEqualToString:[anEquation name]])
                    return anEquation;
            }
        }
    }

    return nil;
}

- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(MMEquation *)aTransition;
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

- (MMEquation *)findTransition:(int)listIndex andIndex:(int)transitionIndex;
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
    NSLog(@"categories: %d", [categories count]);
    NXNameObject(@"mainCategoryList", categories, NSApp);

    symbols = [[aDecoder decodeObject] retain];
    //NSLog(@"symbols: %@", symbols);
    NSLog(@"symbols: %d", [symbols count]);

    parameters = [[aDecoder decodeObject] retain];
    //NSLog(@"parameters: %@", parameters);
    NSLog(@"parameters: %d", [parameters count]);

    metaParameters = [[aDecoder decodeObject] retain];
    //NSLog(@"metaParameters: %@", metaParameters);
    NSLog(@"metaParameters: %d", [metaParameters count]);

    postures = [[aDecoder decodeObject] retain];
    //NSLog(@"postures: %@", postures);
    NSLog(@"postures: %d", [postures count]);
    [postures makeObjectsPerformSelector:@selector(setModel:) withObject:self];

    NXNameObject(@"mainSymbolList", symbols, NSApp);
    NXNameObject(@"mainParameterList", parameters, NSApp);
    NXNameObject(@"mainMetaParameterList", metaParameters, NSApp);
    NXNameObject(@"mainPhoneList", postures, NSApp);

    equations = [[aDecoder decodeObject] retain];
    NSLog(@"equations: %d", [equations count]);

    transitions = [[aDecoder decodeObject] retain];
    NSLog(@"transitions: %d", [transitions count]);

    specialTransitions = [[aDecoder decodeObject] retain];
    NSLog(@"specialTransitions: %d", [specialTransitions count]);

    rules = [[aDecoder decodeObject] retain];
    NSLog(@"rules: %d", [rules count]);
    [rules makeObjectsPerformSelector:@selector(setModel:) withObject:self];

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

//
// Archiving - XML
//

- (void)generateXML:(NSString *)name;
{
    NSMutableString *resultString;

    resultString = [[NSMutableString alloc] init];
    [resultString appendString:@"<?xml version='1.0' encoding='utf-8'?>\n"];
    [resultString appendFormat:@"<!-- %@ -->\n", name];
    [resultString appendString:@"<root version='1'>\n"];
    [self _appendXMLForCategoriesToString:resultString level:1];

    [parameters appendXMLToString:resultString elementName:@"parameters" level:1];
    [metaParameters appendXMLToString:resultString elementName:@"meta-parameters" level:1];
    [symbols appendXMLToString:resultString level:1];
    [postures appendXMLToString:resultString level:1];

    [self _appendXMLForEquationsToString:resultString level:1];
    [self _appendXMLForTransitionsToString:resultString level:1];
    [self _appendXMLForProtoSpecialsToString:resultString level:1];
    [rules appendXMLToString:resultString elementName:@"rules" level:1 numberItems:YES];

    [resultString appendString:@"</root>\n"];

    //NSLog(@"xml: \n%@", resultString);
    [[resultString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:@"/tmp/out.xml" atomically:YES];

    [resultString release];
}

- (void)_appendXMLForCategoriesToString:(NSMutableString *)resultString level:(int)level;
{
    int count, index;

    count = [categories count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<categories>\n"];

    for (index = 0; index < count; index++) {
        MMCategory *aCategory;

        aCategory = [categories objectAtIndex:index];
        [aCategory appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</categories>\n"];
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
        [namedList appendXMLToString:resultString elementName:@"group" level:level + 1];
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
        [namedList appendXMLToString:resultString elementName:@"group" level:level + 1];
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
        [namedList appendXMLToString:resultString elementName:@"group" level:level + 1];
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
    [self generateXML:@"after reading Degas parameters"];
    [self readCategoriesFromDegasFile:fp];
    [self generateXML:@"after reading Degas categories"];
    [self readPosturesFromDegasFile:fp];
    [self generateXML:@"after reading Degas postures"];
    [self readRulesFromDegasFile:fp];
    [self generateXML:@"after reading Degas rules"];
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

    symbolIndex = [symbols findSymbolIndex:@"duration"];

    if (symbolIndex == -1) {
        MMSymbol *newSymbol;

        newSymbol = [[MMSymbol alloc] initWithSymbol:@"duration"];
        [self addSymbol:newSymbol];
        [newSymbol release];

        symbolIndex = [symbols findSymbolIndex:@"duration"];
        [postures addSymbol];
    }

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

        tempTarget = [[newPhone symbolList] objectAtIndex:symbolIndex];
        [tempTarget setValue:(double)tempDuration isDefault:NO];

        /* READ TARGETS IN FROM FILE  */
        for (j = 0; j < targetCount; j++) {
            tempTarget = [[newPhone parameterList] objectAtIndex:j];

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

            tempCategory = [categories findSymbol:str];
            if (!tempCategory) {
                [[newPhone categoryList] addNativeCategory:str];
            } else
                [[newPhone categoryList] addObject:tempCategory];
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
    BooleanParser *boolParser;
    id temp, temp1;
    NSString *bufferStr, *buffer1Str;

    boolParser = [[BooleanParser alloc] init];
    [boolParser setCategoryList:categories];
    [boolParser setPhoneList:postures];

    /* READ FROM FILE  */
    NXRead(fp, &numRules, sizeof(int));
    for (i = 0; i < numRules; i++) {
        /* READ SPECIFIER CATEGORY #1 FROM FILE  */
        NXRead(fp, &tempLength, sizeof(int));
        bzero(buffer, 1024);
        NXRead(fp, buffer, tempLength + 1);
        bufferStr = [NSString stringWithASCIICString:buffer];
        //NSLog(@"i: %d", i);
        //NSLog(@"bufferStr: %@", bufferStr);
        temp = [boolParser parseString:bufferStr];

        /* READ SPECIFIER CATEGORY #2 FROM FILE  */
        NXRead(fp, &tempLength, sizeof(int));
        bzero(buffer1, 1024);
        NXRead(fp, buffer1, tempLength + 1);
        buffer1Str = [NSString stringWithASCIICString:buffer1];
        //NSLog(@"buffer1Str: %@", buffer1Str);
        temp1 = [boolParser parseString:buffer1Str];

        if (temp == nil || temp1 == nil)
            NSLog(@"Error parsing rule: %@ >> %@", bufferStr, buffer1Str);
        else
            [rules addRuleExp1:temp exp2:temp1 exp3:nil exp4:nil];

        /* READ TRANSITION INTERVALS FROM FILE  */
        NXRead(fp, &k1, sizeof(int));
        for (j = 0; j < k1; j++) {
            NXRead(fp, &dummy, sizeof(short int));
            NXRead(fp, &dummy, sizeof(short int));
            NXRead(fp, &dummy, sizeof(int));
            NXRead(fp, &dummy, sizeof(float));
            NXRead(fp, &dummy, sizeof(float));
        }

        /* READ TRANSITION INTERVAL MODE FROM FILE  */
        NXRead(fp, &dummy, sizeof(short int));

        /* READ SPLIT MODE FROM FILE  */
        NXRead(fp, &dummy, sizeof(short int));

        /* READ SPECIAL EVENTS FROM FILE  */
        NXRead(fp, &j1, sizeof(int));

        for (j = 0; j < j1; j++) {
            /* READ SPECIAL EVENT SYMBOL FROM FILE  */
            NXRead(fp, buffer, SYMBOL_LENGTH_MAX + 1);

            /* READ SPECIAL EVENT INTERVALS FROM FILE  */
            for (k = 0; k < k1; k++) {

                /* READ SUB-INTERVALS FROM FILE  */
                NXRead(fp, &l1, sizeof(int));
                for (l = 0; l < l1; l++) {
                    /* READ SUB-INTERVAL PARAMETERS FROM FILE  */
                    NXRead(fp, &dummy, sizeof(short int));
                    NXRead(fp, &dummy, sizeof(int));
                    NXRead(fp, &dummy, sizeof(float));
                }
            }
        }

        /* READ DURATION RULE INFORMATION FROM FILE  */
        NXRead(fp, &dummy, sizeof(int));
        NXRead(fp, &dummy, sizeof(int));
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
        TargetList *aParameterList, *aSymbolList;

        aPhone = [postures objectAtIndex:index];
        fprintf(fp, "%s\n", [[aPhone symbol] UTF8String]);
        aCategoryList = [aPhone categoryList];
        for (j = 0; j < [aCategoryList count]; j++) {
            MMCategory *aCategory;

            aCategory = [aCategoryList objectAtIndex:j];
            if ([aCategory isNative])
                fprintf(fp, "*%s ", [[aCategory symbol] UTF8String]);
            else
                fprintf(fp, "%s ", [[aCategory symbol] UTF8String]);
        }
        fprintf(fp, "\n\n");

        aParameterList = [aPhone parameterList];
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

        aSymbolList = [aPhone symbolList];
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

@end
