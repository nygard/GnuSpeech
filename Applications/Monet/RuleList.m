#import "RuleList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "AppController.h"
#import "BooleanParser.h"
#import "Rule.h"

/*===========================================================================

===========================================================================*/


@implementation RuleList

- (void)seedListWith:(BooleanExpression *)expression1:(BooleanExpression *)expression2;
{
    Rule *aRule;

    aRule = [[Rule alloc] init];
    [aRule setExpression:expression1 number:0];
    [aRule setExpression:expression2 number:1];
    [aRule setDefaultsTo:[aRule numberExpressions]];
    [self addObject:aRule];
    [aRule release];
}

- (void)addRuleExp1:(BooleanExpression *)exp1 exp2:(BooleanExpression *)exp2 exp3:(BooleanExpression *)exp3 exp4:(BooleanExpression *)exp4;
{
    Rule *aRule;

    aRule = [[Rule alloc] init];
    [aRule setExpression:exp1 number:0];
    [aRule setExpression:exp2 number:1];
    [aRule setExpression:exp3 number:2];
    [aRule setExpression:exp4 number:3];
    [aRule setDefaultsTo:[aRule numberExpressions]];
    [self insertObject:aRule atIndex:[self count] - 1];
    [aRule release];
}

- (void)changeRuleAt:(int)index exp1:(BooleanExpression *)exp1 exp2:(BooleanExpression *)exp2 exp3:(BooleanExpression *)exp3 exp4:(BooleanExpression *)exp4;
{
    Rule *aRule;
    int i;

    aRule = [self objectAtIndex:index];
    i = [aRule numberExpressions];

    [aRule setExpression:exp1 number:0];
    [aRule setExpression:exp2 number:1];
    [aRule setExpression:exp3 number:2];
    [aRule setExpression:exp4 number:3];

    if (i != [aRule numberExpressions])
        [aRule setDefaultsTo:[aRule numberExpressions]];
}

- (Rule *)findRule:(MonetList *)categories index:(int *)index;
{
    int i;

    for (i = 0; i < [self count]; i++) {
        if ([(Rule *)[self objectAtIndex:i] numberExpressions] <= [categories count])
            if ([(Rule *)[self objectAtIndex:i] matchRule:categories]) {
                *index = i;
                return [self objectAtIndex:i];
            }
    }

    return [self lastObject];
}



#define SYMBOL_LENGTH_MAX 12
- (void)readDegasFileFormat:(FILE *)fp;
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
    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:NXGetNamedObject(@"mainPhoneList", NSApp)];

    /* READ FROM FILE  */
    NXRead(fp, &numRules, sizeof(int));
    for (i = 0; i < numRules; i++) {
        /* READ SPECIFIER CATEGORY #1 FROM FILE  */
        NXRead(fp, &tempLength, sizeof(int));
        bzero(buffer, 1024);
        NXRead(fp, buffer, tempLength+1);
        bufferStr = [NSString stringWithASCIICString:buffer];
        temp = [boolParser parseString:bufferStr];

        /* READ SPECIFIER CATEGORY #2 FROM FILE  */
        NXRead(fp, &tempLength, sizeof(int));
        bzero(buffer1, 1024);
        NXRead(fp, buffer1, tempLength+1);
        buffer1Str = [NSString stringWithASCIICString:buffer1];
        temp1 = [boolParser parseString:buffer1Str];
        //printf("%s >> %s\n", buffer, buffer1);

        [self addRuleExp1:temp exp2:temp1 exp3:nil exp4:nil];

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

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    int count, index;

    count = [self count];
    for (index = 0; index < count; index++) {
        if ([[self objectAtIndex:index] isCategoryUsed:aCategory])
            return YES;
    }

    return NO;
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    int count, index;

    count = [self count];
    for (index = 0; index < count; index++) {
        if ([[self objectAtIndex:index] isEquationUsed:anEquation])
            return YES;
    }

    return NO;
}

- (BOOL)isTransitionUsed:(MMTransition *)aTransition;
{
    int count, index;

    count = [self count];
    for (index = 0; index < count; index++) {
        if ([[self objectAtIndex:index] isTransitionUsed:aTransition])
            return YES;
    }

    return NO;
}

- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;
{
    int count, index;
    Rule *aRule;

    count = [self count];
    for (index = 0; index < count; index++) {
        aRule = [self objectAtIndex:index];
        if ([aRule isEquationUsed:anEquation]) {
            [aList addObject:aRule];
            break;
        }
    }
}

- (void)findTemplate:(MMTransition *)aTemplate andPutIn:(MonetList *)aList;
{
    int count, index;
    Rule *aRule;

    count = [self count];
    for (index = 0; index < count; index++) {
        aRule = [self objectAtIndex:index];
        if ([aRule isTransitionUsed:aTemplate])
            [aList addObject:aRule];
    }
}

@end
