#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class Parameter;

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
    id mainInspector;
    id parameterPopUpListView;
    id parameterPopUpList;

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

- (void)inspectParameter:parameter;
- (void)setUpWindow:(id)sender;
- (void)beginEditting;

- (void)setComment:(id)sender;
- (void)revertComment:(id)sender;

- (void)setValue:(id)sender;
- (void)revertValue:(id)sender;

@end
