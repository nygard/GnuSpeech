#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class Symbol;

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
    id mainInspector;
    id symbolPopUpListView;
    id symbolPopUpList;

    id commentView;
    id commentText;
    id setButton;
    id revertButton;

    id valueBox;
    id valueFields;
    id setValueButton;
    id revertValueButton;


    Symbol *currentSymbol;
}

- (void)inspectSymbol:symbol;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (void)setComment:(id)sender;
- (void)revertComment:(id)sender;

- (void)setValue:(id)sender;
- (void)revertValue:(id)sender;

@end
