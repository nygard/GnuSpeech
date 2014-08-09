//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMRule.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMBooleanNode.h"
#import "MMBooleanParser.h"
#import "MMParameter.h"
#import "MMEquation.h"
#import "MMSymbol.h"
#import "MMTransition.h"

#import "MModel.h"
#import "MXMLParser.h"
#import "MXMLArrayDelegate.h"
#import "MXMLPCDataDelegate.h"
#import "MXMLStringArrayDelegate.h"
#import "MXMLReferenceDictionaryDelegate.h"

@implementation MMRule
{
    NSMutableArray *parameterTransitions; // Of MMTransitions
    NSMutableArray *metaParameterTransitions; // Of MMTransitions?
    NSMutableArray *symbolEquations; // Of MMEquations
    
    MMTransition *specialProfiles[16]; // TODO (2004-05-16): We should be able to use an NSMutableDictionary here.
    
    MMBooleanNode *expressions[4];
}

- (id)init;
{
    if ((self = [super init])) {
        parameterTransitions = [[NSMutableArray alloc] init];
        metaParameterTransitions = [[NSMutableArray alloc] init];
        symbolEquations = [[NSMutableArray alloc] init];
        
        /* Zero out expressions and special Profiles */
        bzero(expressions, sizeof(MMBooleanNode *) * 4);
        bzero(specialProfiles, sizeof(id) * 16);
    }

    return self;
}

- (void)dealloc;
{
    NSUInteger index;

    [parameterTransitions release];
    [metaParameterTransitions release];
    [symbolEquations release];

    for (index = 0 ; index < 4; index++)
        [expressions[index] release];

    // TODO (2004-03-05): Release special profiles

    [super dealloc];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> parameterTransitions: %@, metaParameterTransitions: %@, symbolEquations(%lu): %@, comment: %@, e1: %@, e2: %@, e3: %@, e4: %@",
            NSStringFromClass([self class]), self, parameterTransitions, metaParameterTransitions, [symbolEquations count], symbolEquations,
            self.comment, [expressions[0] expressionString], [expressions[1] expressionString], [expressions[2] expressionString],
            [expressions[3] expressionString]];
}

#pragma mark -

- (void)setDefaultsTo:(NSUInteger)numPhones;
{
    id tempEntry = nil;
    MMEquation *anEquation, *defaultOnset, *defaultDuration;
    NSArray *aParameterList;
    NSUInteger i;

    /* Empty out the lists */
    [parameterTransitions removeAllObjects];
    [metaParameterTransitions removeAllObjects];
    [symbolEquations removeAllObjects];

    if ((numPhones < 2) || (numPhones > 4))
        return;

    switch (numPhones) {
        case 2:
            tempEntry = [self.model findTransitionWithName:@"Diphone" inGroupWithName:@"Defaults"];
            break;
        case 3:
            tempEntry = [self.model findTransitionWithName:@"Triphone" inGroupWithName:@"Defaults"];
            break;
        case 4:
            tempEntry = [self.model findTransitionWithName:@"Tetraphone" inGroupWithName:@"Defaults"];
            break;
    }

    if (tempEntry == nil) {
        NSLog(@"CANNOT find temp entry");
    }

    aParameterList = [self.model parameters];
    for (i = 0; i < [aParameterList count]; i++) {
        [parameterTransitions addObject:tempEntry];
    }

    /* Alloc lists to point to prototype transition specifiers */
    aParameterList = [self.model metaParameters];
    for (i = 0; i < [aParameterList count]; i++) {
        [metaParameterTransitions addObject:tempEntry];
    }

    switch (numPhones) {
        case 2:
            defaultDuration = [self.model findEquationWithName:@"DiphoneDefault" inGroupWithName:@"DefaultDurations" ];
            if (defaultDuration == nil)
                break;
            [symbolEquations addObject:defaultDuration];
            
            defaultOnset = [self.model findEquationWithName:@"diBeat" inGroupWithName:@"SymbolDefaults"];
            if (defaultOnset == nil)
                break;
            [symbolEquations addObject:defaultOnset];
            
            [symbolEquations addObject:defaultDuration]; /* Make the mark1 value == duration */
            break;
            
        case 3:
            defaultDuration = [self.model findEquationWithName:@"TriphoneDefault" inGroupWithName:@"DefaultDurations"];
            if (defaultDuration == nil)
                break;
            [symbolEquations addObject:defaultDuration];
            
            defaultOnset = [self.model findEquationWithName:@"triBeat" inGroupWithName:@"SymbolDefaults"];
            if (defaultOnset == nil)
                break;
            [symbolEquations addObject:defaultOnset];
            
            anEquation = [self.model findEquationWithName:@"Mark1" inGroupWithName:@"SymbolDefaults"];
            if (anEquation == nil)
                break;
            [symbolEquations addObject:anEquation];
            
            [symbolEquations addObject:defaultDuration]; /* Make the  mark2 value == duration */
            break;
            
        case 4:
            defaultDuration = [self.model findEquationWithName:@"TetraphoneDefault" inGroupWithName:@"DefaultDurations"];
            if (defaultDuration == nil)
                break;
            [symbolEquations addObject:defaultDuration];
            
            defaultOnset = [self.model findEquationWithName:@"tetraBeat" inGroupWithName:@"SymbolDefaults"]; // TODO (2004-03-24): Not in diphones.monet
            if (defaultOnset == nil)
                break;
            [symbolEquations addObject:defaultOnset];
            
            anEquation = [self.model findEquationWithName:@"Mark1" inGroupWithName:@"SymbolDefaults"];
            if (anEquation == nil)
                break;
            [symbolEquations addObject:anEquation];
            
            anEquation = [self.model findEquationWithName:@"Mark2" inGroupWithName:@"SymbolDefaults"];
            if  (anEquation == nil)
                break;
            [symbolEquations addObject:anEquation];
            
            [symbolEquations addObject:defaultDuration]; /* Make the mark3 value == duration */
            break;
    }
}

