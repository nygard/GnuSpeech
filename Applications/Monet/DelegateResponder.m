#import "DelegateResponder.h"

#import <AppKit/AppKit.h>

@implementation DelegateResponder

- (id)init;
{
    if ([super init] == nil)
        return nil;

    nonretained_delegate = nil;

    return self;
}

- (BOOL)acceptsFirstResponder;
{
    NSLog(@"DelegateResponder: Now first responder");
    return YES;
}

- (BOOL)becomeFirstResponder;
{
    return YES;
}

- (BOOL)resignFirstResponder;
{
    return YES;
}

- (id)delegate;
{
    return nonretained_delegate;
}

- (void)setDelegate:(id)aDelegate;
{
    nonretained_delegate = aDelegate;
}

- (void)cut:(id)sender;
{
    [nonretained_delegate cut:sender];
}

- (void)copy:(id)sender;
{
    [nonretained_delegate copy:sender];
}

- (void)paste:(id)sender;
{
    [nonretained_delegate paste:sender];
}


@end
