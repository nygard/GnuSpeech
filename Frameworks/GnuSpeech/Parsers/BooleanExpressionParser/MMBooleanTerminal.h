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
//  MMBooleanTerminal.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import "MMBooleanNode.h"

@class CategoryList, MMCategory;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: BooleanTerminal
	Purpose: Leaf nodes in a boolean expression tree.

	Instance Variables:
		category:  A pointer to a category object which is Terminal
			represents.  NOTE: this object is acctually part of
			the mainCategoryList.  DO NOT FREE this object.  It
			is the responsibility of the main category List.

		matchAll: (int) True if this category matches all categories
			of this type.  That is, categories "uh" and "uh'" are
			of the same class, but are different.  "uh*" will match
			both.  The "*" indicates that this flag is true.

	Import Files

	"CategoryList.h": for object definitions.

	NOTES:

	Optimization is planned, but not yet implemented.

*/

@interface MMBooleanTerminal : MMBooleanNode
{
    MMCategory *category;
    BOOL shouldMatchAll;
}

- (id)init;
- (void)dealloc;

/* Access to instance variables */
- (MMCategory *)category;
- (void)setCategory:(MMCategory *)newCategory;

- (BOOL)shouldMatchAll;
- (void)setShouldMatchAll:(BOOL)newFlag;

/* Evaluate yourself */
- (BOOL)evaluateWithCategories:(CategoryList *)categories;

/* General purpose routines */
- (void)expressionString:(NSMutableString *)resultString;

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

@end
