#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MonetList, ProtoEquation;

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


@interface ProtoEquationInspector : NSObject
{
    id mainInspector;
    id popUpListView;
    id popUpList;

    id commentView;
    id commentText;
    id setCommentButton;
    id revertCommentButton;

    id equationBox;
    id equationText;
    id messagesText;
    id setEquationButton;
    id revertEquationButton;
    id currentEquationField;

    id usageBox;
    id usageBrowser;
    id usageField;

    ProtoEquation *protoEquation;
    id formParser;

    MonetList *equationList;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (id)init;
- (void)dealloc;
- (void)inspectProtoEquation:equation;

- (void)setUpWindow:(id)sender;
- (void)beginEditting;

- (void)setComment:(id)sender;
- (void)revertComment:(id)sender;

- (void)setEquation:(id)sender;
- (void)revertEquation:(id)sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (void)browserHit:(id)sender;
- (void)browserDoubleHit:(id)sender;


@end