- (void)addDefaultTransitionForLastParameter;
{
    MMTransition *transition = nil;

    switch ([self numberExpressions]) {
        case 2:
            transition = [self.model findTransitionWithName:@"Diphone" inGroupWithName:@"Defaults"];
            break;
        case 3:
            transition = [self.model findTransitionWithName:@"Triphone" inGroupWithName:@"Defaults"];
            break;
        case 4:
            transition = [self.model findTransitionWithName:@"Tetraphone" inGroupWithName:@"Defaults"];
            break;
    }

    if (transition != nil)
        [parameterTransitions addObject:transition];
}

// Warning (building for 10.2 deployment) (2004-04-02): tempEntry might be used uninitialized in this function
- (void)addDefaultTransitionForLastMetaParameter;
{
    MMTransition *transition = nil;

    switch ([self numberExpressions]) {
        case 2:
            transition = [self.model findTransitionWithName:@"Diphone" inGroupWithName:@"Defaults"];
            break;
        case 3:
            transition = [self.model findTransitionWithName:@"Triphone" inGroupWithName:@"Defaults"];
            break;
        case 4:
            transition = [self.model findTransitionWithName:@"Tetraphone" inGroupWithName:@"Defaults"];
            break;
    }
    
    if (transition != nil)
        [metaParameterTransitions addObject:transition];
}

- (void)removeParameterAtIndex:(NSUInteger)index;
{
    [parameterTransitions removeObjectAtIndex:index];
}

- (void)removeMetaParameterAtIndex:(NSUInteger)index;
{
    [metaParameterTransitions removeObjectAtIndex:index];
}

- (void)addStoredParameterTransition:(MMTransition *)aTransition;
{
    [parameterTransitions addObject:aTransition];
}

- (void)addParameterTransitionsFromReferenceDictionary:(NSDictionary *)dict;
{
    NSUInteger count, index;

    NSArray *parameters = [[self model] parameters];

    count = [parameters count];
    for (index = 0; index < count; index++) {
        MMParameter *parameter = [parameters objectAtIndex:index];
        NSString *name = [dict objectForKey:[parameter name]];
        MMTransition *transition = [[self model] findTransitionWithName:name];
        if (transition == nil) {
            NSLog(@"Error: Can't find transition named: %@", name);
        } else {
            [self addStoredParameterTransition:transition];
        }
    }
}

- (void)addStoredMetaParameterTransition:(MMTransition *)aTransition;
{
    [metaParameterTransitions addObject:aTransition];
}

- (void)addMetaParameterTransitionsFromReferenceDictionary:(NSDictionary *)dict;
{
    NSUInteger count, index;

    NSArray *parameters = [[self model] metaParameters];

    count = [parameters count];
    for (index = 0; index < count; index++) {

        MMParameter *parameter = [parameters objectAtIndex:index];
        NSString *name = [dict objectForKey:[parameter name]];
        MMTransition *transition = [[self model] findTransitionWithName:name];
        if (transition == nil) {
            NSLog(@"Error: Can't find transition named: %@", name);
        } else {
            [self addStoredMetaParameterTransition:transition];
        }
    }
}

