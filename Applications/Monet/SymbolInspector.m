
#import "SymbolInspector.h"
#import "Inspector.h"
#import "MyController.h"
#import <AppKit/NSText.h>
#import <string.h>

@implementation SymbolInspector

- init
{
	return self;
}

- (void)inspectSymbol:symbol
{
	currentSymbol = symbol;
	[mainInspector setPopUpListView:symbolPopUpListView];
	[self setUpWindow:symbolPopUpList]; 
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

			[commentText setString:[NSString stringWithCString:[currentSymbol comment]]];

			break;
	       case 'D':
			[mainInspector setGeneralView:valueBox];

			[setValueButton setTarget:self];
			[setValueButton setAction:(SEL)(@selector(setValue:))];

			[revertValueButton setTarget:self];
			[revertValueButton setAction:(SEL)(@selector(revertValue:))];

			[[valueFields cellAtIndex:0] setDoubleValue:[currentSymbol minimumValue]];
			[[valueFields cellAtIndex:1] setDoubleValue:[currentSymbol maximumValue]];
			[[valueFields cellAtIndex:2] setDoubleValue:[currentSymbol defaultValue]];

			break;
	} 
}

- (void)beginEditting
{
const char *temp;

	temp = [[[symbolPopUpList selectedCell] title] cString];
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
	[currentSymbol setComment: [[commentText string] cString]];
}

- (void)revertComment:sender
{
	[commentText setString:[NSString stringWithCString:[currentSymbol comment]]]; 
}

- (void)setValue:sender
{

	if ([currentSymbol defaultValue] !=  [[valueFields cellAtIndex:2] doubleValue])
	{
		[currentSymbol setDefaultValue:[[valueFields cellAtIndex:2] doubleValue]];
		[NXGetNamedObject(@"mainPhoneList", NSApp) symbolDefaultChange:currentSymbol to:[[valueFields cellAtIndex:2] doubleValue]];
	}

	[currentSymbol setMinimumValue:[[valueFields cellAtIndex:0] doubleValue]];
	[currentSymbol setMaximumValue:[[valueFields cellAtIndex:1] doubleValue]]; 
}

- (void)revertValue:sender
{
	[[valueFields cellAtIndex:0] setDoubleValue:[currentSymbol minimumValue]];
	[[valueFields cellAtIndex:1] setDoubleValue:[currentSymbol maximumValue]];
	[[valueFields cellAtIndex:2] setDoubleValue:[currentSymbol defaultValue]]; 
}

@end

