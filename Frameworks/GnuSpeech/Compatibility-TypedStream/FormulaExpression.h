//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>
#import "MMOldFormulaNode.h"

@interface FormulaExpression : MMOldFormulaNode

- (id)init;
- (void)dealloc;

- (NSUInteger)operation;
- (void)setOperation:(NSUInteger)newOp;

- (void)addSubExpression:newExpression;

- (id)operandOne;
- (void)setOperandOne:(id)operand;

- (id)operandTwo;
- (void)setOperandTwo:(id)operand;

- (NSString *)opString;

// Methods common to "MMFormulaNode" -- for both FormulaExpression, FormulaTerminal
- (void)expressionString:(NSMutableString *)resultString;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
