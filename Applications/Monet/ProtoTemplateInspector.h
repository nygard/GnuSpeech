#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class FormulaParser, MonetList, MMTransition;
@class Inspector;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: ProtoTemplateInspector
	Purpose: Oversees the functioning of the ProtoTempplateInspector Panel

	Date: May 19, 1994

History:
	May 19, 1994
		Integrated into MONET.

===========================================================================*/


@interface ProtoTemplateInspector : NSObject
{
    IBOutlet Inspector *mainInspector;
    IBOutlet NSBox *popUpListView;
    IBOutlet NSPopUpButton *popUpList;

    IBOutlet NSBox *genInfoView;
    IBOutlet NSMatrix *typeMatrix;

    IBOutlet NSBox *commentView;
    IBOutlet NSTextView *commentText;
    IBOutlet NSButtonCell *setCommentButton;
    IBOutlet NSButtonCell *revertCommentButton;

    IBOutlet NSBox *usageBox;
    IBOutlet NSBrowser *usageBrowser;
    IBOutlet NSTextField *usageField;

    MMTransition *currentMMTransition;

    MonetList *templateList;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (id)init;
- (void)dealloc;

- (void)setCurrentMMTransition:(MMTransition *)aTemplate;
- (void)inspectMMTransition:(MMTransition *)aTemplate;

- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)setComment:(id)sender;
- (IBAction)revertComment:(id)sender;

- (IBAction)setDiphone:(id)sender;
- (IBAction)setTriphone:(id)sender;
- (IBAction)setTetraphone:(id)sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (IBAction)browserHit:(id)sender;
- (IBAction)browserDoubleHit:(id)sender;

@end
