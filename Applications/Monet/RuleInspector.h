#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class Rule;
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
    id browserView;
    id mainBrowser;
    id selectionBrowser;

    id genInfoBox;
    id consumeText;
    id locationTextField;
    id moveToField;

    id commentText;
    id commentView;
    id setCommentButton;
    id revertCommentButton;

    Rule *currentRule;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (id)init;
- (void)inspectRule:(Rule *)rule;
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
