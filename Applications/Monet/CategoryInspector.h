#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSButton;
@class CategoryNode;

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

@interface CategoryInspector : NSObject
{
    id mainInspector;
    id categoryPopUpListView;
    id categoryPopUpList;
    id commentView;
    id commentText;

    IBOutlet NSButton *setButton;
    IBOutlet NSButton *revertButton;

    CategoryNode *currentCategory;
}

- (id)init;
- (void)inspectCategory:category;
- (void)setUpWindow:(id)sender;
- (void)beginEditting;

- (void)setComment:(id)sender;
- (void)revertComment:(id)sender;

@end
