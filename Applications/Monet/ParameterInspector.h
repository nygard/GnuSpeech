#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class Parameter;
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

    id commentView;
    id commentText;
    id setCommentButton;
    id revertCommentButton;

    id valueBox;
    id valueFields;
    id setValueButton;
    id revertValueButton;

    Parameter *currentParameter;
}

- (void)inspectParameter:(Parameter *)parameter;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)setComment:(id)sender;
- (IBAction)revertComment:(id)sender;

- (IBAction)setValue:(id)sender;
- (IBAction)revertValue:(id)sender;

@end
