#import "MMRule.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MonetList.h"
#import "MMBooleanNode.h"
#import "MMBooleanParser.h"
#import "MMParameter.h"
#import "ParameterList.h"
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

- (id)init;
{
    if ([super init] == nil)
        return nil;

    /* Alloc lists to point to prototype transition specifiers */
    parameterProfiles = [[MonetList alloc] init];
    metaParameterProfiles = [[MonetList alloc] init];

    /* Set up list for Expression symbols */
    expressionSymbols = [[MonetList alloc] initWithCapacity:5];

    /* Zero out expressions and special Profiles */
    bzero(expressions, sizeof(MMBooleanNode *) * 4);
    bzero(specialProfiles, sizeof(id) * 16);

    comment = nil;

    return self;
}

- (void)dealloc;
{
    int index;

    [parameterProfiles release];
    [metaParameterProfiles release];
    [expressionSymbols release];

    for (index = 0 ; index < 4; index++)
        [expressions[index] release];

    // TODO (2004-03-05): Release special profiles

    [comment release];

    [super dealloc];
}

- (void)setDefaultsTo:(int)numPhones;
{
    id tempEntry = nil;
    MMEquation *anEquation, *defaultOnset, *defaultDuration;
    ParameterList *aParameterList;
    int i;

    /* Empty out the lists */
    [parameterProfiles removeAllObjects];
    [metaParameterProfiles removeAllObjects];
    [expressionSymbols removeAllObjects];

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
        [parameterProfiles addObject:tempEntry];
    }

    /* Alloc lists to point to prototype transition specifiers */
    aParameterList = [[self model] metaParameters];
    for (i = 0; i < [aParameterList count]; i++) {
        [metaParameterProfiles addObject:tempEntry];
    }

    switch (numPhones) {
      case 2:
          defaultDuration = [[self model] findEquationList:@"DefaultDurations" named:@"DiphoneDefault"];
          if (defaultDuration == nil)
              break;
          [expressionSymbols addObject:defaultDuration];

          defaultOnset = [[self model] findEquationList:@"SymbolDefaults" named:@"diBeat"];
          if (defaultOnset == nil)
              break;
          [expressionSymbols addObject:defaultOnset];

          [expressionSymbols addObject:defaultDuration]; /* Make the mark1 value == duration */
          break;

      case 3:
          defaultDuration = [[self model] findEquationList:@"DefaultDurations" named:@"TriphoneDefault"];
          if (defaultDuration == nil)
              break;
          [expressionSymbols addObject:defaultDuration];

          defaultOnset = [[self model] findEquationList:@"SymbolDefaults" named:@"triBeat"];
          if (defaultOnset == nil)
              break;
          [expressionSymbols addObject:defaultOnset];

          anEquation = [[self model] findEquationList:@"SymbolDefaults" named:@"Mark1"];
          if (anEquation == nil)
              break;
          [expressionSymbols addObject:anEquation];

          [expressionSymbols addObject:defaultDuration]; /* Make the  mark2 value == duration */
          break;

      case 4:
          defaultDuration = [[self model] findEquationList:@"DefaultDurations" named:@"TetraphoneDefault"];
          if (defaultDuration == nil)
              break;
          [expressionSymbols addObject:defaultDuration];

          defaultOnset = [[self model] findEquationList:@"SymbolDefaults" named:@"tetraBeat"]; // TODO (2004-03-24): Not in diphones.monet
          if (defaultOnset == nil)
              break;
          [expressionSymbols addObject:defaultOnset];

          anEquation = [[self model] findEquationList:@"SymbolDefaults" named:@"Mark1"];
          if (anEquation == nil)
              break;
          [expressionSymbols addObject:anEquation];

          anEquation = [[self model] findEquationList:@"SymbolDefaults" named:@"Mark2"];
          if  (anEquation == nil)
              break;
          [expressionSymbols addObject:anEquation];

          [expressionSymbols addObject:defaultDuration]; /* Make the mark3 value == duration */
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
        [parameterProfiles addObject:aTransition];
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
        [metaParameterProfiles addObject:aTransition];
}

- (void)removeParameterAtIndex:(int)index;
{
    [parameterProfiles removeObjectAtIndex:index];
}

- (void)removeMetaParameterAtIndex:(int)index;
{
    [metaParameterProfiles removeObjectAtIndex:index];
}

