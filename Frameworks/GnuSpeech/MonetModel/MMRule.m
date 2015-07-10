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
#import "MMFRuleSymbols.h"
#import "MModel.h"

@implementation MMRule
{
    NSMutableArray *_parameterTransitions; // Of MMTransitions
    NSMutableArray *_metaParameterTransitions; // Of MMTransitions?
    NSMutableArray *_symbolEquations; // Of MMEquations

    MMTransition *_specialProfiles[16]; // TODO (2004-05-16): We should be able to use an NSMutableDictionary here.

    MMBooleanNode *_expressions[4];
}

- (id)init;
{
    if ((self = [super init])) {
        _parameterTransitions = [[NSMutableArray alloc] init];
        _metaParameterTransitions = [[NSMutableArray alloc] init];
        _symbolEquations = [[NSMutableArray alloc] init];
        
        /* Zero out expressions and special Profiles */
        bzero(_expressions, sizeof(MMBooleanNode *) * 4);
        bzero(_specialProfiles, sizeof(id) * 16);
    }

    return self;
}

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"rule" isEqualToString:element.name]);

    if ((self = [super initWithXMLElement:element error:error])) {
        _parameterTransitions = [[NSMutableArray alloc] init];
        _metaParameterTransitions = [[NSMutableArray alloc] init];
        _symbolEquations = [[NSMutableArray alloc] init];

        /* Zero out expressions and special Profiles */
        bzero(_expressions, sizeof(MMBooleanNode *) * 4);
        bzero(_specialProfiles, sizeof(id) * 16);

        self.model = model;

        if (![self _loadBooleanExpressionFromXMLElement:    [[element elementsForName:@"boolean-expressions"] firstObject]     error:error]) return nil;
        if (![self _loadParameterProfilesFromXMLElement:    [[element elementsForName:@"parameter-profiles"] firstObject]      error:error]) return nil;
        if (![self _loadMetaParameterProfilesFromXMLElement:[[element elementsForName:@"meta-parameter-profiles"] firstObject] error:error]) return nil;
        if (![self _loadSpecialProfilesFromXMLElement:      [[element elementsForName:@"special-profiles"] firstObject]        error:error]) return nil;
        if (![self _loadExpressionSymbolsFromXMLElement:    [[element elementsForName:@"expression-symbols"] firstObject]      error:error]) return nil;
    }

    return self;
}

- (BOOL)_loadBooleanExpressionFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    if (element == nil) return YES;
    NSParameterAssert([@"boolean-expressions" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"boolean-expression"]) {
        NSString *str = [childElement stringValue];
        [self addBooleanExpressionString:str];
    }

    return YES;
}

- (BOOL)_loadParameterProfilesFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    if (element == nil) return YES;
    NSParameterAssert([@"parameter-profiles" isEqualToString:element.name]);

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    for (NSXMLElement *childElement in [element elementsForName:@"parameter-transition"]) {
        NSString *key = [[childElement attributeForName:@"name"] stringValue];
        dict[key] = [[childElement attributeForName:@"transition"] stringValue];
    }

    [self addParameterTransitionsFromReferenceDictionary:dict];

    return YES;
}

- (BOOL)_loadMetaParameterProfilesFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    if (element == nil) return YES;
    NSParameterAssert([@"meta-parameter-profiles" isEqualToString:element.name]);

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    for (NSXMLElement *childElement in [element elementsForName:@"parameter-transition"]) {
        NSString *key = [[childElement attributeForName:@"name"] stringValue];
        dict[key] = [[childElement attributeForName:@"transition"] stringValue];
    }

    [self addMetaParameterTransitionsFromReferenceDictionary:dict];

    return YES;
}

