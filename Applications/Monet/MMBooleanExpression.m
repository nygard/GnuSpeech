#import "MMBooleanExpression.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"

@implementation MMBooleanExpression

- (id)init;
{
    if ([super init] == nil)
        return nil;

    operation = NO_OP;
    expressions = [[NSMutableArray alloc] initWithCapacity:4];

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

- (void)setOperation:(int)newOperation;
{
    operation = newOperation;
}

- (void)addSubExpression:(MMBooleanNode *)newExpression;
{
    if (newExpression != nil)
        [expressions addObject:newExpression];
}

- (MMBooleanNode *)operandOne;
{
    if  ([expressions count] > 0)
        return [expressions objectAtIndex:0];

    return nil;
}

- (MMBooleanNode *)operandTwo;
{
    if  ([expressions count] > 1)
        return [expressions objectAtIndex:1];

    return nil;
}

- (NSString *)opString;
{
    switch (operation) {
      default:
      case NO_OP: return @"";
      case NOT_OP: return @" not ";
      case OR_OP: return @" or ";
      case AND_OP: return @" and ";
      case XOR_OP: return @" xor ";
    }

    return @"";
}

//
// Methods common to "BooleanNode" -- for both BooleanExpress, BooleanTerminal
//

- (BOOL)evaluateWithCategories:(CategoryList *)categories;
{
    switch (operation) {
      case NOT_OP:
          return ![[self operandOne] evaluateWithCategories:categories];
          break;

      case AND_OP:
          if (![[self operandOne] evaluateWithCategories:categories])
              return NO;
          return [[self operandTwo] evaluateWithCategories:categories];
          break;

      case OR_OP:
          if ([[self operandOne] evaluateWithCategories:categories])
              return YES;
          return [[self operandTwo] evaluateWithCategories:categories];
          break;

      case XOR_OP:
          return ([[self operandOne] evaluateWithCategories:categories] ^ [[self operandTwo] evaluateWithCategories:categories]);
          break;

      default:
          return YES;
    }

    return NO;
}

- (void)expressionString:(NSMutableString *)resultString;
{
    NSString *opString;

    opString = [self opString];

    [resultString appendString:@"("];

    if (operation == NOT_OP) {
        [resultString appendString:@"not "];
        if ([expressions count] > 0)
            [[expressions objectAtIndex:0] expressionString:resultString];
    } else {
        int count, index;

        count = [expressions count];
        for (index = 0; index < count; index++) {
            if (index != 0)
                [resultString appendString:opString];
            [[expressions objectAtIndex:index] expressionString:resultString];
	}
    }

    [resultString appendString:@")"];
}

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    int count, index;

    count = [expressions count];
    for (index = 0; index < count; index++) {
        if ([[expressions objectAtIndex:index] isCategoryUsed:aCategory])
            return YES;
    }

    return NO;
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int numExpressions, maxExpressions;
    int i;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"iii", &operation, &numExpressions, &maxExpressions];
    //NSLog(@"operation: %d, numExpressions: %d, maxExpressions: %d", operation, numExpressions, maxExpressions);
    expressions = [[NSMutableArray alloc] init];

    for (i = 0; i < numExpressions; i++) {
        MMBooleanNode *anExpression;

        anExpression = [aDecoder decodeObject];
        if (anExpression != nil)
            [self addSubExpression:anExpression];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: operation: %d, expressions: %@, expressionString: %@",
                     NSStringFromClass([self class]), self, operation, expressions, [self expressionString]];
}

@end
