
#import "MonetList.h"
#import "CategoryNode.h"
#import <stdio.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/
@interface CategoryList : MonetList
{
}

- findSymbol:(const char *)searchSymbol;
- addCategory:(const char *)newCategory;
- (void)addNativeCategory:(const char *)newCategory;
- (void)freeNativeCategories;
- (void)readDegasFileFormat:(FILE *)fp;
- (void)printDataTo:(FILE *)fp;


/* BrowserManager List delegate Methods */
- (void)addNewValue:(const char *)newValue;
- findByName:(const char *)name;
- (void)changeSymbolOf:temp to:(const char *)name;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
