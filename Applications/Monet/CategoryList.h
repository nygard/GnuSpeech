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

@end
