#import "MonetList.h"

@class MMCategory;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface CategoryList : MonetList
{
}

- (MMCategory *)findSymbol:(NSString *)searchSymbol;
- (MMCategory *)addCategory:(NSString *)newCategoryName; // TODO (2004-03-01): Make this return void
- (void)addNativeCategory:(NSString *)newCategoryName;
//- (void)freeNativeCategories;

- (NSString *)description;

@end