- (BOOL)_loadSpecialProfilesFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    if (element == nil) return YES;
    NSParameterAssert([@"special-profiles" isEqualToString:element.name]);

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    for (NSXMLElement *childElement in [element elementsForName:@"parameter-transition"]) {
        NSString *key = [[childElement attributeForName:@"name"] stringValue];
        dict[key] = [[childElement attributeForName:@"transition"] stringValue];
    }

    [self addSpecialProfilesFromReferenceDictionary:dict];

    return YES;
}

- (BOOL)_loadExpressionSymbolsFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    if (element == nil) return YES;
    NSParameterAssert([@"expression-symbols" isEqualToString:element.name]);

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    for (NSXMLElement *childElement in [element elementsForName:@"symbol-equation"]) {
        NSString *key = [[childElement attributeForName:@"name"] stringValue];
        dict[key] = [[childElement attributeForName:@"equation"] stringValue];
    }

    [self addSymbolEquationsFromReferenceDictionary:dict];

    return YES;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> parameterTransitions: %@, metaParameterTransitions: %@, symbolEquations(%lu): %@, comment: %@, e1: %@, e2: %@, e3: %@, e4: %@",
            NSStringFromClass([self class]), self, _parameterTransitions, _metaParameterTransitions, [_symbolEquations count], _symbolEquations,
            self.comment, [_expressions[0] expressionString], [_expressions[1] expressionString], [_expressions[2] expressionString],
            [_expressions[3] expressionString]];
}

#pragma mark -

- (void)setDefaults;
{
    [_parameterTransitions removeAllObjects];
    [_metaParameterTransitions removeAllObjects];
    [_symbolEquations removeAllObjects];

    NSUInteger numPhones = [self expressionCount];
    if ((numPhones < 2) || (numPhones > 4))
        return;

    MMTransition *defaultTransition = [self.model defaultTransitionForPhoneCount:numPhones];

    if (defaultTransition == nil) {
        NSLog(@"Error: CANNOT find default transition");
    } else {
        [self.model.parameters enumerateObjectsUsingBlock:^(MMParameter *parameter, NSUInteger index, BOOL *stop) {
            [_parameterTransitions addObject:defaultTransition];
        }];
        [self.model.metaParameters enumerateObjectsUsingBlock:^(MMParameter *parameter, NSUInteger index, BOOL *stop) {
            [_metaParameterTransitions addObject:defaultTransition];
        }];
    }

    switch (numPhones) {
        case 2:
        {
            MMEquation *defaultDuration = [self.model findEquationWithName:@"DiphoneDefault" inGroupWithName:@"DefaultDurations" ];
            if (defaultDuration == nil) break;
            [_symbolEquations addObject:defaultDuration];
            
            MMEquation *defaultOnset = [self.model findEquationWithName:@"diBeat" inGroupWithName:@"SymbolDefaults"];
            if (defaultOnset == nil) break;
            [_symbolEquations addObject:defaultOnset];
            
            [_symbolEquations addObject:defaultDuration]; // Make the mark1 value == duration
            break;
        }
            
        case 3:
        {
            MMEquation *defaultDuration = [self.model findEquationWithName:@"TriphoneDefault" inGroupWithName:@"DefaultDurations"];
            if (defaultDuration == nil) break;
            [_symbolEquations addObject:defaultDuration];
            
            MMEquation *defaultOnset = [self.model findEquationWithName:@"triBeat" inGroupWithName:@"SymbolDefaults"];
            if (defaultOnset == nil) break;
            [_symbolEquations addObject:defaultOnset];
            
            MMEquation *defaultMark1 = [self.model findEquationWithName:@"Mark1" inGroupWithName:@"SymbolDefaults"];
            if (defaultMark1 == nil) break;
            [_symbolEquations addObject:defaultMark1];
            
            [_symbolEquations addObject:defaultDuration]; // Make the  mark2 value == duration
            break;
        }
            
        case 4:
        {
            MMEquation *defaultDuration = [self.model findEquationWithName:@"TetraphoneDefault" inGroupWithName:@"DefaultDurations"];
            if (defaultDuration == nil) break;
            [_symbolEquations addObject:defaultDuration];
            
            MMEquation *defaultOnset = [self.model findEquationWithName:@"tetraBeat" inGroupWithName:@"SymbolDefaults"]; // TODO (2004-03-24): Not in diphones.monet
            if (defaultOnset == nil) break;
            [_symbolEquations addObject:defaultOnset];
            
            MMEquation *defaultMark1 = [self.model findEquationWithName:@"Mark1" inGroupWithName:@"SymbolDefaults"];
            if (defaultMark1 == nil) break;
            [_symbolEquations addObject:defaultMark1];
            
            MMEquation *defaultMark2 = [self.model findEquationWithName:@"Mark2" inGroupWithName:@"SymbolDefaults"];
            if  (defaultMark2 == nil) break;
            [_symbolEquations addObject:defaultMark2];
            
            [_symbolEquations addObject:defaultDuration]; // Make the mark3 value == duration
            break;
        }
    }
}

