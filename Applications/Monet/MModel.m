//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MModel.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "AppController.h"
#import "CategoryList.h"
#import "MMCategory.h"
#import "MonetList.h"
#import "NamedList.h"
#import "ParameterList.h"
#import "PhoneList.h"
#import "MMEquation.h"
#import "MMTransition.h"
#import "RuleList.h"
#import "SymbolList.h"

#import "MUnarchiver.h"

@implementation MModel

- (id)init;
{
    if ([super init] == nil)
        return nil;

    categories = [[CategoryList alloc] init];
    parameters = [[ParameterList alloc] init];
    metaParameters = [[ParameterList alloc] init];
    symbols = [[SymbolList alloc] init];
    phones = [[PhoneList alloc] init];

    equations = [[MonetList alloc] init];
    transitions = [[MonetList alloc] init];
    specialTransitions = [[MonetList alloc] init];

    rules = [[RuleList alloc] init];

    // And set up some default values:
    [symbols addNewValue:@"duration"];
    [[categories addCategory:@"phone"] setComment:@"This is the static phone category.  It cannot be changed or removed."];

    return self;
}

- (void)dealloc;
{
    [categories release];
    [parameters release];
    [metaParameters release];
    [symbols release];
    [phones release];
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

- (PhoneList *)phones;
{
    return phones;
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

    phones = [[aDecoder decodeObject] retain];
    //NSLog(@"phones: %@", phones);
    NSLog(@"phones: %d", [phones count]);

    NXNameObject(@"mainSymbolList", symbols, NSApp);
    NXNameObject(@"mainParameterList", parameters, NSApp);
    NXNameObject(@"mainMetaParameterList", metaParameters, NSApp);
    NXNameObject(@"mainPhoneList", phones, NSApp);

    equations = [[aDecoder decodeObject] retain];
    NSLog(@"equations: %d", [equations count]);

    transitions = [[aDecoder decodeObject] retain];
    NSLog(@"transitions: %d", [transitions count]);

    specialTransitions = [[aDecoder decodeObject] retain];
    NSLog(@"specialTransitions: %d", [specialTransitions count]);

    rules = [[aDecoder decodeObject] retain];
    NSLog(@"rules: %d", [rules count]);

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
    [categories appendXMLToString:resultString level:1 useReferences:NO];

    [parameters appendXMLToString:resultString elementName:@"parameters" level:1];
    [metaParameters appendXMLToString:resultString elementName:@"meta-parameters" level:1];
    [symbols appendXMLToString:resultString level:1];
    [phones appendXMLToString:resultString level:1];

    [self _appendXMLForMMEquationsToString:resultString level:1];
    [self _appendXMLForMMTransitionsToString:resultString level:1];
    [self _appendXMLForProtoSpecialsToString:resultString level:1];
    [rules appendXMLToString:resultString elementName:@"rules" level:1 numberItems:YES];

    [resultString appendString:@"</root>\n"];

    //NSLog(@"xml: \n%@", resultString);
    [[resultString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:@"/tmp/out.xml" atomically:YES];

    [resultString release];
}

- (void)_appendXMLForMMEquationsToString:(NSMutableString *)resultString level:(int)level;
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

- (void)_appendXMLForMMTransitionsToString:(NSMutableString *)resultString level:(int)level;
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

@end
