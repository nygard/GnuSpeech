
#import "MonetList.h"
#import "Symbol.h"
#import <stdio.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface SymbolList:MonetList
{
}

- findSymbol:(const char *)searchSymbol;
- (int) findSymbolIndex:(const char *) searchSymbol;
- addSymbol:(const char *) symbol withValue:(double) newValue;
- (void)printDataTo:(FILE *)fp;

/* BrowserManager List delegate Methods */
- (void)addNewValue:(const char *)newValue;
- findByName:(const char *)name;
- (void)changeSymbolOf:temp to:(const char *)name;

@end
