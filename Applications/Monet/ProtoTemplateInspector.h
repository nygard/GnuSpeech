
#import <AppKit/AppKit.h>
#import "ProtoTemplate.h"
#import "FormulaParser.h"

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


@interface ProtoTemplateInspector:NSObject
{
	id	mainInspector;
	id	popUpListView;
	id	popUpList;

	id	genInfoView;
	id	typeMatrix;

	id	commentView;
	id	commentText;
	id	setCommentButton;
	id	revertCommentButton;

	id      usageBox;
	id      usageBrowser;
	id      usageField;

	ProtoTemplate *protoTemplate;
	id	formParser;

	MonetList	*templateList;

}

- init;
- (void)inspectProtoTemplate:template;

- (void)setUpWindow:sender;
- (void)beginEditting;

- (void)setDiphone:sender;
- (void)setTriphone:sender;
- (void)setTetraphone:sender;

- (void)setComment:sender;
- (void)revertComment:sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (void)browserHit:sender;
- (void)browserDoubleHit:sender;

@end
