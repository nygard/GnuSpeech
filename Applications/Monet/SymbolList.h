#import "MonetList.h"

@class MMSymbol;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface SymbolList : MonetList
{
}

- (MMSymbol *)findSymbol:(NSString *)searchSymbol;
- (int)findSymbolIndex:(NSString *)searchSymbol;

@end
