#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MMRule;
@class Inspector;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: RuleInspector
	Purpose: Oversees the functioning of the RuleInspector Panel

	Date: May 24, 1994

History:
	May 24, 1994
		Integrated into MONET.

===========================================================================*/


@interface RuleInspector : NSObject
{
    IBOutlet Inspector *mainInspector;
    IBOutlet NSBox *popUpListView;
    IBOutlet NSPopUpButton *popUpList;

    int currentBrowser;
    IBOutlet NSBox *browserView;
    IBOutlet NSBrowser *mainBrowser;
    IBOutlet NSBrowser *selectionBrowser;

    IBOutlet NSBox *genInfoBox;
    IBOutlet NSTextField *consumeText;
    IBOutlet NSTextField *locationTextField;
    IBOutlet NSTextField *moveToField;

    IBOutlet NSTextView *commentText;
    IBOutlet NSBox *commentView;
    IBOutlet NSButtonCell *setCommentButton;
    IBOutlet NSButtonCell *revertCommentButton;

    MMRule *currentRule;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (id)init;
- (void)dealloc;

- (void)setCurrentRule:(MMRule *)aRule;
- (void)inspectRule:(MMRule *)aRule;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)browserHit:(id)sender;
- (IBAction)browserDoubleHit:(id)sender;
- (IBAction)selectionBrowserHit:(id)sender;
- (IBAction)selectionBrowserDoubleHit:(id)sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (IBAction)setComment:(id)sender;
- (IBAction)revertComment:(id)sender;
- (IBAction)moveRule:(id)sender;

@end
