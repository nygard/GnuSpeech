#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MMSymbol;
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

    IBOutlet NSBox *commentView;
    IBOutlet NSTextView *commentText;
    IBOutlet NSButtonCell *setButton;
    IBOutlet NSButtonCell *revertButton;

    IBOutlet NSBox *valueBox;
    IBOutlet NSForm *valueFields;
    IBOutlet NSButtonCell *setValueButton;
    IBOutlet NSButtonCell *revertValueButton;

    MMSymbol *currentSymbol;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)dealloc;

- (void)setCurrentSymbol:(MMSymbol *)aSymbol;
- (void)inspectSymbol:(MMSymbol *)aSymbol;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)setComment:(id)sender;
- (IBAction)revertComment:(id)sender;

- (IBAction)setValue:(id)sender;
- (IBAction)revertValue:(id)sender;

@end
