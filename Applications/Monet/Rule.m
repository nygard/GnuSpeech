#import "Rule.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "AppController.h"
#import "BooleanExpression.h"
#import "MonetList.h"
#import "ParameterList.h"
#import "ProtoEquation.h"
#import "PrototypeManager.h"

@implementation Rule

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
    bzero(expressions, sizeof(BooleanExpression *) * 4);
    bzero(specialProfiles, sizeof(id) * 16);

    comment = nil;

    return self;
}

- (void)dealloc;
{
    int index;

    NSLog(@"[%p] -> %@ %s", self, NSStringFromClass([self class]), _cmd);

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
    id tempEntry = nil, tempOnset = nil, tempDuration = nil;
    PrototypeManager *tempProto;
    ParameterList *tempList;
    int i;

    /* Empty out the lists */
    [parameterProfiles removeAllObjects];
    [metaParameterProfiles removeAllObjects];
    [expressionSymbols removeAllObjects];

    if ((numPhones < 2) || (numPhones > 4))
        return;

    tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
    switch (numPhones) {
      case 2:
          tempEntry = [tempProto findTransitionList:@"Defaults" named:@"Diphone"];
          break;
      case 3:
          tempEntry = [tempProto findTransitionList:@"Defaults" named:@"Triphone"];
          break;
      case 4:
          tempEntry = [tempProto findTransitionList:@"Defaults" named:@"Tetraphone"];
          break;
    }

    if (tempEntry == nil) {
        NSLog(@"CANNOT find temp entry");
    }

    tempList = NXGetNamedObject(@"mainParameterList", NSApp);
    for (i = 0; i < [tempList count]; i++) {
        [parameterProfiles addObject:tempEntry];
    }

    /* Alloc lists to point to prototype transition specifiers */
    tempList = NXGetNamedObject(@"mainMetaParameterList", NSApp);
    for (i = 0; i < [tempList count]; i++) {
        [metaParameterProfiles addObject:tempEntry];
    }

    switch (numPhones) {
      case 2:
          tempDuration = [tempProto findEquationList:@"DefaultDurations" named:@"DiphoneDefault"];
          [expressionSymbols addObject:tempDuration];

          tempOnset = [tempProto findEquationList:@"SymbolDefaults" named:@"Beat"];
          [expressionSymbols addObject:tempOnset];

          [expressionSymbols addObject:tempDuration]; /* Make the duration the mark1 value */

          break;
      case 3:
          tempDuration = [tempProto findEquationList:@"DefaultDurations" named:@"TriphoneDefault"];
          [expressionSymbols addObject:tempDuration];

          tempOnset = [tempProto findEquationList:@"SymbolDefaults" named:@"Beat"];
          [expressionSymbols addObject:tempOnset];

          tempEntry = [tempProto findEquationList:@"SymbolDefaults" named:@"Mark1"];
          [expressionSymbols addObject:tempEntry];
          [expressionSymbols addObject:tempDuration];	/* make the duration the mark2 value */

          break;
      case 4:
          tempDuration = [tempProto findEquationList:@"DefaultDurations" named:@"TetraphoneDefault"];
          [expressionSymbols addObject:tempDuration];

          tempOnset = [tempProto findEquationList:@"SymbolDefaults" named:@"Beat"];
          [expressionSymbols addObject:tempOnset];

          tempEntry = [tempProto findEquationList:@"SymbolDefaults" named:@"Mark1"];
          [expressionSymbols addObject:tempEntry];

          tempEntry = [tempProto findEquationList:@"SymbolDefaults" named:@"Mark2"];
          [expressionSymbols addObject:tempEntry];
          [expressionSymbols addObject:tempDuration];	/* make the duration the mark3 value */

          break;
    }
}

- (void)addDefaultParameter;
{
    id tempEntry;
    PrototypeManager *tempProto;

    tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
    switch ([self numberExpressions]) {
      case 2:
          tempEntry = [tempProto findTransitionList:@"Defaults" named:@"Diphone"];
          break;
      case 3:
          tempEntry = [tempProto findTransitionList:@"Defaults" named:@"Triphone"];
          break;
      case 4:
          tempEntry = [tempProto findTransitionList:@"Defaults" named:@"Tetraphone"];
          break;
    }

    [parameterProfiles addObject:tempEntry];
}

- (void)addDefaultMetaParameter;
{
    id tempEntry;
    PrototypeManager *tempProto;

    tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
    switch ([self numberExpressions]) {
      case 2:
          tempEntry = [tempProto findTransitionList:@"Defaults" named:@"Diphone"];
          break;
      case 3:
          tempEntry = [tempProto findTransitionList:@"Defaults" named:@"Triphone"];
          break;
      case 4:
          tempEntry = [tempProto findTransitionList:@"Defaults" named:@"Tetraphone"];
          break;
    }

    [metaParameterProfiles addObject:tempEntry];
}

- (void)removeParameter:(int)index;
{
    NSLog(@"Removing Object atIndex: %d", index);
    [parameterProfiles removeObjectAtIndex:index];
}

- (void)removeMetaParameter:(int)index;
{
    [metaParameterProfiles removeObjectAtIndex:index];
}

- (void)setExpression:(BooleanExpression *)newExpression number:(int)index;
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

