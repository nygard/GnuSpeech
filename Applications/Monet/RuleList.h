#import "MonetList.h"

@class MMRule;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface RuleList : MonetList
{
}

- (MMRule *)findRule:(MonetList *)categories index:(int *)indexPtr;

@end
