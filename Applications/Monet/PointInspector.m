
#import "PointInspector.h"
#import "Inspector.h"
#import "ProtoTemplate.h"
#import "PrototypeManager.h"
#import "ProtoEquation.h"
#import "MyController.h"
#import <AppKit/NSText.h>
#import <AppKit/NSApplication.h>
#import <string.h>

@implementation PointInspector

- init
{
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [expressionBrowser setTarget:self];
	[expressionBrowser setAction:(SEL)(@selector(browserHit:))];
	[expressionBrowser setDoubleAction:(SEL)(@selector(browserDoubleHit:))];
}

- (void)inspectPoint:point
{
	/* Hack for Single Point Inspections */
	if ([point isKindOfClassNamed:"Point"])
	{
		currentPoint = point;
		[mainInspector setPopUpListView:popUpListView];
		[self setUpWindow:popUpList];
	}
	else
	if ([point count] == 1)
	{
		currentPoint = [point objectAtIndex: 0];
		[mainInspector setPopUpListView:popUpListView];
		[self setUpWindow:popUpList];
	}
	else
	{
		[mainInspector cleanInspectorWindow];
		[mainInspector setGeneralView:multipleListView];

	} 
}

- (void)setUpWindow:sender
{
const char *temp;
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
id tempCell;
int index1, index2;
char buffer[256];


	temp = [[[sender selectedCell] title] cString];
	switch(temp[0])
	{
		/* Comment Window */
		case 'C':
/*			[mainInspector setGeneralView: commentView];

			[setCommentButton setTarget:self];
			[setCommentButton setAction:(SEL)(@selector(setComment:))];

			[revertCommentButton setTarget:self];
			[revertCommentButton setAction:(SEL)(@selector(revertComment:))];

			[commentText setText:[currentParameter comment]];*/

			break;
		case 'G':
			[mainInspector setGeneralView:valueBox];
			[expressionBrowser loadColumnZero];

			[valueField setDoubleValue:[currentPoint value]];
			switch([currentPoint type])
			{
				case DIPHONE:
					[type1Button setState:1];
					[type2Button setState:0];
					[type3Button setState:0];
					break;
				case TRIPHONE:
					[type1Button setState:0];
					[type2Button setState:1];
					[type3Button setState:0];
					break;
				case TETRAPHONE:
					[type1Button setState:0];
					[type2Button setState:0];
					[type3Button setState:1];
					break;
			}

			[phantomSwitch setState:[currentPoint phantom]];

			bzero(buffer,256);
			tempCell = [currentPoint expression];
			if (tempCell)
			{
				[[tempCell expression] expressionString:buffer];
				[currentTimingField setStringValue:[NSString stringWithCString:buffer]];
			}
			else
			{
				sprintf(buffer, "Fixed: %.3f ms", [currentPoint freeTime]);
				[currentTimingField setStringValue:[NSString stringWithCString:buffer]];
			}
			[tempProto findList: &index1 andIndex: &index2 ofEquation: tempCell];
			sprintf(buffer, "/%s/%s", [[(ProtoEquation *)[[tempProto equationList] objectAtIndex:index1] name] cString],
				[[(ProtoEquation *)[[[tempProto equationList] objectAtIndex:index1] objectAtIndex: index2] name] cString]);
			printf("Path = |%s|\n", buffer);
			[expressionBrowser setPath:[NSString stringWithCString:buffer]];
			break;
	} 
}

- (void)beginEditting
{
const char *temp;

	temp = [[[popUpList selectedCell] title] cString];
	switch(temp[0])
	{
		/* Comment Window */
		case 'C':
//			[commentText selectAll:self];
			break;

		case 'D':
			[valueField selectText: self];

			break;
	} 
}

- (void)browserHit:sender
{
int listIndex, index;
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
id temp;
char buffer[256];

	if ([sender selectedColumn] == 1)
	{
		listIndex = [[sender matrixInColumn:0] selectedRow];
		index = [[sender matrixInColumn:1] selectedRow];
		[tempProto findEquation:listIndex andIndex:    index];
		temp = tempProto;
		[currentPoint setExpression:temp];

		bzero(buffer,256);
		[[temp expression] expressionString:buffer];
		[currentTimingField setStringValue:[NSString stringWithCString:buffer]];

		[NXGetNamedObject(@"transitionBuilder", NSApp) display];
		[NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];

	} 
}

- (void)browserDoubleHit:sender
{
	 
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
int index;

	if (column == 0)
		return [[NXGetNamedObject(@"prototypeManager", NSApp) equationList] count];
	else
	{
		index = [[sender matrixInColumn:0] selectedRow];
		return [[[NXGetNamedObject(@"prototypeManager", NSApp) equationList] objectAtIndex: index] count];
	}
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
id temp, list, tempCell;
int index;

	temp = NXGetNamedObject(@"prototypeManager", NSApp);
	index = [[sender matrixInColumn:0] selectedRow];
	[cell setLoaded:YES];

	list = [temp equationList];
	if (column == 0)
	{
		[cell setStringValue: [(ProtoEquation *)[list objectAtIndex:row] name]];
		[cell setLeaf:NO];
	}
	else
	{
		tempCell = [[list objectAtIndex:index] objectAtIndex:row];
		[cell setStringValue:[(ProtoEquation *)tempCell name]];

//		if ([[tempCell expression] maxPhone] >[currentPoint type])
//			[cell setEnabled:NO];
//		else
//			[cell setEnabled:YES];
		[cell setLeaf:YES];
	}
}

- (void)setValue:sender
{
id temp = NXGetNamedObject(@"transitionBuilder", NSApp);

	[currentPoint setValue:[sender doubleValue]];
	[temp display];
	[NXGetNamedObject(@"specialTransitionBuilder", NSApp) display]; 
}

- (void)setType1:sender
{
id temp = NXGetNamedObject(@"transitionBuilder", NSApp);

	[type2Button setState:0];
	[type3Button setState:0];
	[currentPoint setType:DIPHONE];
	[temp display];
	[NXGetNamedObject(@"specialTransitionBuilder", NSApp) display]; 
}

- (void)setType2:sender
{
id temp = NXGetNamedObject(@"transitionBuilder", NSApp);

	[type1Button setState:0];
	[type3Button setState:0];
	[currentPoint setType:TRIPHONE];
	[temp display];
	[NXGetNamedObject(@"specialTransitionBuilder", NSApp) display]; 
}

- (void)setType3:sender
{
id temp = NXGetNamedObject(@"transitionBuilder", NSApp);

	[type1Button setState:0];
	[type2Button setState:0];
	[currentPoint setType:TETRAPHONE];
	[temp display];
	[NXGetNamedObject(@"specialTransitionBuilder", NSApp) display]; 
}

- (void)setPhantom:sender
{
	[currentPoint setPhantom:[sender state]]; 
}

@end