- (void)addDefaultTransitionForLastParameter;
{
    MMTransition *defaultTransition = [self.model defaultTransitionForPhoneCount:[self expressionCount]];

    if (defaultTransition != nil)
        [_parameterTransitions addObject:defaultTransition];
}

- (void)addDefaultTransitionForLastMetaParameter;
{
    MMTransition *defaultTransition = [self.model defaultTransitionForPhoneCount:[self expressionCount]];

    if (defaultTransition != nil)
        [_metaParameterTransitions addObject:defaultTransition];
}

- (void)removeParameterAtIndex:(NSUInteger)index;
{
    [_parameterTransitions removeObjectAtIndex:index];
}

- (void)removeMetaParameterAtIndex:(NSUInteger)index;
{
    [_metaParameterTransitions removeObjectAtIndex:index];
}

- (void)addStoredParameterTransition:(MMTransition *)aTransition;
{
    [_parameterTransitions addObject:aTransition];
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
    [_metaParameterTransitions addObject:aTransition];
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
    [_symbolEquations addObject:anEquation];
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
}

- (void)setExpression:(MMBooleanNode *)newExpression number:(NSUInteger)index;
{
    if (index > 3)
        return;

    if (newExpression == _expressions[index])
        return;

    _expressions[index] = newExpression;
}

- (NSUInteger)expressionCount;
{
    for (NSUInteger index = 0; index < 4; index++)
        if (_expressions[index] == nil)
            return index;

    return 4;
}

- (MMBooleanNode *)getExpressionNumber:(NSUInteger)index;
{
    if (index > 3)
        return nil;

    return _expressions[index];
}

