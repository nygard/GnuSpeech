#import "MonetList.h"

@class MMParameter;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface ParameterList : MonetList
{
}

- (MMParameter *)findParameter:(NSString *)symbol;
- (int)findParameterIndex:(NSString *)symbol;

/* BrowserManager List delegate Methods */
- (id)findByName:(NSString *)name;
- (void)changeSymbolOf:(id)temp to:(NSString *)name;

- (void)printDataTo:(FILE *)fp;

@end