- (void)addStoredParameterProfile:(MMTransition *)aTransition;
{
    [parameterProfiles addObject:aTransition];
}

- (void)addParameterProfilesFromReferenceDictionary:(NSDictionary *)dict;
{
    ParameterList *parameters;
    unsigned int count, index;
    MMParameter *parameter;
    NSString *name;
    MMTransition *transition;

    parameters = [[self model] parameters];

    count = [parameters count];
    for (index = 0; index < count; index++) {

        parameter = [parameters objectAtIndex:index];
        name = [dict objectForKey:[parameter symbol]];
        transition = [[self model] findTransitionWithName:name];
        if (transition == nil) {
            NSLog(@"Error: Can't find transition named: %@", name);
        } else {
            [self addStoredParameterProfile:transition];
        }
    }
}

- (void)addStoredMetaParameterProfile:(MMTransition *)aTransition;
{
    [metaParameterProfiles addObject:aTransition];
}

- (void)addMetaParameterProfilesFromReferenceDictionary:(NSDictionary *)dict;
{
    ParameterList *parameters;
    unsigned int count, index;
    MMParameter *parameter;
    NSString *name;
    MMTransition *transition;

    parameters = [[self model] metaParameters];

    count = [parameters count];
    for (index = 0; index < count; index++) {

        parameter = [parameters objectAtIndex:index];
        name = [dict objectForKey:[parameter symbol]];
        transition = [[self model] findTransitionWithName:name];
        if (transition == nil) {
            NSLog(@"Error: Can't find transition named: %@", name);
        } else {
            [self addStoredMetaParameterProfile:transition];
        }
    }
}

- (void)addSpecialProfilesFromReferenceDictionary:(NSDictionary *)dict;
{
    ParameterList *parameters;
    unsigned int count, index;
    MMParameter *parameter;
    NSString *transitionName;
    MMTransition *transition;

    //NSLog(@"%s, dict: %@", _cmd, [dict description]);
    parameters = [[self model] parameters];

    count = [parameters count];
    for (index = 0; index < count; index++) {
        parameter = [parameters objectAtIndex:index];
        transitionName = [dict objectForKey:[parameter symbol]];
        if (transitionName != nil) {
            //NSLog(@"parameter: %@, transition name: %@", [parameter symbol], transitionName);
            transition = [[self model] findSpecialTransitionWithName:transitionName];
            if (transition == nil) {
                NSLog(@"Error: Can't find transition named: %@", transitionName);
            } else {
                [self setSpecialProfile:index to:transition];
            }
        }
    }
}

- (void)addStoredExpressionSymbol:(MMEquation *)anEquation;
{
    [expressionSymbols addObject:anEquation];
}

- (void)addExpressionSymbolsFromReferenceDictionary:(NSDictionary *)dict;
{
    NSArray *symbols;
    unsigned int count, index;
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
            [self addStoredExpressionSymbol:equation];
        }
    }

    [symbols release];
}

- (void)setExpression:(MMBooleanNode *)newExpression number:(int)index;
{
    if ((index > 3) || (index < 0))
        return;

    if (newExpression == expressions[index])
        return;

    [expressions[index] release];
    expressions[index] = [newExpression retain];
}

- (int)numberExpressions;
{
    int index;

    for (index = 0; index < 4; index++)
        if (expressions[index] == nil)
            return index;

    return index;
}

- (MMBooleanNode *)getExpressionNumber:(int)index;
{
    if ((index > 3) || (index < 0))
        return nil;

    return expressions[index];
}

