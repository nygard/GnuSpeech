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

@end
