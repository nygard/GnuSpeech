
#import <AppKit/AppKit.h>
#import "SymbolList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: SymbolInspector
	Purpose: Oversees the functioning of the PhoneInspector Panel

	Date: March 24, 1994

History:
	March 24, 1994
		Integrated into MONET.

===========================================================================*/


@interface SymbolInspector:NSObject
{
	id	mainInspector;
	id	symbolPopUpListView;
	id	symbolPopUpList;

	id	commentView;
	id	commentText;
	id	setButton;
	id	revertButton;

	id	valueBox;
	id	valueFields;
	id	setValueButton;
	id	revertValueButton;


	Symbol	*currentSymbol;

}

- init;
- (void)inspectSymbol:phone;
- (void)setUpWindow:sender;
- (void)beginEditting;

- (void)setComment:sender;
- (void)revertComment:sender;

- (void)setValue:sender;
- (void)revertValue:sender;

@end
