#import "MonetList.h"

@class Symbol;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface SymbolList : MonetList
{
}

- (Symbol *)findSymbol:(NSString *)searchSymbol;
- (int)findSymbolIndex:(NSString *)searchSymbol;
- (void)addSymbol:(NSString *)symbol withValue:(double)newValue;

/* BrowserManager List delegate Methods */
- (void)addNewValue:(NSString *)newValue;
- (id)findByName:(NSString *)name;
- (void)changeSymbolOf:(id)aSymbol to:(NSString *)name;

- (void)printDataTo:(FILE *)fp;

@end
