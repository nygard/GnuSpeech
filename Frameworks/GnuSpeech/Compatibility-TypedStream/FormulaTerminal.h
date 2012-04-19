//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMOldFormulaNode.h"

@class MMSymbol;

#define RULEDURATION    (-2)
#define BEAT		(-3)
#define MARK1		(-4)
#define MARK2		(-5)
#define MARK3		(-6)
#define TEMPO0		(-7)
#define TEMPO1		(-8)
#define TEMPO2		(-9)
#define TEMPO3		(-10)


@interface FormulaTerminal : MMOldFormulaNode
{
    MMSymbol *symbol;
    double value;
    int whichPhone; // TODO (2004-03-10): Rename this
}

- (id)init;
- (void)dealloc;

- (MMSymbol *)symbol;
- (void)setSymbol:(MMSymbol *)newSymbol;

- (double)value;
- (void)setValue:(double)newValue;

- (int)whichPhone;
- (void)setWhichPhone:(int)newValue;

// Methods common to "FormulaNode" -- for both FormulaExpression, FormulaTerminal
- (void)expressionString:(NSMutableString *)resultString;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
