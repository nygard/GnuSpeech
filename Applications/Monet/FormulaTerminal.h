#import <Foundation/NSObject.h>

@class PhoneList, MMSymbol;

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
    MMSymbol *symbol;
    double value;
    int whichPhone; // TODO (2004-03-10): Rename this
    int precedence;

    int cacheTag;
    double cacheValue;
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
- (int)precedence;
- (void)setPrecedence:(int)newPrec;

- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones;
- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones tempos:(double *)tempos;

- (void)optimize;
- (void)optimizeSubExpressions;

- (int)maxExpressionLevels;
- (int)maxPhone;

- (NSString *)expressionString;
- (void)expressionString:(NSMutableString *)resultString;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

@end
