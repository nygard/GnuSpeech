
#import <AppKit/AppKit.h>
#import "RuleList.h"

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


@interface RuleInspector:NSObject
{
	id	mainInspector;
	id	popUpListView;
	id	popUpList;

	int	currentBrowser;
	id	browserView;
	id	mainBrowser;
	id	selectionBrowser;

	id	genInfoBox;
	id	consumeText;
	id	locationTextField;
	id	moveToField;

	id	commentText;
	id	commentView;
	id	setCommentButton;
	id	revertCommentButton;

	Rule	*currentRule;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- init;
- (void)inspectRule:rule;
- (void)setUpWindow:sender;
- (void)beginEditting;

- (void)browserHit:sender;
- (void)browserDoubleHit:sender;
- (void)selectionBrowserHit:sender;
- (void)selectionBrowserDoubleHit:sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)moveRule:sender;

- (void)setComment:sender;
- (void)revertComment:sender;

@end
