
#import "DelegateResponder.h"

@implementation DelegateResponder

- init
{
	[super init];
	delegate = nil;
	return self;
}

- (BOOL) acceptsFirstResponder
{
	printf("DelegateResponder: Now first responder\n");
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	return YES;
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

- delegate
{
	return delegate;
}

- (void)cut:(id)sender
{
	[delegate cut:sender];
}

- (void)copy:(id)sender
{
	[delegate copy:sender];
}

- (void)paste:(id)sender
{
	[delegate paste:sender];
}


@end
