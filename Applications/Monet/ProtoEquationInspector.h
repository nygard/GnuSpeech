#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MonetList, ProtoEquation;
@class Inspector;

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
    IBOutlet Inspector *mainInspector;
    IBOutlet NSBox *popUpListView;
    IBOutlet NSPopUpButton *popUpList;

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

    ProtoEquation *currentProtoEquation;
    id formParser;

    MonetList *equationList;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (id)init;
- (void)dealloc;

- (void)setCurrentProtoEquation:(ProtoEquation *)anEquation;
- (void)inspectProtoEquation:(ProtoEquation *)anEquation;

- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)setComment:(id)sender;
- (IBAction)revertComment:(id)sender;

- (IBAction)setEquation:(id)sender;
- (IBAction)revertEquation:(id)sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (IBAction)browserHit:(id)sender;
- (IBAction)browserDoubleHit:(id)sender;


@end
