#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MonetList, Phone;
@class Inspector, NiftyMatrix;

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

    IBOutlet NSScrollView *niftyMatrixScrollView;
    IBOutlet NiftyMatrix *niftyMatrix;
    IBOutlet NSBox *niftyMatrixBox;

    IBOutlet NSBox *browserBox;
    IBOutlet NSBrowser *browser;
    IBOutlet NSTextField *minText;
    IBOutlet NSTextField *maxText;
    IBOutlet NSTextField *defText;
    IBOutlet NSForm *valueField;
    IBOutlet NSButtonCell *setBrowserButton;
    IBOutlet NSButtonCell *defBrowserButton;
    IBOutlet NSButtonCell *revertBrowserButton;

    IBOutlet NSBox *commentView;
    IBOutlet NSTextView *commentText;
    IBOutlet NSButtonCell *setCommentButton;
    IBOutlet NSButtonCell *revertCommentButton;

    Phone *currentPhone;
    NSFont *courierFont;
    NSFont *courierBoldFont;

    int currentBrowser;
    MonetList *currentMainList; // Either SymbolList or ParameterList
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
