#import "MonetList.h"

@class CategoryNode;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface CategoryList : MonetList
{
}

- (CategoryNode *)findSymbol:(NSString *)searchSymbol;
- (CategoryNode *)addCategory:(NSString *)newCategoryName; // TODO (2004-03-01): Make this return void
- (void)addNativeCategory:(NSString *)newCategoryName;
//- (void)freeNativeCategories;


// BrowserManager List delegate Methods
- (void)addNewValue:(NSString *)newValue;
- (CategoryNode *)findByName:(NSString *)name;
- (void)changeSymbolOf:(CategoryNode *)temp to:(NSString *)name;

//- (void)readDegasFileFormat:(FILE *)fp;
//- (void)printDataTo:(FILE *)fp;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