- (void)addBooleanExpression:(MMBooleanNode *)newExpression;
{
    int index;

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

- (int)matchRule:(MonetList *)categories;
{
    int index;

    for (index = 0; index < [self numberExpressions]; index++) {
        if (![expressions[index] evaluateWithCategories:[categories objectAtIndex:index]])
            return 0;
    }

    return 1;
}

- (MMEquation *)getExpressionSymbol:(int)index;
{
    return [expressionSymbols objectAtIndex:index];
}

- (void)evaluateExpressionSymbols:(double *)buffer tempos:(double *)tempos phones:(PhoneList *)phones withCache:(int)cache;
{
    // TODO (2004-03-02): Is it okay to do these in order? (2004-04-01): No.
    buffer[0] = [(MMEquation *)[expressionSymbols objectAtIndex:0] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
    buffer[2] = [(MMEquation *)[expressionSymbols objectAtIndex:2] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
    buffer[3] = [(MMEquation *)[expressionSymbols objectAtIndex:3] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
    buffer[4] = [(MMEquation *)[expressionSymbols objectAtIndex:4] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
    buffer[1] = [(MMEquation *)[expressionSymbols objectAtIndex:1] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
}

- (MonetList *)parameterList;
{
    return parameterProfiles;
}

- (MonetList *)metaParameterList;
{
    return metaParameterProfiles;
}

- (MonetList *)symbols;
{
    return expressionSymbols;
}

- (MMTransition *)getSpecialProfile:(int)index;
{
    if ((index > 15) || (index < 0))
        return nil;

    return specialProfiles[index];
}

- (void)setSpecialProfile:(int)index to:(MMTransition *)special;
{
    if ((index > 15) || (index < 0))
        return;

    specialProfiles[index] = special;
}

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    int count, index;

    count = [self numberExpressions];
    for (index = 0; index < count; index++) {
        if ([expressions[index] isCategoryUsed:aCategory])
            return YES;
    }

    return NO;
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    if ([expressionSymbols indexOfObject:anEquation] != NSNotFound)
        return YES;

    return NO;
}

- (BOOL)isTransitionUsed:(MMTransition *)aTransition;
{
    int index;

    if ([parameterProfiles indexOfObject:aTransition] != NSNotFound)
        return YES;
    if ([metaParameterProfiles indexOfObject:aTransition] != NSNotFound)
        return YES;

    for (index = 0; index < 16; index++) {
        if (specialProfiles[index] == aTransition)
            return YES;
    }

    return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int index, j, k;
    int symbolCount, parameterCount, metaParmaterCount;
    id tempParameter;
    char *c_comment;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];
    //NSLog(@"model: %p, class: %@", model, NSStringFromClass([model class]));

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    parameterProfiles = [[MonetList alloc] init];
    metaParameterProfiles = [[MonetList alloc] init];
    expressionSymbols = [[MonetList alloc] initWithCapacity:5];

    [aDecoder decodeValuesOfObjCTypes:"i*", &j, &c_comment];
    comment = [[NSString stringWithASCIICString:c_comment] retain];

    bzero(expressions, sizeof(MMBooleanNode *) * 4);
    bzero(specialProfiles, sizeof(id) * 16);

    for (index = 0; index < j; index++) {
        expressions[index] = [[aDecoder decodeObject] retain];
    }

    // TODO (2004-03-05): These removeAllObjects: calls should be redundant.
    [expressionSymbols removeAllObjects];
    [parameterProfiles removeAllObjects];
    [metaParameterProfiles removeAllObjects];

    [aDecoder decodeValuesOfObjCTypes:"iii", &symbolCount, &parameterCount, &metaParmaterCount];
    //NSLog(@"symbolCount: %d, parameterCount: %d, metaParmaterCount: %d", symbolCount, parameterCount, metaParmaterCount);

    for (index = 0; index < symbolCount; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        //NSLog(@"j: %d, k: %d", j, k);
        tempParameter = [model findEquation:j andIndex:k];
        [expressionSymbols addObject:tempParameter];
    }

    for (index = 0; index < parameterCount; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        //NSLog(@"j: %d, k: %d", j, k);
        tempParameter = [model findTransition:j andIndex:k];
        [parameterProfiles addObject:tempParameter];
    }

    for (index = 0; index < metaParmaterCount; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        //NSLog(@"j: %d, k: %d", j, k);
        [metaParameterProfiles addObject:[model findTransition:j andIndex:k]];
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
    return [NSString stringWithFormat:@"<%@>[%p]: parameterProfiles: %@, metaParameterProfiles: %@, expressionSymbols(%d): %@, comment: %@, e1: %@, e2: %@, e3: %@, e4: %@",
                     NSStringFromClass([self class]), self, parameterProfiles, metaParameterProfiles, [expressionSymbols count], expressionSymbols,
                     comment, [expressions[0] expressionString], [expressions[1] expressionString], [expressions[2] expressionString],
                     [expressions[3] expressionString]];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    unsigned int index;

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

    [self _appendXMLForParameterProfilesToString:resultString level:level + 1];
    [self _appendXMLForMetaParameterProfilesToString:resultString level:level + 1];
    [self _appendXMLForSpecialProfilesToString:resultString level:level + 1];
    [self _appendXMLForExpressionSymbolsToString:resultString level:level + 1];

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</rule>\n"];
}

- (void)_appendXMLForParameterProfilesToString:(NSMutableString *)resultString level:(int)level;
{
    ParameterList *mainParameterList;
    int count, index;

    mainParameterList = [[self model] parameters];
    assert([mainParameterList count] == [parameterProfiles count]);

    if ([parameterProfiles count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<parameter-profiles>\n"];

    count = [mainParameterList count];
    for (index = 0; index < count; index++) {
        MMParameter *aParameter;
        MMTransition *aTransition;

        aParameter = [mainParameterList objectAtIndex:index];
        aTransition = [parameterProfiles objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<parameter-transition name=\"%@\" transition=\"%@\"/>\n",
                      GSXMLAttributeString([aParameter symbol], NO), GSXMLAttributeString([aTransition name], NO)];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</parameter-profiles>\n"];
}

- (void)_appendXMLForMetaParameterProfilesToString:(NSMutableString *)resultString level:(int)level;
{
    ParameterList *mainMetaParameterList;
    int count, index;

    mainMetaParameterList = [[self model] metaParameters];
    assert([mainMetaParameterList count] == [metaParameterProfiles count]);

    if ([metaParameterProfiles count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<meta-parameter-profiles>\n"];

    count = [mainMetaParameterList count];
    for (index = 0; index < count; index++) {
        MMParameter *aParameter;
        MMTransition *aTransition;

        aParameter = [mainMetaParameterList objectAtIndex:index];
        aTransition = [metaParameterProfiles objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<parameter-transition name=\"%@\" transition=\"%@\"/>\n",
                      GSXMLAttributeString([aParameter symbol], NO), GSXMLAttributeString([aTransition name], NO)];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</meta-parameter-profiles>\n"];
}

- (void)_appendXMLForSpecialProfilesToString:(NSMutableString *)resultString level:(int)level;
{
    ParameterList *mainParameterList;
    int count, index;
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
                          GSXMLAttributeString([aParameter symbol], NO), GSXMLAttributeString([aTransition name], NO)];
        }
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</special-profiles>\n"];
}

- (void)_appendXMLForExpressionSymbolsToString:(NSMutableString *)resultString level:(int)level;
{
    int count, index;

    if ([expressionSymbols count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<expression-symbols>\n"];

    count = [expressionSymbols count];
    for (index = 0; index < count; index++) {
        MMEquation *anEquation;

        anEquation = [expressionSymbols objectAtIndex:index];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<symbol-equation name=\"%@\" equation=\"%@\"/>\n",
                      GSXMLAttributeString([self expressionSymbolNameAtIndex:index], NO), GSXMLAttributeString([anEquation name], NO)];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</expression-symbols>\n"];
}

- (NSString *)expressionSymbolNameAtIndex:(int)index;
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
    int oldExpressionCount;

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
        MXMLArrayDelegate *newDelegate;

        // TODO (2004-05-14): It will need to implement initWithXMLAttributes:context:, and use the boolean parser.  Hmm, need a BooleanNode baseclass?
        newDelegate = [[MXMLStringArrayDelegate alloc] initWithChildElementName:@"boolean-expression" delegate:self addObjectSelector:@selector(addBooleanExpressionString:)];
        //newDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"boolean-expression" class:[NSString class] delegate:self addObjectSelector:@selector(addPoint:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"parameter-profiles"]) {
        MXMLReferenceDictionaryDelegate *newDelegate;

        newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"parameter-transition" keyAttributeName:@"name" referenceAttributeName:@"transition"
                                                               delegate:self addObjectsSelector:@selector(addParameterProfilesFromReferenceDictionary:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"meta-parameter-profiles"]) {
        MXMLReferenceDictionaryDelegate *newDelegate;

        newDelegate = [[MXMLReferenceDictionaryDelegate alloc] initWithChildElementName:@"parameter-transition" keyAttributeName:@"name" referenceAttributeName:@"transition"
                                                               delegate:self addObjectsSelector:@selector(addMetaParameterProfilesFromReferenceDictionary:)];
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
                                                               delegate:self addObjectsSelector:@selector(addExpressionSymbolsFromReferenceDictionary:)];
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
