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
        _parameterTransitions     = [[NSMutableArray alloc] init];
        _metaParameterTransitions = [[NSMutableArray alloc] init];
        _symbolEquations          = [[NSMutableArray alloc] init];
        
        /* Zero out expressions and special Profiles */
        bzero(_expressions,     sizeof(MMBooleanNode *) * 4);
        bzero(_specialProfiles, sizeof(MMTransition *)  * 16);
    }

    return self;
}

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"rule" isEqualToString:element.name]);

    if ((self = [super initWithXMLElement:element error:error])) {
        _parameterTransitions     = [[NSMutableArray alloc] init];
        _metaParameterTransitions = [[NSMutableArray alloc] init];
        _symbolEquations          = [[NSMutableArray alloc] init];

        /* Zero out expressions and special Profiles */
        bzero(_expressions,     sizeof(MMBooleanNode *) * 4);
        bzero(_specialProfiles, sizeof(MMTransition *)  * 16);

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

- (void)addStoredParameterTransition:(MMTransition *)transition;
{
    [_parameterTransitions addObject:transition];
}

- (void)addParameterTransitionsFromReferenceDictionary:(NSDictionary *)dict;
{
    for (MMParameter *parameter in self.model.parameters) {
        NSString *name = dict[parameter.name];
        MMTransition *transition = [self.model findTransitionWithName:name];
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
    for (MMParameter *parameter in self.model.metaParameters) {
        NSString *name = dict[parameter.name];
        MMTransition *transition = [self.model findTransitionWithName:name];
        if (transition == nil) {
            NSLog(@"Error: Can't find transition named: %@", name);
        } else {
            [self addStoredMetaParameterTransition:transition];
        }
    }
}

- (void)addSpecialProfilesFromReferenceDictionary:(NSDictionary *)dict;
{
    [self.model.parameters enumerateObjectsUsingBlock:^(MMParameter *parameter, NSUInteger index, BOOL *stop) {
        NSString *transitionName = dict[parameter.name];
        if (transitionName != nil) {
            //NSLog(@"parameter: %@, transition name: %@", [parameter name], transitionName);
            MMTransition *transition = [self.model findSpecialTransitionWithName:transitionName];
            if (transition == nil) {
                NSLog(@"Error: Can't find transition named: %@", transitionName);
            } else {
                [self setSpecialProfile:index to:transition];
            }
        }
    }];
}

- (void)addStoredSymbolEquation:(MMEquation *)equation;
{
    [_symbolEquations addObject:equation];
}

- (void)addSymbolEquationsFromReferenceDictionary:(NSDictionary *)dict;
{
    NSArray *symbols = [[NSArray alloc] initWithObjects:@"rd", @"beat", @"mark1", @"mark2", @"mark3", nil];

    for (NSString *symbolName in symbols) {
        NSString *equationName = dict[symbolName];
        if (equationName == nil)
            break;

        MMEquation *equation = [self.model findEquationWithName:equationName];
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

- (void)addBooleanExpressionString:(NSString *)string;
{
    MMBooleanParser *parser = [[MMBooleanParser alloc] initWithModel:self.model];

    MMBooleanNode *result = [parser parseString:string];
    if (result == nil) {
        NSLog(@"Error parsing boolean expression: %@", parser.errorMessage);
    } else {
        [self addBooleanExpression:result];
    }
}

- (BOOL)matchRule:(NSArray *)categories;
{
    for (NSUInteger index = 0; index < [self expressionCount]; index++) {
        if (![_expressions[index] evaluateWithCategories:categories[index]])
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

    ruleSymbols.ruleDuration = (count > 0) ? [(MMEquation *)_symbolEquations[0] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.mark1        = (count > 2) ? [(MMEquation *)_symbolEquations[2] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.mark2        = (count > 3) ? [(MMEquation *)_symbolEquations[3] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.mark3        = (count > 4) ? [(MMEquation *)_symbolEquations[4] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
    ruleSymbols.beat         = (count > 1) ? [(MMEquation *)_symbolEquations[1] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:cache] : 0.0;
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

- (BOOL)usesEquation:(MMEquation *)equation;
{
    if ([_symbolEquations indexOfObject:equation] != NSNotFound)
        return YES;

    return NO;
}

- (BOOL)usesTransition:(MMTransition *)transition;
{
    if ([_parameterTransitions indexOfObject:transition] != NSNotFound)
        return YES;
    if ([_metaParameterTransitions indexOfObject:transition] != NSNotFound)
        return YES;

    for (NSUInteger index = 0; index < 16; index++) {
        if (_specialProfiles[index] == transition)
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

#pragma mark - XML Archiving

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendString:@"<rule>\n"];

    [resultString indentToLevel:level + 1];
    [resultString appendString:@"<boolean-expressions>\n"];

    for (NSUInteger index = 0; index < 4; index++) {
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
    NSArray *mainParameterList = self.model.parameters;
    NSParameterAssert([mainParameterList count] == [_parameterTransitions count]);

    if ([_parameterTransitions count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<parameter-profiles>\n"];

    NSUInteger count = [mainParameterList count];
    for (NSUInteger index = 0; index < count; index++) {
        MMParameter *parameter   = mainParameterList[index];
        MMTransition *transition = _parameterTransitions[index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<parameter-transition name=\"%@\" transition=\"%@\"/>\n",
                      GSXMLAttributeString([parameter name], NO), GSXMLAttributeString([transition name], NO)];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</parameter-profiles>\n"];
}

- (void)_appendXMLForMetaParameterTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSArray *mainMetaParameterList = self.model.metaParameters;
    NSParameterAssert([mainMetaParameterList count] == [_metaParameterTransitions count]);

    if ([_metaParameterTransitions count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<meta-parameter-profiles>\n"];

    NSUInteger count = [mainMetaParameterList count];
    for (NSUInteger index = 0; index < count; index++) {
        MMParameter *parameter   = mainMetaParameterList[index];
        MMTransition *transition = _metaParameterTransitions[index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<parameter-transition name=\"%@\" transition=\"%@\"/>\n",
                      GSXMLAttributeString([parameter name], NO), GSXMLAttributeString([transition name], NO)];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</meta-parameter-profiles>\n"];
}

- (void)_appendXMLForSpecialProfilesToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    BOOL hasSpecialProfiles = NO;

    NSArray *mainParameterList = self.model.parameters;

    NSUInteger count = [mainParameterList count];
    for (NSUInteger index = 0; index < count && index < 16; index++) {
        if (_specialProfiles[index] != nil) {
            hasSpecialProfiles = YES;
            break;
        }
    }

    if (hasSpecialProfiles == NO)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<special-profiles>\n"];

    for (NSUInteger index = 0; index < count && index < 16; index++) {
        MMParameter *parameter   = mainParameterList[index];
        MMTransition *transition = _specialProfiles[index];

        if (transition != nil) {
            [resultString indentToLevel:level + 1];
            [resultString appendFormat:@"<parameter-transition name=\"%@\" transition=\"%@\"/>\n",
                          GSXMLAttributeString([parameter name], NO), GSXMLAttributeString([transition name], NO)];
        }
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</special-profiles>\n"];
}

- (void)_appendXMLForSymbolEquationsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    if ([_symbolEquations count] == 0)
        return;

    [resultString indentToLevel:level];
    // TODO (2004-08-15): Rename this to symbol-equations.
    [resultString appendString:@"<expression-symbols>\n"];

    [_symbolEquations enumerateObjectsUsingBlock:^(MMEquation *equation, NSUInteger index, BOOL *stop) {
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<symbol-equation name=\"%@\" equation=\"%@\"/>\n",
                      GSXMLAttributeString([self symbolNameAtIndex:index], NO), GSXMLAttributeString([equation name], NO)];
    }];

    [resultString indentToLevel:level];
    [resultString appendString:@"</expression-symbols>\n"];
}

#pragma mark -

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
