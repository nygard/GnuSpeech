
#import <Foundation/NSObject.h>
#import "Symbol.h"

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


@interface FormulaTerminal:NSObject
{
	Symbol	*symbol;
	double	value;
	int	whichPhone;
	int	precedence;

	int     cacheTag;
	double  cacheValue;

}

- init;

- (void)setSymbol:newSymbol;
- symbol;

- (void)setValue:(double)newValue;
- (double) value;

- (void)setWhichPhone:(int)newValue;
- (int) whichPhone;

- (void)setPrecedence:(int)newPrec;
- (int) precedence;

- (double) evaluate:(double *) ruleSymbols phones: phones;
- (double) evaluate:(double *) ruleSymbols tempos: (double *) tempos  phones: phones;

- (void)optimize;
- (void)optimizeSubExpressions;

- (int) maxExpressionLevels;
- (int) maxPhone;
- expressionString:(char *)string;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;


@end
