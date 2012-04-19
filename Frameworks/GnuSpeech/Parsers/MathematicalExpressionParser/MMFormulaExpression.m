//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaExpression.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"

#import "MMFormulaSymbols.h"

@implementation MMFormulaExpression

- (id)init;
{
    if ([super init] == nil)
        return nil;

    operation = TK_F_END;
    left = nil;
    right = nil;

    return self;
}

- (void)dealloc;
{
    [left release];
    [right release];

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

- (id)operandOne;
{
    return left;
}

- (void)setOperandOne:(id)operand;
{
    if (operand == left)
        return;

    [left release];
    left = [operand retain];
}

- (id)operandTwo;
{
    return right;
}

- (void)setOperandTwo:(id)operand;
{
    if (operand == right)
        return;

    [right release];right = [operand retain];
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
// Methods overridden from MMFormulaNode
//

- (int)precedence;
{
    switch (operation) {
      case TK_F_ADD:
      case TK_F_SUB:
          return 1;

      case TK_F_MULT:
      case TK_F_DIV:
          return 2;
    }

    return 0;
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;
{
    switch (operation) {
      case TK_F_ADD:
          return [left evaluate:ruleSymbols postures:postures tempos:tempos] + [right evaluate:ruleSymbols postures:postures tempos:tempos];
          break;

      case TK_F_SUB:
          return [left evaluate:ruleSymbols postures:postures tempos:tempos] - [right evaluate:ruleSymbols postures:postures tempos:tempos];
          break;

      case TK_F_MULT:
          return [left evaluate:ruleSymbols postures:postures tempos:tempos] * [right evaluate:ruleSymbols postures:postures tempos:tempos];
          break;

      case TK_F_DIV:
          return [left evaluate:ruleSymbols postures:postures tempos:tempos] / [right evaluate:ruleSymbols postures:postures tempos:tempos];
          break;

      default:
          return 1.0;
    }

    return 0.0;
}

- (int)maxPhone;
{
    int max = 0;
    int temp;

    temp = [left maxPhone];
    if (temp > max)
        max = temp;

    temp = [right maxPhone];
    if (temp > max)
        max = temp;

    return max + 1;
}

- (void)expressionString:(NSMutableString *)resultString;
{
    NSString *opString;
    BOOL shouldParenthesize;

    opString = [self opString];

    shouldParenthesize = [left precedence] < [self precedence];

    if (shouldParenthesize)
        [resultString appendString:@"("];
    [left expressionString:resultString];
    if (shouldParenthesize)
        [resultString appendString:@")"];

    [resultString appendString:opString];

    shouldParenthesize = [right precedence] < [self precedence];

    if (shouldParenthesize)
        [resultString appendString:@"("];
    [right expressionString:resultString];
    if (shouldParenthesize)
        [resultString appendString:@")"];
}

@end
