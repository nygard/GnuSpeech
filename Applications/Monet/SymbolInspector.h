#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class Symbol;
@class Inspector;

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
    IBOutlet Inspector *mainInspector;
    IBOutlet NSBox *symbolPopUpListView;
    IBOutlet NSPopUpButton *symbolPopUpList;

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

- (void)dealloc;

- (void)setCurrentSymbol:(Symbol *)aSymbol;
- (void)inspectSymbol:(Symbol *)aSymbol;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)setComment:(id)sender;
- (IBAction)revertComment:(id)sender;

- (IBAction)setValue:(id)sender;
- (IBAction)revertValue:(id)sender;

@end