- (void)addSpecialProfilesFromReferenceDictionary:(NSDictionary *)dict;
{
    NSUInteger count, index;

    //NSLog(@"%s, dict: %@", _cmd, [dict description]);
    NSArray *parameters = [[self model] parameters];

    count = [parameters count];
    for (index = 0; index < count; index++) {
        MMParameter *parameter = [parameters objectAtIndex:index];
        NSString *transitionName = [dict objectForKey:[parameter name]];
        if (transitionName != nil) {
            //NSLog(@"parameter: %@, transition name: %@", [parameter name], transitionName);
            MMTransition *transition = [[self model] findSpecialTransitionWithName:transitionName];
            if (transition == nil) {
                NSLog(@"Error: Can't find transition named: %@", transitionName);
            } else {
                [self setSpecialProfile:index to:transition];
            }
        }
    }
}

- (void)addStoredSymbolEquation:(MMEquation *)anEquation;
{
    [symbolEquations addObject:anEquation];
}

- (void)addSymbolEquationsFromReferenceDictionary:(NSDictionary *)dict;
{
    NSUInteger count, index;

    NSArray *symbols = [[NSArray alloc] initWithObjects:@"rd", @"beat", @"mark1", @"mark2", @"mark3", nil];

    count = [symbols count];
    for (index = 0; index < count; index++) {
        NSString *symbolName = [symbols objectAtIndex:index];
        NSString *equationName = [dict objectForKey:symbolName];
        if (equationName == nil)
            break;

        MMEquation *equation = [[self model] findEquationWithName:equationName];
        if (equation == nil) {
            NSLog(@"Error: Can't find equation named: %@", equationName);
        } else {
            [self addStoredSymbolEquation:equation];
        }
    }

    [symbols release];
}

- (void)setExpression:(MMBooleanNode *)newExpression number:(NSUInteger)index;
{
    if (index > 3)
        return;

    if (newExpression == expressions[index])
        return;

    [expressions[index] release];
    expressions[index] = [newExpression retain];
}

- (NSUInteger)numberExpressions;
{
    NSUInteger index;
    
    for (index = 0; index < 4; index++)
        if (expressions[index] == nil)
            return index;

    return index;
}

- (MMBooleanNode *)getExpressionNumber:(NSUInteger)index;
{
    if (index > 3)
        return nil;

    return expressions[index];
}

- (void)addBooleanExpression:(MMBooleanNode *)newExpression;
{
    for (NSUInteger index = 0; index < 4; index++) {
        if (expressions[index] == nil) {
            expressions[index] = [newExpression retain];
            return;
        }
    }

    NSLog(@"Warning: No room for another boolean expression in MMRule.");
}

- (void)addBooleanExpressionString:(NSString *)aString;
{
    MMBooleanParser *parser = [[MMBooleanParser alloc] initWithModel:[self model]];

    MMBooleanNode *result = [parser parseString:aString];
    if (result == nil) {
        NSLog(@"Error parsing boolean expression: %@", [parser errorMessage]);
    } else {
        [self addBooleanExpression:result];
    }

    [parser release];
}

- (BOOL)matchRule:(NSArray *)categories;
{
    for (NSUInteger index = 0; index < [self numberExpressions]; index++) {
        if (![expressions[index] evaluateWithCategories:[categories objectAtIndex:index]])
            return NO;
    }

    return YES;
}

- (MMEquation *)getSymbolEquation:(int)index;
{
    return [symbolEquations objectAtIndex:index];
}

