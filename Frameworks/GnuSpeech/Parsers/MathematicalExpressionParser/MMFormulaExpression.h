//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaNode.h"

@interface MMFormulaExpression : MMFormulaNode
{
    NSUInteger operation;
    MMFormulaNode *left;
    MMFormulaNode *right;
}

- (id)init;
- (void)dealloc;

- (NSUInteger)operation;
- (void)setOperation:(NSUInteger)newOp;

- (id)operandOne;
- (void)setOperandOne:(id)operand;

- (id)operandTwo;
- (void)setOperandTwo:(id)operand;

- (NSString *)opString;

// Methods overridden from MMFormulaNode
- (NSUInteger)precedence;

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;

- (NSUInteger)maxPhone;

- (void)expressionString:(NSMutableString *)resultString;

@end