- (void)addBooleanExpression:(MMBooleanNode *)newExpression;
{
    for (NSUInteger index = 0; index < 4; index++) {
        if (_expressions[index] == nil) {
            _expressions[index] = newExpression;
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
}

- (BOOL)matchRule:(NSArray *)categories;
{
    for (NSUInteger index = 0; index < [self expressionCount]; index++) {
        if (![_expressions[index] evaluateWithCategories:[categories objectAtIndex:index]])
            return NO;
    }

    return YES;
}

- (MMEquation *)getSymbolEquation:(int)index;
{
    return [_symbolEquations objectAtIndex:index];
}

- (void)evaluateSymbolEquationsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols withCacheTag:(NSUInteger)cache;
{
    NSUInteger count = [_symbolEquations count];
    // It is not okay to do these in order -- beat often depends on duration, mark1, mark2, and/or mark3.

    ruleSymbols.ruleDuration = (count > 0) ? [(MMEquation *)[_symbolEquations objectAtIndex:0] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.mark1        = (count > 2) ? [(MMEquation *)[_symbolEquations objectAtIndex:2] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.mark2        = (count > 3) ? [(MMEquation *)[_symbolEquations objectAtIndex:3] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.mark3        = (count > 4) ? [(MMEquation *)[_symbolEquations objectAtIndex:4] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.beat         = (count > 1) ? [(MMEquation *)[_symbolEquations objectAtIndex:1] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
}

- (NSMutableArray *)parameterTransitions;
{
    return _parameterTransitions;
}

- (NSMutableArray *)metaParameterTransitions;
{
    return _metaParameterTransitions;
}

- (NSMutableArray *)symbolEquations;
{
    return _symbolEquations;
}

- (MMTransition *)getSpecialProfile:(NSUInteger)index;
{
    if (index > 15)
        return nil;

    return _specialProfiles[index];
}

- (void)setSpecialProfile:(NSUInteger)index to:(MMTransition *)special;
{
    if (index > 15)
        return;

    _specialProfiles[index] = special;
}

- (BOOL)usesCategory:(MMCategory *)aCategory;
{
    NSUInteger count = [self expressionCount];
    for (NSUInteger index = 0; index < count; index++) {
        if ([_expressions[index] usesCategory:aCategory])
            return YES;
    }

    return NO;
}

- (BOOL)usesEquation:(MMEquation *)anEquation;
{
    if ([_symbolEquations indexOfObject:anEquation] != NSNotFound)
        return YES;

    return NO;
}

- (BOOL)usesTransition:(MMTransition *)aTransition;
{
    if ([_parameterTransitions indexOfObject:aTransition] != NSNotFound)
        return YES;
    if ([_metaParameterTransitions indexOfObject:aTransition] != NSNotFound)
        return YES;

    for (NSUInteger index = 0; index < 16; index++) {
        if (_specialProfiles[index] == aTransition)
            return YES;
    }

    return NO;
}

- (NSString *)ruleString;
{
    NSMutableString *ruleString = [[NSMutableString alloc] init];

    [_expressions[0] appendExpressionToString:ruleString];
    [ruleString appendString:@" >> "];
    [_expressions[1] appendExpressionToString:ruleString];

    NSString *str = [_expressions[2] expressionString];
    if (str != nil) {
        [ruleString appendString:@" >> "];
        [ruleString appendString:str];
    }

    str = [_expressions[3] expressionString];
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
        NSString *str = [_expressions[index] expressionString];
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
    NSParameterAssert([mainParameterList count] == [_parameterTransitions count]);

    if ([_parameterTransitions count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<parameter-profiles>\n"];

    count = [mainParameterList count];
    for (index = 0; index < count; index++) {
        MMParameter *aParameter = [mainParameterList objectAtIndex:index];
        MMTransition *aTransition = [_parameterTransitions objectAtIndex:index];

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
    NSParameterAssert([mainMetaParameterList count] == [_metaParameterTransitions count]);

    if ([_metaParameterTransitions count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<meta-parameter-profiles>\n"];

    count = [mainMetaParameterList count];
    for (index = 0; index < count; index++) {
        MMParameter *aParameter;
        MMTransition *aTransition;

        aParameter = [mainMetaParameterList objectAtIndex:index];
        aTransition = [_metaParameterTransitions objectAtIndex:index];

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
        if (_specialProfiles[index] != nil) {
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
        aTransition = _specialProfiles[index];

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

    if ([_symbolEquations count] == 0)
        return;

    [resultString indentToLevel:level];
    // TODO (2004-08-15): Rename this to symbol-equations.
    [resultString appendString:@"<expression-symbols>\n"];

    count = [_symbolEquations count];
    for (index = 0; index < count; index++) {
        MMEquation *anEquation;

        anEquation = [_symbolEquations objectAtIndex:index];

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
    NSUInteger oldExpressionCount = [self expressionCount];

    [self setExpression:exp1 number:0];
    [self setExpression:exp2 number:1];
    [self setExpression:exp3 number:2];
    [self setExpression:exp4 number:3];

    if (oldExpressionCount != [self expressionCount])
        [self setDefaults];
}

@end
