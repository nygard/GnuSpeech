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
//  MMBooleanExpression.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MMBooleanNode.h"
#import <Foundation/NSArray.h>

@class CategoryList, MMCategory;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: BooleanExpression
	Purpose:  Non-leaf node in a boolean expression tree.

	Instance Variables:
		operation: (int) Defines the operation to be performed on the
			return values from the subexpression(s).  One of
			NO_OP, NOT_OP, OR_OP, AND_OP, or XOR_OP.

		numExpressions: (int) The number of sub-expressions.  NOT_OP
			requires only one sub-expression.

		maxExpressions: (int) Future enhancements will offer more than
			two sub-expressions.  This variable keeps track of
			how much space has been allocated for storing
			sub-expression id's.  If a sub-expression is added
			and there is no more room, this object will have
			to realloc and set a new value for maxExpressions.

		expressions: (id*) pointer to an array of sub-expressions.
			The length of this array is defined by the instance
			variable "maxExpressions".

	Import Files:

	"CategoryList.h":  In MONET, terminals are of the "MMCategory"
		class.  The named object "mainCategoryList" is checked to
		ensure the existence of a selected category.

	NOTES:

	Optimizations are planned, but not yet implemented.

=============================================================================
*/

#define NO_OP	0
#define NOT_OP	1
#define OR_OP	2
#define AND_OP	3
#define XOR_OP	4

@interface MMBooleanExpression : MMBooleanNode
{
    int operation;

    NSMutableArray *expressions;
}

/* Init and free */
- (id)init;
- (void)dealloc;

/* Access to instance variables */
- (int)operation;
- (void)setOperation:(int)newOperation;

- (void)addSubExpression:(MMBooleanNode *)newExpression;
- (MMBooleanNode *)operandOne;
- (MMBooleanNode *)operandTwo;

- (NSString *)opString;

/* Evaluate yourself.*/
- (BOOL)evaluateWithCategories:(CategoryList *)categories;

/* General purpose methods */
- (void)expressionString:(NSMutableString *)resultString;

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

@end
