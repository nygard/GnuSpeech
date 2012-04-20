//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMRule.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MonetList.h"
#import "MMBooleanNode.h"
#import "MMBooleanParser.h"
#import "MMParameter.h"
#import "MMEquation.h"
#import "MMSymbol.h"
#import "MMTransition.h"

#import "MModel.h"
#import "MUnarchiver.h"
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
    NSString *comment;
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    parameterTransitions = [[NSMutableArray alloc] init];
    metaParameterTransitions = [[NSMutableArray alloc] init];
    symbolEquations = [[NSMutableArray alloc] init];

    /* Zero out expressions and special Profiles */
    bzero(expressions, sizeof(MMBooleanNode *) * 4);
    bzero(specialProfiles, sizeof(id) * 16);

    comment = nil;

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

    [comment release];

    [super dealloc];
}

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
          tempEntry = [[self model] findTransitionList:@"Defaults" named:@"Diphone"];
          break;
      case 3:
          tempEntry = [[self model] findTransitionList:@"Defaults" named:@"Triphone"];
          break;
      case 4:
          tempEntry = [[self model] findTransitionList:@"Defaults" named:@"Tetraphone"];
          break;
    }

    if (tempEntry == nil) {
        NSLog(@"CANNOT find temp entry");
    }

    aParameterList = [[self model] parameters];
    for (i = 0; i < [aParameterList count]; i++) {
        [parameterTransitions addObject:tempEntry];
    }

    /* Alloc lists to point to prototype transition specifiers */
    aParameterList = [[self model] metaParameters];
    for (i = 0; i < [aParameterList count]; i++) {
        [metaParameterTransitions addObject:tempEntry];
    }

    switch (numPhones) {
      case 2:
          defaultDuration = [[self model] findEquationList:@"DefaultDurations" named:@"DiphoneDefault"];
          if (defaultDuration == nil)
              break;
          [symbolEquations addObject:defaultDuration];

          defaultOnset = [[self model] findEquationList:@"SymbolDefaults" named:@"diBeat"];
          if (defaultOnset == nil)
              break;
          [symbolEquations addObject:defaultOnset];

          [symbolEquations addObject:defaultDuration]; /* Make the mark1 value == duration */
          break;

      case 3:
          defaultDuration = [[self model] findEquationList:@"DefaultDurations" named:@"TriphoneDefault"];
          if (defaultDuration == nil)
              break;
          [symbolEquations addObject:defaultDuration];

          defaultOnset = [[self model] findEquationList:@"SymbolDefaults" named:@"triBeat"];
          if (defaultOnset == nil)
              break;
          [symbolEquations addObject:defaultOnset];

          anEquation = [[self model] findEquationList:@"SymbolDefaults" named:@"Mark1"];
          if (anEquation == nil)
              break;
          [symbolEquations addObject:anEquation];

          [symbolEquations addObject:defaultDuration]; /* Make the  mark2 value == duration */
          break;

      case 4:
          defaultDuration = [[self model] findEquationList:@"DefaultDurations" named:@"TetraphoneDefault"];
          if (defaultDuration == nil)
              break;
          [symbolEquations addObject:defaultDuration];

          defaultOnset = [[self model] findEquationList:@"SymbolDefaults" named:@"tetraBeat"]; // TODO (2004-03-24): Not in diphones.monet
          if (defaultOnset == nil)
              break;
          [symbolEquations addObject:defaultOnset];

          anEquation = [[self model] findEquationList:@"SymbolDefaults" named:@"Mark1"];
          if (anEquation == nil)
              break;
          [symbolEquations addObject:anEquation];

          anEquation = [[self model] findEquationList:@"SymbolDefaults" named:@"Mark2"];
          if  (anEquation == nil)
              break;
          [symbolEquations addObject:anEquation];

          [symbolEquations addObject:defaultDuration]; /* Make the mark3 value == duration */
          break;
    }
}

- (void)addDefaultParameter;
{
    MMTransition *aTransition = nil;

    switch ([self numberExpressions]) {
      case 2:
          aTransition = [[self model] findTransitionList:@"Defaults" named:@"Diphone"];
          break;
      case 3:
          aTransition = [[self model] findTransitionList:@"Defaults" named:@"Triphone"];
          break;
      case 4:
          aTransition = [[self model] findTransitionList:@"Defaults" named:@"Tetraphone"];
          break;
    }

    if (aTransition != nil)
        [parameterTransitions addObject:aTransition];
}

