#import "MonetList.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MMParameter, MMPosture;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: PhoneList
	Purpose: To provide special functionality specific to maintaining
		and accessing a list of phones.

	Import Files:
		"MMPosture.h":  The objects within this list will all be instances
			of the "Phone" class.


*/

@interface PhoneList : MonetList
{
}

- (MMPosture *)findPhone:(NSString *)phone;

@end
