#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MonetList, ProtoTemplate;

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
    id mainInspector;
    id popUpListView;
    id popUpList;

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

- (void)inspectProtoTemplate:template;

- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (void)setComment:(id)sender;
- (void)revertComment:(id)sender;

- (void)setDiphone:(id)sender;
- (void)setTriphone:(id)sender;
- (void)setTetraphone:(id)sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (void)browserHit:(id)sender;
- (void)browserDoubleHit:(id)sender;

@end
