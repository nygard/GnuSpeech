#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class Phone;
@class Inspector;

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
    IBOutlet Inspector *mainInspector;
    IBOutlet NSBox *phonePopUpListView;
    IBOutlet NSPopUpButton *phonePopUpList;

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
- (void)dealloc;

- (void)setCurrentPhone:(Phone *)aPhone;
- (void)inspectPhone:(Phone *)aPhone;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)browserHit:(id)sender;
- (IBAction)browserDoubleHit:(id)sender;
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (IBAction)itemsChanged:(id)sender;

- (IBAction)setComment:(id)sender;
- (IBAction)revertComment:(id)sender;

- (IBAction)setValueNextText:(id)sender;

@end
