#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MonetList, ProtoTemplate;
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

    id genInfoView;
    id typeMatrix;

    id commentView;
    id commentText;
    id setCommentButton;
    id revertCommentButton;

    id usageBox;
    id usageBrowser;
    id usageField;

    ProtoTemplate *protoTemplate;
    id formParser;

    MonetList *templateList;
}

- (id)init;
- (void)dealloc;

- (void)inspectProtoTemplate:(ProtoTemplate *)template;

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
