
#import <AppKit/AppKit.h>
#import "ParameterList.h"

/*===========================================================================

Author: Craig-Richard Taube-Schock
Copyright (c) 1994, Trillium Sound Research Incorporated.
All Rights Reserved.

=============================================================================

	Object: ParameterInspector
	Purpose: Oversees the functioning of the PhoneInspector Panel

	Date: March 24, 1994

History:
	March 24, 1994
		Integrated into MONET.

===========================================================================*/


@interface ParameterInspector:NSObject
{
	id	mainInspector;
	id	parameterPopUpListView;
	id	parameterPopUpList;

	id	commentView;
	id	commentText;
	id	setCommentButton;
	id	revertCommentButton;

	id	valueBox;
	id	valueFields;
	id	setValueButton;
	id	revertValueButton;

	Parameter	*currentParameter;

}

- init;
- (void)inspectParameter:phone;
- (void)setUpWindow:sender;
- (void)beginEditting;

- (void)setComment:sender;
- (void)revertComment:sender;

- (void)setValue:sender;
- (void)revertValue:sender;

@end
