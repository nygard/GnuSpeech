
#import <AppKit/AppKit.h>
#import "CategoryList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: CategoryInspector
	Purpose: Oversees the functioning of the PhoneInspector Panel

	Date: March 24, 1994

History:
	March 24, 1994
		Integrated into MONET.

===========================================================================*/


@interface CategoryInspector:NSObject
{
	id	mainInspector;
	id	categoryPopUpListView;
	id	categoryPopUpList;
	id	commentView;
	id	commentText;

	id	setButton;
	id	revertButton;


	CategoryNode	*currentCategory;

}

- init;
- (void)inspectCategory:phone;
- (void)setUpWindow:sender;
- (void)beginEditting;

- (void)setComment:sender;
- (void)revertComment:sender;

@end
