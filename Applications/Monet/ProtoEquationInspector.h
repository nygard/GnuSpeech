#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class FormulaParser, MonetList, ProtoEquation;
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

    IBOutlet NSBox *commentView;
    IBOutlet NSTextView *commentText;
    IBOutlet NSButtonCell *setCommentButton;
    IBOutlet NSButtonCell *revertCommentButton;

    IBOutlet NSBox *equationBox;
    IBOutlet NSTextView *equationText;
    IBOutlet NSTextView *messagesText;
    IBOutlet NSButtonCell *setEquationButton;
    IBOutlet NSButtonCell *revertEquationButton;
    IBOutlet NSTextField *currentEquationField;

    IBOutlet NSBox *usageBox;
    IBOutlet NSBrowser *usageBrowser;
    IBOutlet NSTextField *usageField;

    ProtoEquation *currentProtoEquation;
    FormulaParser *formulaParser;

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
