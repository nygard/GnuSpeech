#import "FormulaExpression.h"

#import <Foundation/Foundation.h>
#import "FormulaSymbols.h"

@implementation FormulaExpression

- (id)init;
{
    if ([super init] == nil)
        return nil;

    operation = TK_F_END;
    expressions = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc;
{
    [expressions release];

    [super dealloc];
}

- (int)operation;
{
    return operation;
}

- (void)setOperation:(int)newOp;
{
    operation = newOp;
}

- (void)addSubExpression:newExpression;
{
    [expressions addObject:newExpression];
}

- (id)operandOne;
{
    if ([expressions count] > 0)
        return [expressions objectAtIndex:0];

    return nil;
}

- (void)setOperandOne:(id)operand;
{
    if ([expressions count] == 0)
        [expressions addObject:operand];
    else
        [expressions replaceObjectAtIndex:0 withObject:operand];
}

- (id)operandTwo;
{
    if ([expressions count] > 1)
        return [expressions objectAtIndex:1];

    return nil;
}

- (void)setOperandTwo:(id)operand;
{
    switch ([expressions count]) {
      case 0:
          NSLog(@"Drat, there should be an operandOne in %s", _cmd);
          break;
      case 1:
          [expressions addObject:operand];
          break;
      default:
          [expressions replaceObjectAtIndex:1 withObject:operand];
          break;
    }
}

- (NSString *)opString;
{
    switch (operation) {
      default:
      case TK_F_END: return @"";
      case TK_F_ADD: return @" + ";
      case TK_F_SUB: return @" - ";
      case TK_F_MULT: return @" * ";
      case TK_F_DIV: return @" / ";
    }

    return @"";
}

//
// Methods common to "FormulaNode" -- for both FormulaExpression, FormulaTerminal
//

- (int)precedence;
{
    return precedence;
}

- (void)setPrecedence:(int)newPrec;
{
    precedence = newPrec;
}

- (double)evaluate:(double *)ruleSymbols phones:phones;
{
    double tempos[4] = {1.0, 1.0, 1.0, 1.0};

    return [self evaluate:ruleSymbols tempos:tempos phones:phones];
}

- (double)evaluate:(double *)ruleSymbols tempos:(double *)tempos phones:phones;
{
    switch (operation) {
      case TK_F_ADD:
          return ([[self operandOne] evaluate:ruleSymbols tempos:tempos phones:phones] +
                  [[self operandTwo] evaluate:ruleSymbols tempos:tempos phones:phones]);
          break;

      case TK_F_SUB:
          return ([[self operandOne] evaluate:ruleSymbols tempos:tempos phones:phones] -
                  [[self operandTwo] evaluate:ruleSymbols tempos:tempos phones:phones]);
          break;

      case TK_F_MULT:
          return ([[self operandOne] evaluate:ruleSymbols tempos:tempos phones:phones] *
                  [[self operandTwo] evaluate:ruleSymbols tempos:tempos phones:phones]);
          break;

      case TK_F_DIV:
          return ([[self operandOne] evaluate:ruleSymbols tempos:tempos phones:phones] /
                  [[self operandTwo] evaluate:ruleSymbols tempos:tempos phones:phones]);
          break;

      default:
          return 1.0;
    }

    return 0.0;
}

- (void)optimize;
{
}


- (void)optimizeSubExpressions;
{
    int count, index;

    count = [expressions count];
    for (index = 0; index < count; index++)
        [[expressions objectAtIndex:index] optimizeSubExpressions];

    [self optimize];
}


- (int)maxExpressionLevels;
{
    int count, index;
    int max = 0;
    int temp;

    count = [expressions count];
    for (index = 0; index < count; index++) {
        temp = [[expressions objectAtIndex:index] maxExpressionLevels];
        if (temp > max)
            max = temp;
    }

    return max + 1;
}

- (int)maxPhone;
{
    int count, index;
    int max = 0;
    int temp;

    count = [expressions count];
    for (index = 0; index < count; index++) {
        temp = [[expressions objectAtIndex:index] maxPhone];
        if (temp > max)
            max = temp;
    }

    return max + 1;
}

- (NSString *)expressionString;
{
    NSMutableString *resultString;

    resultString = [NSMutableString string];
    [self expressionString:resultString];

    return resultString;
}

- (void)expressionString:(NSMutableString *)resultString;
{
    int count, index;
    NSString *opString;

    opString = [self opString];

    if (precedence == 3)
        [resultString appendString:@"("];

    count = [expressions count];
    for (index = 0; index < count; index++) {
        if (index != 0)
            [resultString appendString:opString];

        [[expressions objectAtIndex:index] expressionString:resultString];

    }

    if (precedence == 3)
        [resultString appendString:@")"];
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int index;
    int numExpressions, maxExpressions;

    if ([self init] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"iiii", &operation, &numExpressions, &maxExpressions, &precedence];
    //NSLog(@"operation: %d, numExpressions: %d, maxExpressions: %d, precedence: %d", operation, numExpressions, maxExpressions, precedence);
    for (index = 0; index < numExpressions; index++)
        [self addSubExpression:[aDecoder decodeObject]];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);

    return self;
}

#ifdef PORTING
- (void)encodeWithCoder:(NSCoder *)aCoder;
{
int i;

	[aCoder encodeValuesOfObjCTypes:"iiii", &operation, &numExpressions, &maxExpressions, &precedence];
	for (i = 0; i<numExpressions; i++)
		[aCoder encodeObject:expressions[i]];
}
#endif

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: operation: %d, precedence: %d, expressions: %@, cacheTag: %d, cacheValue: %g",
                     NSStringFromClass([self class]), self, operation, precedence, expressions, cacheTag, cacheValue];
}

@end
