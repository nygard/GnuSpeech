#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSButton;
@class CategoryNode;
@class Inspector;

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
    IBOutlet Inspector *mainInspector;
    IBOutlet NSBox *categoryPopUpListView;
    IBOutlet NSPopUpButton *categoryPopUpList;
    IBOutlet NSBox *commentView;
    IBOutlet NSTextView *commentText;

    IBOutlet NSButtonCell *setButton;
    IBOutlet NSButtonCell *revertButton;

    CategoryNode *currentCategory; // nonretained
}

- (id)init;
- (void)inspectCategory:(CategoryNode *)aCategory;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)setComment:(id)sender;
- (IBAction)revertComment:(id)sender;

@end