- (BooleanExpression *)getExpressionNumber:(int)index;
{
    if ((index > 3) || (index < 0))
        return nil;

    return expressions[index];
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

- (int)matchRule:(MonetList *)categories;
{
    int index;

    for (index = 0; index < [self numberExpressions]; index++) {
        if (![expressions[index] evaluate:[categories objectAtIndex:index]])
            return 0;
    }

    return 1;
}

- getExpressionSymbol:(int)index;
{
    return [expressionSymbols objectAtIndex:index];
}

- (void)evaluateExpressionSymbols:(double *)buffer tempos:(double *)tempos phones:phones withCache:(int)cache;
{
    // TODO (2004-03-02): Is it okay to do these in order?
    buffer[0] = [(ProtoEquation *)[expressionSymbols objectAtIndex:0] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
    buffer[2] = [(ProtoEquation *)[expressionSymbols objectAtIndex:2] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
    buffer[3] = [(ProtoEquation *)[expressionSymbols objectAtIndex:3] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
    buffer[4] = [(ProtoEquation *)[expressionSymbols objectAtIndex:4] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
    buffer[1] = [(ProtoEquation *)[expressionSymbols objectAtIndex:1] evaluate:buffer tempos:tempos phones:phones andCacheWith:cache];
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

- getSpecialProfile:(int)index;
{
    if ((index > 15) || (index < 0))
        return nil;

    return specialProfiles[index];
}

- (void)setSpecialProfile:(int)index to:special;
{
    if ((index > 15) || (index < 0))
        return;

    specialProfiles[index] = special;
}

- (BOOL)isCategoryUsed:aCategory;
{
    int count, index;

    count = [self numberExpressions];
    for (index = 0; index < count; index++) {
        if ([expressions[index] isCategoryUsed:aCategory])
            return YES;
    }

    return NO;
}

- (BOOL)isEquationUsed:anEquation;
{
    if ([expressionSymbols indexOfObject:anEquation] != NSNotFound)
        return YES;

    return NO;
}

- (BOOL)isTransitionUsed:aTransition;
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
    int parms, metaParms, symbols;
    PrototypeManager *tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
    id tempParameter;
    char *c_comment;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    parameterProfiles = [[MonetList alloc] init];
    metaParameterProfiles = [[MonetList alloc] init];
    expressionSymbols = [[MonetList alloc] initWithCapacity:5];

    [aDecoder decodeValuesOfObjCTypes:"i*", &j, &c_comment];
    comment = [[NSString stringWithASCIICString:c_comment] retain];

    [NSException raise:@"fail here" format:@"Forcing it to fail here."];
#ifdef PORTING
    bzero(expressions, sizeof(BooleanExpression *) * 4);
    for (index = 0; index < j; index++) {
        expressions[index] = [[aDecoder decodeObject] retain];
    }

    [expressionSymbols removeAllObjects];
    [parameterProfiles removeAllObjects];
    [metaParameterProfiles removeAllObjects];
    bzero(specialProfiles, sizeof(id) * 16);

    [aDecoder decodeValuesOfObjCTypes:"iii", &symbols, &parms, &metaParms];

    for (index = 0; index < symbols; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        tempParameter = [tempProto findEquation:j andIndex:k];
        [expressionSymbols addObject:tempParameter];
    }

    for (index = 0; index < parms; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        tempParameter = [tempProto findTransition:j andIndex:k];
        [parameterProfiles addObject:tempParameter];
    }

    for (index = 0; index < metaParms; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        [metaParameterProfiles addObject:[tempProto findTransition:j andIndex:k]];
    }

    for (index = 0; index <  16; index++) {
        [aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
        if (index == -1) {
            specialProfiles[index] = nil;
        } else {
            specialProfiles[index] = [tempProto findSpecial:j andIndex:k];
        }
    }
#endif
    NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
#ifdef PORTING
    int index, j, k, dummy;
    int parms, metaParms, symbols;
    PrototypeManager *tempProto = NXGetNamedObject(@"prototypeManager", NSApp);

    j = [self numberExpressions];
    [aCoder encodeValuesOfObjCTypes:"i*", &j, &comment];

    for (index = 0; index < j; index++) {
        [aCoder encodeObject:expressions[index]];
    }

    symbols = [expressionSymbols count];
    parms = [parameterProfiles count];
    metaParms = [metaParameterProfiles count];
    [aCoder encodeValuesOfObjCTypes:"iii", &symbols, &parms, &metaParms];

    for (index = 0; index < symbols; index++) {
        [tempProto findList:&j andIndex:&k ofEquation:[expressionSymbols objectAtIndex:index]];
        [aCoder encodeValuesOfObjCTypes:"ii", &j, &k];
    }

    for (index = 0; index < parms; index++) {
        [tempProto findList:&j andIndex:&k ofTransition:[parameterProfiles objectAtIndex:index]];
        [aCoder encodeValuesOfObjCTypes:"ii", &j, &k];
    }

    for (index = 0; index < metaParms; index++) {
        [tempProto findList:&j andIndex:&k ofTransition:[metaParameterProfiles objectAtIndex:index]];
        [aCoder encodeValuesOfObjCTypes:"ii", &j, &k];
    }

    dummy = -1;

    for (index = 0; index < 16; index++) {
        if (specialProfiles[index] != nil) {
            [tempProto findList:&j andIndex:&k ofSpecial:specialProfiles[index]];
            [aCoder encodeValuesOfObjCTypes:"ii", &j, &k];
        } else {
            [aCoder encodeValuesOfObjCTypes:"ii", &dummy, &dummy];
        }
    }
#endif
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: parameterProfiles: %@, metaParameterProfiles: %@, expressionSymbols: %@, comment: %@",
                     NSStringFromClass([self class]), self, parameterProfiles, metaParameterProfiles, expressionSymbols, comment];
}

@end
