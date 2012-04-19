//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaNode.h"

@interface MMFormulaExpression : MMFormulaNode
{
    int operation;
    MMFormulaNode *left;
    MMFormulaNode *right;
}

- (id)init;
- (void)dealloc;

- (int)operation;
- (void)setOperation:(int)newOp;

- (id)operandOne;
- (void)setOperandOne:(id)operand;

- (id)operandTwo;
- (void)setOperandTwo:(id)operand;

- (NSString *)opString;

// Methods overridden from MMFormulaNode
- (int)precedence;

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;

- (int)maxPhone;

- (void)expressionString:(NSMutableString *)resultString;

@end
