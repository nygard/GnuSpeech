#import <Foundation/NSObject.h>

@class Symbol;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

#define RULEDURATION    (-2)
#define BEAT		(-3)
#define MARK1		(-4)
#define MARK2		(-5)
#define MARK3		(-6)
#define TEMPO0		(-7)
#define TEMPO1		(-8)
#define TEMPO2		(-9)
#define TEMPO3		(-10)


@interface FormulaTerminal : NSObject
{
    Symbol *symbol;
    double value;
    int whichPhone;
    int precedence;

    int cacheTag;
    double cacheValue;
}

- (id)init;
- (void)dealloc;

- (Symbol *)symbol;
- (void)setSymbol:(Symbol *)newSymbol;

- (double)value;
- (void)setValue:(double)newValue;

- (int)whichPhone;
- (void)setWhichPhone:(int)newValue;

// Methods common to "FormulaNode" -- for both FormulaExpression, FormulaTerminal
- (int)precedence;
- (void)setPrecedence:(int)newPrec;

- (double)evaluate:(double *)ruleSymbols phones:phones;
- (double)evaluate:(double *)ruleSymbols tempos:(double *)tempos phones:phones;

- (void)optimize;
- (void)optimizeSubExpressions;

- (int)maxExpressionLevels;
- (int)maxPhone;

- (NSString *)expressionString;
- (void)expressionString:(NSMutableString *)resultString;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)description;

@end
