
#import <Foundation/NSObject.h>
#import "CategoryList.h"

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

@interface BooleanTerminal:NSObject
{
	id	category;
	int	matchAll;
}

- init;

/* Access to instance variables */
- (void)setCategory:newCategory;
- category;

- (void)setMatchAll:(int)value;
- (int) matchAll;

/* Evaluate yourself */
- (int) evaluate: (CategoryList *) categories;

/* Optimization methods.  Not yet implemented */
- (void)optimize;
- (void)optimizeSubExpressions;

/* General purpose routines */
- (int) maxExpressionLevels;
- expressionString:(char *)string;

- (BOOL) isCategoryUsed: aCategory;

/* Archiving methods */
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
