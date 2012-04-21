//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaExpression.h"

#import "NSObject-Extensions.h"

@interface MMFormulaExpression ()
@property (retain) MMFormulaNode *left;
@property (retain) MMFormulaNode *right;
@end

#pragma mark -

@implementation MMFormulaExpression
{
    MMFormulaOperation m_operation;
    MMFormulaNode *m_left;
    MMFormulaNode *m_right;
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    m_operation = MMFormulaOperation_None;
    m_left = nil;
    m_right = nil;

    return self;
}

- (void)dealloc;
{
    [m_left release];
    [m_right release];

    [super dealloc];
}

#pragma mark -

@synthesize operation = m_operation;
@synthesize left = m_left;
@synthesize right = m_right;

- (id)operandOne;
{
    return self.left;
}

- (void)setOperandOne:(id)operand;
{
    self.left = operand;
}

- (id)operandTwo;
{
    return self.right;
}

- (void)setOperandTwo:(id)operand;
{
    self.right = operand;
}

- (NSString *)operationString;
{
    switch (self.operation) {
        default:
        case MMFormulaOperation_None:     return @"";
        case MMFormulaOperation_Add:      return @" + ";
        case MMFormulaOperation_Subtract: return @" - ";
        case MMFormulaOperation_Multiply: return @" * ";
        case MMFormulaOperation_Divide:   return @" / ";
    }

    return @"";
}

//
// Methods overridden from MMFormulaNode
//

- (NSUInteger)precedence;
{
    switch (self.operation) {
      case MMFormulaOperation_Add:
      case MMFormulaOperation_Subtract:
          return 1;

      case MMFormulaOperation_Multiply:
      case MMFormulaOperation_Divide:
          return 2;
    }

    return 0;
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;
{
    switch (self.operation) {
      case MMFormulaOperation_Add:
          return [self.left evaluate:ruleSymbols postures:postures tempos:tempos] + [self.right evaluate:ruleSymbols postures:postures tempos:tempos];
          break;

      case MMFormulaOperation_Subtract:
          return [self.left evaluate:ruleSymbols postures:postures tempos:tempos] - [self.right evaluate:ruleSymbols postures:postures tempos:tempos];
          break;

      case MMFormulaOperation_Multiply:
          return [self.left evaluate:ruleSymbols postures:postures tempos:tempos] * [self.right evaluate:ruleSymbols postures:postures tempos:tempos];
          break;

      case MMFormulaOperation_Divide:
          return [self.left evaluate:ruleSymbols postures:postures tempos:tempos] / [self.right evaluate:ruleSymbols postures:postures tempos:tempos];
          break;

      default:
          return 1.0;
    }

    return 0.0;
}

- (NSUInteger)maxPhone;
{
    NSUInteger max = 0;
    NSUInteger temp;

    temp = self.left.maxPhone;
    if (temp > max)
        max = temp;

    temp = self.right.maxPhone;
    if (temp > max)
        max = temp;

    return max + 1;
}

- (void)appendExpressionToString:(NSMutableString *)resultString;
{
    BOOL shouldParenthesize = self.left.precedence < self.precedence;

    if (shouldParenthesize) {
        [resultString appendString:@"("];
        [self.left appendExpressionToString:resultString];
        [resultString appendString:@")"];
    } else {
        [self.left appendExpressionToString:resultString];
    }

    [resultString appendString:self.operationString];

    shouldParenthesize = self.right.precedence < self.precedence;

    if (shouldParenthesize) {
        [resultString appendString:@"("];
        [self.right appendExpressionToString:resultString];
        [resultString appendString:@")"];
    } else {
        [self.right appendExpressionToString:resultString];
    }
}

@end
