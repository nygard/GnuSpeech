#import <AppKit/NSResponder.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface DelegateResponder : NSResponder
{
    id nonretained_delegate;
}

- (id)init;
- (BOOL)acceptsFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

- (void)cut:(id)sender;
- (void)copy:(id)sender;
- (void)paste:(id)sender;

@end
