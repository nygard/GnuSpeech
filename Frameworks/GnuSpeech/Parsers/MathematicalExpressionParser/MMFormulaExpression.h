////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MMFormulaExpression.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MMFormulaNode.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

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
