
#import "ProtoTemplateInspector.h"
#import "Inspector.h"
#import "RuleManager.h"
#import "MyController.h"
#import <AppKit/NSText.h>
#import <AppKit/NSApplication.h>
#import <string.h>

@implementation ProtoTemplateInspector

- init
{
	formParser = [[FormulaParser alloc] init];
	templateList = [[MonetList alloc] initWithCapacity:20];
	return self;
}

- (void)inspectProtoTemplate:template
{
	protoTemplate = template;
	[mainInspector setPopUpListView:popUpListView];
	[self setUpWindow:popUpList]; 
}

- (void)setUpWindow:sender
{
id tempRuleManager = NXGetNamedObject("ruleManager", NSApp);
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

			[commentText setString:[NSString stringWithCString:[protoTemplate comment]]];

			break;
		case 'G':
			[mainInspector setGeneralView:genInfoView];

			switch([protoTemplate type])
			{
				case DIPHONE: 
					[typeMatrix selectCellAtRow:0 column:0];
					break;
				case TRIPHONE: 
					[typeMatrix selectCellAtRow:1 column:0];
					break;
				case TETRAPHONE: 
					[typeMatrix selectCellAtRow:2 column:0];
					break;
			}
			[typeMatrix display];
			break;
		case 'U':
			[usageBrowser setDelegate:self];
			[usageBrowser setTarget:self];
			[usageBrowser setAction:(SEL)(@selector(browserHit:))];
			[usageBrowser setDoubleAction:(SEL)(@selector(browserDoubleHit:))];
 			[mainInspector setGeneralView:usageBox];
			[templateList removeAllObjects];
			[tempRuleManager findTemplate: protoTemplate andPutIn: templateList];

			[usageBrowser loadColumnZero];
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
			[commentText selectAll:self];
			break;

	} 
}

- (void)setComment:sender
{
	[protoTemplate setComment: [[commentText string] cString]];
}

- (void)revertComment:sender
{
	[commentText setString:[NSString stringWithCString:[protoTemplate comment]]]; 
}

- (void)setDiphone:sender
{
	[protoTemplate setType:DIPHONE];
	[NXGetNamedObject("transitionBuilder", NSApp) display];
	[NXGetNamedObject("specialTransitionBuilder", NSApp) display]; 
}

- (void)setTriphone:sender
{
	[protoTemplate setType:TRIPHONE];
	[NXGetNamedObject("transitionBuilder", NSApp) display];
	[NXGetNamedObject("specialTransitionBuilder", NSApp) display]; 
}

- (void)setTetraphone:sender
{
	[protoTemplate setType:TETRAPHONE];
	[NXGetNamedObject("transitionBuilder", NSApp) display];
	[NXGetNamedObject("specialTransitionBuilder", NSApp) display]; 
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
char buffer[128];
	sprintf(buffer,"Equation Usage: %d", [templateList count]);
	[usageBrowser setTitle:[NSString stringWithCString:buffer] ofColumn:0];
	return [templateList count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
id tempRuleManager = NXGetNamedObject("ruleManager", NSApp);
id tempRuleList; 
char buffer[128];

	tempRuleList = [tempRuleManager ruleList];
	[cell setLeaf:YES];
	[cell setLoaded:YES];

	if ([[templateList objectAtIndex: row] isKindOfClassNamed:"Rule"])
	{
		bzero(buffer, 128);
		sprintf(buffer,"Rule: %d\n", [tempRuleList indexOfObject: [templateList objectAtIndex: row]]+1);
		[cell setStringValue:[NSString stringWithCString:buffer]];
	}
}

- (void)browserHit:sender
{
	 
}

- (void)browserDoubleHit:sender
{
	 
}


@end
