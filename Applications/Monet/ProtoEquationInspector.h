
#import <AppKit/AppKit.h>
#import "ProtoEquation.h"
#import "FormulaParser.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: ProtoEquationInspector
	Purpose: Oversees the functioning of the ProtoEquationInspector Panel

	Date: May 18, 1994

History:
	May 18, 1994
		Integrated into MONET.

===========================================================================*/


@interface ProtoEquationInspector:NSObject
{
	id	mainInspector;
	id	popUpListView;
	id	popUpList;

	id	commentView;
	id	commentText;
	id	setCommentButton;
	id	revertCommentButton;

	id	equationBox;
	id	equationText;
	id	messagesText;
	id	setEquationButton;
	id	revertEquationButton;
	id	currentEquationField;

	id	usageBox;
	id	usageBrowser;
	id	usageField;

	ProtoEquation *protoEquation;
	id	formParser;

	MonetList	*equationList;
}

- init;
- (void)inspectProtoEquation:equation;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)setUpWindow:sender;
- (void)beginEditting;

- (void)setComment:sender;
- (void)revertComment:sender;

- (void)setEquation:sender;
- (void)revertEquation:sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (void)browserHit:sender;
- (void)browserDoubleHit:sender;


@end
