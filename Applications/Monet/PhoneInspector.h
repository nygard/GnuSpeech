#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class Phone;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: PhoneInspector
	Purpose: Oversees the functioning of the PhoneInspector Panel

	Date: March 23, 1994

History:
	March 23, 1994
		Integrated into MONET.

===========================================================================*/


@interface PhoneInspector:NSObject
{
    id mainInspector;
    id phonePopUpListView;
    id phonePopUpList;

    id niftyMatrixScrollView;
    id niftyMatrix;
    id niftyMatrixBox;

    id browserBox;
    id browser;
    id minText;
    id maxText;
    id defText;
    id valueField;
    id setBrowserButton;
    id defBrowserButton;
    id revertBrowserButton;

    id commentView;
    id commentText;
    id setCommentButton;
    id revertCommentButton;

    Phone *currentPhone;
    NSFont *courier;
    NSFont *courierBold;

    int currentBrowser;
    id currentMainList;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (id)init;
- (void)itemsChanged:(id)sender;
- (void)inspectPhone:phone;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (void)browserHit:(id)sender;
- (void)browserDoubleHit:(id)sender;
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)setComment:(id)sender;
- (void)revertComment:(id)sender;

- (void)setValueNextText:(id)sender;

@end