- (void)evaluateSymbolEquationsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols withCacheTag:(NSUInteger)cache;
{
    NSUInteger count = [symbolEquations count];
    // It is not okay to do these in order -- beat often depends on duration, mark1, mark2, and/or mark3.

    ruleSymbols.ruleDuration = (count > 0) ? [(MMEquation *)[symbolEquations objectAtIndex:0] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.mark1        = (count > 2) ? [(MMEquation *)[symbolEquations objectAtIndex:2] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.mark2        = (count > 3) ? [(MMEquation *)[symbolEquations objectAtIndex:3] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.mark3        = (count > 4) ? [(MMEquation *)[symbolEquations objectAtIndex:4] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.beat         = (count > 1) ? [(MMEquation *)[symbolEquations objectAtIndex:1] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
}

- (NSMutableArray *)parameterTransitions;
{
    return parameterTransitions;
}

- (NSMutableArray *)metaParameterTransitions;
{
    return metaParameterTransitions;
}

- (NSMutableArray *)symbolEquations;
{
    return symbolEquations;
}

- (MMTransition *)getSpecialProfile:(NSUInteger)index;
{
    if (index > 15)
        return nil;

    return specialProfiles[index];
}

- (void)setSpecialProfile:(NSUInteger)index to:(MMTransition *)special;
{
    if (index > 15)
        return;

    specialProfiles[index] = special;
}

- (BOOL)usesCategory:(MMCategory *)aCategory;
{
    NSUInteger count, index;

    count = [self numberExpressions];
    for (index = 0; index < count; index++) {
        if ([expressions[index] usesCategory:aCategory])
            return YES;
    }

    return NO;
}

- (BOOL)usesEquation:(MMEquation *)anEquation;
{
    if ([symbolEquations indexOfObject:anEquation] != NSNotFound)
        return YES;

    return NO;
}

- (BOOL)usesTransition:(MMTransition *)aTransition;
{
    if ([parameterTransitions indexOfObject:aTransition] != NSNotFound)
        return YES;
    if ([metaParameterTransitions indexOfObject:aTransition] != NSNotFound)
        return YES;

    for (NSUInteger index = 0; index < 16; index++) {
        if (specialProfiles[index] == aTransition)
            return YES;
    }

    return NO;
}

- (NSString *)ruleString;
{
    NSMutableString *ruleString = [[[NSMutableString alloc] init] autorelease];

    [expressions[0] appendExpressionToString:ruleString];
    [ruleString appendString:@" >> "];
    [expressions[1] appendExpressionToString:ruleString];

    NSString *str = [expressions[2] expressionString];
    if (str != nil) {
        [ruleString appendString:@" >> "];
        [ruleString appendString:str];
    }

    str = [expressions[3] expressionString];
    if (str != nil) {
        [ruleString appendString:@" >> "];
        [ruleString appendString:str];
    }

    return ruleString;
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger index;

    [resultString indentToLevel:level];
    [resultString appendString:@"<rule>\n"];

    [resultString indentToLevel:level + 1];
    [resultString appendString:@"<boolean-expressions>\n"];

    for (index = 0; index < 4; index++) {
        NSString *str = [expressions[index] expressionString];
        if (str != nil) {
            [resultString indentToLevel:level + 2];
            [resultString appendFormat:@"<boolean-expression>%@</boolean-expression>\n", GSXMLCharacterData(str)];
        }
    }

    [resultString indentToLevel:level + 1];
    [resultString appendString:@"</boolean-expressions>\n"];

    if (self.comment != nil) {
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(self.comment)];
    }

    [self _appendXMLForParameterTransitionsToString:resultString level:level + 1];
    [self _appendXMLForMetaParameterTransitionsToString:resultString level:level + 1];
    [self _appendXMLForSpecialProfilesToString:resultString level:level + 1];
    [self _appendXMLForSymbolEquationsToString:resultString level:level + 1];

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</rule>\n"];
}

- (void)_appendXMLForParameterTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger count, index;

    NSArray *mainParameterList = [[self model] parameters];
    NSParameterAssert([mainParameterList count] == [parameterTransitions count]);

    if ([parameterTransitions count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<parameter-profiles>\n"];

    count = [mainParameterList count];
    for (index = 0; index < count; index++) {
        MMParameter *aParameter = [mainParameterList objectAtIndex:index];
        MMTransition *aTransition = [parameterTransitions objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<parameter-transition name=\"%@\" transition=\"%@\"/>\n",
                      GSXMLAttributeString([aParameter name], NO), GSXMLAttributeString([aTransition name], NO)];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</parameter-profiles>\n"];
}

- (void)_appendXMLForMetaParameterTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger count, index;

    NSArray *mainMetaParameterList = [[self model] metaParameters];
    NSParameterAssert([mainMetaParameterList count] == [metaParameterTransitions count]);

    if ([metaParameterTransitions count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<meta-parameter-profiles>\n"];

    count = [mainMetaParameterList count];
    for (index = 0; index < count; index++) {
        MMParameter *aParameter;
        MMTransition *aTransition;

        aParameter = [mainMetaParameterList objectAtIndex:index];
        aTransition = [metaParameterTransitions objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<parameter-transition name=\"%@\" transition=\"%@\"/>\n",
                      GSXMLAttributeString([aParameter name], NO), GSXMLAttributeString([aTransition name], NO)];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</meta-parameter-profiles>\n"];
}

- (void)_appendXMLForSpecialProfilesToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger count, index;
    BOOL hasSpecialProfiles = NO;

    NSArray *mainParameterList = [[self model] parameters];

    count = [mainParameterList count];
    for (index = 0; index < count && index < 16; index++) {
        if (specialProfiles[index] != nil) {
            hasSpecialProfiles = YES;
            break;
        }
    }

    if (hasSpecialProfiles == NO)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<special-profiles>\n"];

    for (index = 0; index < count && index < 16; index++) {
        MMParameter *aParameter;
        MMTransition *aTransition;

        aParameter = [mainParameterList objectAtIndex:index];
        aTransition = specialProfiles[index];

        if (aTransition != nil) {
            [resultString indentToLevel:level + 1];
            [resultString appendFormat:@"<parameter-transition name=\"%@\" transition=\"%@\"/>\n",
                          GSXMLAttributeString([aParameter name], NO), GSXMLAttributeString([aTransition name], NO)];
        }
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</special-profiles>\n"];
}

- (void)_appendXMLForSymbolEquationsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger count, index;

    if ([symbolEquations count] == 0)
        return;

    [resultString indentToLevel:level];
    // TODO (2004-08-15): Rename this to symbol-equations.
    [resultString appendString:@"<expression-symbols>\n"];

    count = [symbolEquations count];
    for (index = 0; index < count; index++) {
        MMEquation *anEquation;

        anEquation = [symbolEquations objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<symbol-equation name=\"%@\" equation=\"%@\"/>\n",
                      GSXMLAttributeString([self symbolNameAtIndex:index], NO), GSXMLAttributeString([anEquation name], NO)];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</expression-symbols>\n"];
}

- (NSString *)symbolNameAtIndex:(NSUInteger)index;
{
    switch (index) {
        case 0: return @"rd";
        case 1: return @"beat";
        case 2: return @"mark1";
        case 3: return @"mark2";
        case 4: return @"mark3";
    }

    return nil;
}

- (void)setRuleExpression1:(MMBooleanNode *)exp1 exp2:(MMBooleanNode *)exp2 exp3:(MMBooleanNode *)exp3 exp4:(MMBooleanNode *)exp4;
{
    NSUInteger oldExpressionCount = [self numberExpressions];

    [self setExpression:exp1 number:0];
    [self setExpression:exp2 number:1];
    [self setExpression:exp3 number:2];
    [self setExpression:exp4 number:3];

    if (oldExpressionCount != [self numberExpressions])
        [self setDefaultsTo:[self numberExpressions]];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributes;
{
    if ([elementName isEqualToString:@"boolean-expressions"]) {
        MXMLStringArrayDelegate *newDelegate = [[MXMLStringArrayDelegate alloc] initWithChildElementName:@"boolean-expression" delegate:self addObjectSelector:@selector(addBooleanExpressionString:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"parameter-profiles"]) {
        MXMLReferenceDictionaryDelegate *newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"parameter-transition" keyAttributeName:@"name" referenceAttributeName:@"transition"
                                                               delegate:self addObjectsSelector:@selector(addParameterTransitionsFromReferenceDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"meta-parameter-profiles"]) {
        MXMLReferenceDictionaryDelegate *newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"parameter-transition" keyAttributeName:@"name" referenceAttributeName:@"transition"
                                                               delegate:self addObjectsSelector:@selector(addMetaParameterTransitionsFromReferenceDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"special-profiles"]) {
        MXMLReferenceDictionaryDelegate *newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"parameter-transition" keyAttributeName:@"name" referenceAttributeName:@"transition"
                                                               delegate:self addObjectsSelector:@selector(addSpecialProfilesFromReferenceDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"expression-symbols"]) {
        MXMLReferenceDictionaryDelegate *newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"symbol-equation" keyAttributeName:@"name" referenceAttributeName:@"equation"
                                                               delegate:self addObjectsSelector:@selector(addSymbolEquationsFromReferenceDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else {
        [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributes];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"rule"])
        [(MXMLParser *)parser popDelegate];
    else
        [NSException raise:@"Unknown close tag" format:@"Unknown closing tag (%@) in %@", elementName, NSStringFromClass([self class])];
}

@end
