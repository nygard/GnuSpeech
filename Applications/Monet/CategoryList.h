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
- (id)findByName:(NSString *)name;
- (void)changeSymbolOf:(id)temp to:(NSString *)name;

- (void)readDegasFileFormat:(FILE *)fp;
- (void)printDataTo:(FILE *)fp;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

@end
