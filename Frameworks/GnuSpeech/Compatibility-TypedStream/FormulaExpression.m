//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "FormulaExpression.h"

#import "NSObject-Extensions.h"

#import "MMFormulaSymbols.h"

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

- (NSUInteger)operation;
{
    return operation;
}

- (void)setOperation:(NSUInteger)newOp;
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
    if (operand == nil)
        return;

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
          NSLog(@"Drat, there should be an operandOne in %s", __PRETTY_FUNCTION__);
          break;
      case 1:
          if (operand != nil)
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

- (void)expressionString:(NSMutableString *)resultString;
{
    NSUInteger count, index;
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
    NSUInteger index;
    NSUInteger numExpressions, maxExpressions;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    /*NSInteger archivedVersion =*/ [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"iiii", &operation, &numExpressions, &maxExpressions, &precedence];
    if (numExpressions != 2)
        NSLog(@"operation: %lu, numExpressions: %lu, maxExpressions: %lu, precedence: %lu", operation, numExpressions, maxExpressions, precedence);
    expressions = [[NSMutableArray alloc] init];
    for (index = 0; index < numExpressions; index++)
        [self addSubExpression:[aDecoder decodeObject]];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);

    return self;
}

@end
