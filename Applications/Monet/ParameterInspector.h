#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MMParameter;
@class Inspector;

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


@interface ParameterInspector : NSObject
{
    IBOutlet Inspector *mainInspector;
    IBOutlet NSBox *parameterPopUpListView;
    IBOutlet NSPopUpButton *parameterPopUpList;

    IBOutlet NSBox *commentView;
    IBOutlet NSTextView *commentText;
    IBOutlet NSButtonCell *setCommentButton;
    IBOutlet NSButtonCell *revertCommentButton;

    IBOutlet NSBox *valueBox;
    IBOutlet NSForm *valueFields;
    IBOutlet NSButtonCell *setValueButton;
    IBOutlet NSButtonCell *revertValueButton;

    MMParameter *currentParameter;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)dealloc;

- (void)setCurrentParameter:(MMParameter *)aParameter;
- (void)inspectParameter:(MMParameter *)aParameter;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)setComment:(id)sender;
- (IBAction)revertComment:(id)sender;

- (IBAction)setValue:(id)sender;
- (IBAction)revertValue:(id)sender;

@end
