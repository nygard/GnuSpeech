
#import "CategoryInspector.h"
#import "Inspector.h"
#import <AppKit/NSText.h>
#import <string.h>

@implementation CategoryInspector

- init
{
	return self;
}

- (void)inspectCategory:category
{
	currentCategory = category;
	[mainInspector setPopUpListView:categoryPopUpListView];
	[self setUpWindow:categoryPopUpList]; 
}

- (void)setUpWindow:sender
{
const char *temp;

	temp = [[[sender selectedCell] title] cString];
	switch(temp[0])
	{
		/* Comment Window */
		case 'C':
			[mainInspector setGeneralView:commentView];

			[setButton setTarget:self];
			[setButton setAction:(SEL)(@selector(setComment:))];

			[revertButton setTarget:self];
			[revertButton setAction:(SEL)(@selector(revertComment:))];

			[commentText setString:[NSString stringWithCString:[currentCategory comment]]];

			break;
	} 
}

- (void)beginEditting
{
const char *temp;

	temp = [[[categoryPopUpList selectedCell] title] cString];
	switch(temp[0])
	{
		/* Comment Window */
		case 'C':
			[commentText selectAll:self];
			break;
	} 
}

- (void)setComment:sender
{
	[currentCategory setComment:[[commentText string] cString] ];
}

- (void)revertComment:sender
{
	[commentText setString:[NSString stringWithCString:[currentCategory comment]]]; 
}


@end