// Warning (building for 10.2 deployment) (2004-04-02): tempEntry might be used uninitialized in this function
- (void)addDefaultMetaParameter;
{
    MMTransition *aTransition = nil;

    switch ([self numberExpressions]) {
      case 2:
          aTransition = [[self model] findTransitionList:@"Defaults" named:@"Diphone"];
          break;
      case 3:
          aTransition = [[self model] findTransitionList:@"Defaults" named:@"Triphone"];
          break;
      case 4:
          aTransition = [[self model] findTransitionList:@"Defaults" named:@"Tetraphone"];
          break;
    }

    if (aTransition != nil)
        [metaParameterTransitions addObject:aTransition];
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
    NSArray *parameters;
    NSUInteger count, index;
    MMParameter *parameter;
    NSString *name;
    MMTransition *transition;

    parameters = [[self model] parameters];

    count = [parameters count];
    for (index = 0; index < count; index++) {

        parameter = [parameters objectAtIndex:index];
        name = [dict objectForKey:[parameter name]];
        transition = [[self model] findTransitionWithName:name];
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
    NSArray *parameters;
    NSUInteger count, index;
    MMParameter *parameter;
    NSString *name;
    MMTransition *transition;

    parameters = [[self model] metaParameters];

    count = [parameters count];
    for (index = 0; index < count; index++) {

        parameter = [parameters objectAtIndex:index];
        name = [dict objectForKey:[parameter name]];
        transition = [[self model] findTransitionWithName:name];
        if (transition == nil) {
            NSLog(@"Error: Can't find transition named: %@", name);
        } else {
            [self addStoredMetaParameterTransition:transition];
        }
    }
}

- (void)addSpecialProfilesFromReferenceDictionary:(NSDictionary *)dict;
{
    NSArray *parameters;
    NSUInteger count, index;
    MMParameter *parameter;
    NSString *transitionName;
    MMTransition *transition;

    //NSLog(@"%s, dict: %@", _cmd, [dict description]);
    parameters = [[self model] parameters];

    count = [parameters count];
    for (index = 0; index < count; index++) {
        parameter = [parameters objectAtIndex:index];
        transitionName = [dict objectForKey:[parameter name]];
        if (transitionName != nil) {
            //NSLog(@"parameter: %@, transition name: %@", [parameter name], transitionName);
            transition = [[self model] findSpecialTransitionWithName:transitionName];
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
    NSArray *symbols;
    NSUInteger count, index;
    NSString *symbolName, *equationName;
    MMEquation *equation;

    symbols = [[NSArray alloc] initWithObjects:@"rd", @"beat", @"mark1", @"mark2", @"mark3", nil];

    count = [symbols count];
    for (index = 0; index < count; index++) {

        symbolName = [symbols objectAtIndex:index];
        equationName = [dict objectForKey:symbolName];
        if (equationName == nil)
            break;

        equation = [[self model] findEquationWithName:equationName];
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
    NSUInteger index;

    for (index = 0; index < 4; index++) {
        if (expressions[index] == nil) {
            expressions[index] = [newExpression retain];
            return;
        }
    }

    NSLog(@"Warning: No room for another boolean expression in MMRule.");
}

- (void)addBooleanExpressionString:(NSString *)aString;
{
    MMBooleanParser *parser;
    MMBooleanNode *result;

    parser = [[MMBooleanParser alloc] initWithModel:[self model]];

    result = [parser parseString:aString];
    if (result == nil) {
        NSLog(@"Error parsing boolean expression: %@", [parser errorMessage]);
    } else {
        [self addBooleanExpression:result];
    }

    [parser release];
}

- (NSString *)comment;
{
    return comment;
}

- (void)setComment:(NSString *)newComment;
{
    if (newComment == comment)
        return;

    [comment release];
    comment = [newComment retain];
}

- (BOOL)hasComment;
{
    return comment != nil && [comment length] > 0;
}

- (BOOL)matchRule:(NSArray *)categories;
{
    NSUInteger index;

    for (index = 0; index < [self numberExpressions]; index++) {
        if (![expressions[index] evaluateWithCategories:[categories objectAtIndex:index]])
            return NO;
    }

    return YES;
}

- (MMEquation *)getSymbolEquation:(int)index;
{
    return [symbolEquations objectAtIndex:index];
}

- (void)evaluateSymbolEquations:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures withCache:(NSUInteger)cache;
{
    NSUInteger count;

    count = [symbolEquations count];
    // It is not okay to do these in order -- beat often depends on duration, mark1, mark2, and/or mark3.

    if (count > 0)
        ruleSymbols->ruleDuration = [(MMEquation *)[symbolEquations objectAtIndex:0] evaluate:ruleSymbols tempos:tempos postures:postures andCacheWith:cache];
    else
        ruleSymbols->ruleDuration = 0.0;

    if (count > 2)
        ruleSymbols->mark1 = [(MMEquation *)[symbolEquations objectAtIndex:2] evaluate:ruleSymbols tempos:tempos postures:postures andCacheWith:cache];
    else
        ruleSymbols->mark1 = 0.0;

    if (count > 3)
        ruleSymbols->mark2 = [(MMEquation *)[symbolEquations objectAtIndex:3] evaluate:ruleSymbols tempos:tempos postures:postures andCacheWith:cache];
    else
        ruleSymbols->mark2 = 0.0;

    if (count > 4)
        ruleSymbols->mark3 = [(MMEquation *)[symbolEquations objectAtIndex:4] evaluate:ruleSymbols tempos:tempos postures:postures andCacheWith:cache];
    else
        ruleSymbols->mark3 = 0.0;

    if (count > 1)
        ruleSymbols->beat = [(MMEquation *)[symbolEquations objectAtIndex:1] evaluate:ruleSymbols tempos:tempos postures:postures andCacheWith:cache];
    else
        ruleSymbols->beat = 0.0;
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

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    NSUInteger count, index;

    count = [self numberExpressions];
    for (index = 0; index < count; index++) {
        if ([expressions[index] isCategoryUsed:aCategory])
            return YES;
    }

    return NO;
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    if ([symbolEquations indexOfObject:anEquation] != NSNotFound)
        return YES;

    return NO;
}

- (BOOL)isTransitionUsed:(MMTransition *)aTransition;
{
    NSUInteger index;

    if ([parameterTransitions indexOfObject:aTransition] != NSNotFound)
        return YES;
    if ([metaParameterTransitions indexOfObject:aTransition] != NSNotFound)
        return YES;

    for (index = 0; index < 16; index++) {
        if (specialProfiles[index] == aTransition)
            return YES;
    }

    return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    NSUInteger index, j, k;
    NSUInteger symbolCount, parameterCount, metaParmaterCount;
    id tempParameter;
    char *c_comment;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];
    //NSLog(@"model: %p, class: %@", model, NSStringFromClass([model class]));

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    /*NSInteger archivedVersion =*/ [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    parameterTransitions = [[NSMutableArray alloc] init];
    metaParameterTransitions = [[NSMutableArray alloc] init];
    symbolEquations = [[NSMutableArray alloc] init];

    [aDecoder decodeValuesOfObjCTypes:"i*", &j, &c_comment];
    comment = [[NSString stringWithASCIICString:c_comment] retain];
    free(c_comment);

    bzero(expressions, sizeof(MMBooleanNode *) * 4);
    bzero(specialProfiles, sizeof(id) * 16);

    for (index = 0; index < j; index++) {
        expressions[index] = [[aDecoder decodeObject] retain];
    }

    [aDecoder decodeValuesOfObjCTypes:"iii", &symbolCount, &parameterCount, &metaParmaterCount];
    //NSLog(@"symbolCount: %d, parameterCount: %d, metaParmaterCount: %d", symbolCount, parameterCount, metaParmaterCount);

    for (index = 0; index < symbolCount; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        //NSLog(@"j: %d, k: %d", j, k);
        tempParameter = [model findEquation:j andIndex:k];
        [symbolEquations addObject:tempParameter];
    }

    for (index = 0; index < parameterCount; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        //NSLog(@"j: %d, k: %d", j, k);
        tempParameter = [model findTransition:j andIndex:k];
        [parameterTransitions addObject:tempParameter];
    }

    for (index = 0; index < metaParmaterCount; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        //NSLog(@"j: %d, k: %d", j, k);
        [metaParameterTransitions addObject:[model findTransition:j andIndex:k]];
    }

    for (index = 0; index <  16; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        //NSLog(@"j: %d, k: %d", j, k);
        // TODO (2004-03-05): Bug fixed from original code
        if (j == -1) {
            specialProfiles[index] = nil;
        } else {
            specialProfiles[index] = [model findSpecial:j andIndex:k];
        }
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)ruleString;
{
    NSMutableString *ruleString;
    NSString *str;

    ruleString = [[[NSMutableString alloc] init] autorelease];

    [expressions[0] expressionString:ruleString];
    [ruleString appendString:@" >> "];
    [expressions[1] expressionString:ruleString];

    str = [expressions[2] expressionString];
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

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: parameterTransitions: %@, metaParameterTransitions: %@, symbolEquations(%lu): %@, comment: %@, e1: %@, e2: %@, e3: %@, e4: %@",
                     NSStringFromClass([self class]), self, parameterTransitions, metaParameterTransitions, [symbolEquations count], symbolEquations,
                     comment, [expressions[0] expressionString], [expressions[1] expressionString], [expressions[2] expressionString],
                     [expressions[3] expressionString]];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSUInteger index;

    [resultString indentToLevel:level];
    [resultString appendString:@"<rule>\n"];

    [resultString indentToLevel:level + 1];
    [resultString appendString:@"<boolean-expressions>\n"];

    for (index = 0; index < 4; index++) {
        NSString *str;

        str = [expressions[index] expressionString];
        if (str != nil) {
            [resultString indentToLevel:level + 2];
            [resultString appendFormat:@"<boolean-expression>%@</boolean-expression>\n", GSXMLCharacterData(str)];
        }
    }

    [resultString indentToLevel:level + 1];
    [resultString appendString:@"</boolean-expressions>\n"];

    if (comment != nil) {
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];
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
    NSArray *mainParameterList;
    NSUInteger count, index;

    mainParameterList = [[self model] parameters];
    assert([mainParameterList count] == [parameterTransitions count]);

    if ([parameterTransitions count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<parameter-profiles>\n"];

    count = [mainParameterList count];
    for (index = 0; index < count; index++) {
        MMParameter *aParameter;
        MMTransition *aTransition;

        aParameter = [mainParameterList objectAtIndex:index];
        aTransition = [parameterTransitions objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<parameter-transition name=\"%@\" transition=\"%@\"/>\n",
                      GSXMLAttributeString([aParameter name], NO), GSXMLAttributeString([aTransition name], NO)];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</parameter-profiles>\n"];
}

- (void)_appendXMLForMetaParameterTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    NSArray *mainMetaParameterList;
    NSUInteger count, index;

    mainMetaParameterList = [[self model] metaParameters];
    assert([mainMetaParameterList count] == [metaParameterTransitions count]);

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
    NSArray *mainParameterList;
    NSUInteger count, index;
    BOOL hasSpecialProfiles = NO;

    mainParameterList = [[self model] parameters];

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
    NSUInteger oldExpressionCount;

    oldExpressionCount = [self numberExpressions];

    [self setExpression:exp1 number:0];
    [self setExpression:exp2 number:1];
    [self setExpression:exp3 number:2];
    [self setExpression:exp4 number:3];

    if (oldExpressionCount != [self numberExpressions])
        [self setDefaultsTo:[self numberExpressions]];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    if ([self init] == nil)
        return nil;

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"comment"]) {
        MXMLPCDataDelegate *newDelegate;

        newDelegate = [[MXMLPCDataDelegate alloc] initWithElementName:elementName delegate:self setSelector:@selector(setComment:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"boolean-expressions"]) {
        MXMLStringArrayDelegate *newDelegate;

        newDelegate = [[MXMLStringArrayDelegate alloc] initWithChildElementName:@"boolean-expression" delegate:self addObjectSelector:@selector(addBooleanExpressionString:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"parameter-profiles"]) {
        MXMLReferenceDictionaryDelegate *newDelegate;

        newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"parameter-transition" keyAttributeName:@"name" referenceAttributeName:@"transition"
                                                               delegate:self addObjectsSelector:@selector(addParameterTransitionsFromReferenceDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"meta-parameter-profiles"]) {
        MXMLReferenceDictionaryDelegate *newDelegate;

        newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"parameter-transition" keyAttributeName:@"name" referenceAttributeName:@"transition"
                                                               delegate:self addObjectsSelector:@selector(addMetaParameterTransitionsFromReferenceDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"special-profiles"]) {
        MXMLReferenceDictionaryDelegate *newDelegate;

        newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"parameter-transition" keyAttributeName:@"name" referenceAttributeName:@"transition"
                                                               delegate:self addObjectsSelector:@selector(addSpecialProfilesFromReferenceDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"expression-symbols"]) {
        MXMLReferenceDictionaryDelegate *newDelegate;

        newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"symbol-equation" keyAttributeName:@"name" referenceAttributeName:@"equation"
                                                               delegate:self addObjectsSelector:@selector(addSymbolEquationsFromReferenceDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else {
        NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

@end
