
#import "ParameterInspector.h"
#import "Inspector.h"
#import "MyController.h"
#import <AppKit/NSText.h>
#import <string.h>

@implementation ParameterInspector

- init
{
	return self;
}

- (void)inspectParameter:parameter
{
	currentParameter= parameter;
	[mainInspector setPopUpListView:parameterPopUpListView];
	[self setUpWindow:parameterPopUpList]; 
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

			[setCommentButton setTarget:self];
			[setCommentButton setAction:(SEL)(@selector(setComment:))];

			[revertCommentButton setTarget:self];
			[revertCommentButton setAction:(SEL)(@selector(revertComment:))];

			[commentText setString:[NSString stringWithCString:[currentParameter comment]]];

			break;
		case 'D':
			[mainInspector setGeneralView:valueBox];

			[setValueButton setTarget:self];
			[setValueButton setAction:(SEL)(@selector(setValue:))];

			[revertValueButton setTarget:self];
			[revertValueButton setAction:(SEL)(@selector(revertValue:))];

			[[valueFields cellAtIndex:0] setDoubleValue:[currentParameter minimumValue]];
			[[valueFields cellAtIndex:1] setDoubleValue:[currentParameter maximumValue]];
			[[valueFields cellAtIndex:2] setDoubleValue:[currentParameter defaultValue]];

			break;
	} 
}

- (void)beginEditting
{
const char *temp;

	temp = [[[parameterPopUpList selectedCell] title] cString];
	switch(temp[0])
	{
		/* Comment Window */
		case 'C':
			[commentText selectAll:self];
			break;

		case 'D':
			[valueFields selectTextAtIndex:0];

			break;
	} 
}

- (void)setComment:sender
{
	[currentParameter setComment: [[commentText string] cString]];
}

- (void)revertComment:sender
{
	[commentText setString:[NSString stringWithCString:[currentParameter comment]]]; 
}

- (void)setValue:sender
{

	if ([currentParameter defaultValue] !=  [[valueFields cellAtIndex:2] doubleValue])
	{
		[currentParameter setDefaultValue:[[valueFields cellAtIndex:2] doubleValue]];
		[NXGetNamedObject("mainPhoneList", NSApp) parameterDefaultChange:currentParameter to:[[valueFields cellAtIndex:2] doubleValue]];
	}

	[currentParameter setMinimumValue:[[valueFields cellAtIndex:0] doubleValue]];
	[currentParameter setMaximumValue:[[valueFields cellAtIndex:1] doubleValue]]; 
}

- (void)revertValue:sender
{
	[[valueFields cellAtIndex:0] setDoubleValue:[currentParameter minimumValue]];
	[[valueFields cellAtIndex:1] setDoubleValue:[currentParameter maximumValue]];
	[[valueFields cellAtIndex:2] setDoubleValue:[currentParameter defaultValue]]; 
}

@end
