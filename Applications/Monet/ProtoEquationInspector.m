
#import "ProtoEquationInspector.h"
#import "PrototypeManager.h"
#import "Inspector.h"
#import "RuleList.h"
#import "RuleManager.h"
#import "MyController.h"
#import <AppKit/NSText.h>
#import <AppKit/NSApplication.h>
#import <Foundation/NSArray.h>
#import <string.h>

@implementation ProtoEquationInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [usageBrowser setTarget:self];
	[usageBrowser setAction:(SEL)(@selector(browserHit:))];
	[usageBrowser setDoubleAction:(SEL)(@selector(browserDoubleHit:))];
}

- init
{
	formParser = [[FormulaParser alloc] init];
	equationList = [[MonetList alloc] initWithCapacity:20];
	return self;
}

- (void)inspectProtoEquation:equation;
{
	protoEquation = equation;
	[mainInspector setPopUpListView:popUpListView];
	[self setUpWindow:popUpList];
}

- (void)setUpWindow:sender
{
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
id tempRuleManager = NXGetNamedObject(@"ruleManager", NSApp);
id tempProtoManager = NXGetNamedObject(@"prototypeManager", NSApp);
const char *temp;
char string[1024];
int index1, index2;
int i, j;
id tempList1, tempList2;
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

			[commentText setString:[NSString stringWithCString:[protoEquation comment]]];

			break;
		case 'E':
			[mainInspector setGeneralView:equationBox];

			[setEquationButton setTarget:self];
			[setEquationButton setAction:(SEL)(@selector(setEquation:))];

			[revertEquationButton setTarget:self];
			[revertEquationButton setAction:(SEL)(@selector(revertEquation:))];

			bzero(string, 1024);
			[[protoEquation expression] expressionString:string];
			[equationText setString:[NSString stringWithCString:string]];

			[tempProto findList: &index1 andIndex: &index2 ofEquation: protoEquation];
			sprintf(string, "%s:%s", [[(ProtoEquation *)[[tempProto equationList] objectAtIndex:index1] name] cString],
				[[(ProtoEquation *)[[[tempProto equationList] objectAtIndex:index1] objectAtIndex: index2] name] cString]);

			[currentEquationField setStringValue:[NSString stringWithCString:string]];
			break;

		case 'U':
			[usageBrowser setDelegate:self];
			[usageBrowser setTarget:self];
			[usageBrowser setAction:(SEL)(@selector(browserHit:))];
			[usageBrowser setDoubleAction:(SEL)(@selector(browserDoubleHit:))];
			[mainInspector setGeneralView:usageBox];
			[usageBrowser setDelegate:self];
			[equationList removeAllObjects];
			[tempRuleManager findEquation: protoEquation andPutIn: equationList];

			tempList1 = [tempProtoManager transitionList];
			for (i = 0; i< [tempList1 count]; i++)
			{
				tempList2 = [tempList1 objectAtIndex: i];
				for (j = 0; j< [tempList2 count]; j++)
					[[tempList2 objectAtIndex:j] findEquation: protoEquation andPutIn: equationList];
			}
			tempList1 = [tempProtoManager specialList];
			for (i = 0; i< [tempList1 count]; i++)
			{
				tempList2 = [tempList1 objectAtIndex: i];
				for (j = 0; j< [tempList2 count]; j++)
					[[tempList2 objectAtIndex:j] findEquation: protoEquation andPutIn: equationList];
			}

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

		case 'E':

			break;
	} 
}

- (void)setComment:sender
{
	[protoEquation setComment: [commentText cString]];
}

- (void)revertComment:sender
{
	[commentText setString:[NSString stringWithCString:[protoEquation comment]]]; 
}

- (void)setEquation:sender
{
id temp;
const char *tempString;

	tempString = [equationText cString];

	[formParser setSymbolList:NXGetNamedObject(@"mainSymbolList", NSApp)];
	[formParser setErrorOutput:messagesText];

	temp = [formParser parseString:tempString];
	if (temp)
	{
		[protoEquation setExpression:temp];
	} 
}

- (void)revertEquation:sender
{
char string[1024];

	bzero(string, 1024);
	[[protoEquation expression] expressionString:string];
	[equationText setString:[NSString stringWithCString:string]]; 
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
char buffer[128];
	sprintf(buffer,"Equation Usage: %d", [equationList count]);
	[usageBrowser setTitle:[NSString stringWithCString:buffer] ofColumn:0];
	return [equationList count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
id tempRuleManager = NXGetNamedObject(@"ruleManager", NSApp);
id tempProtoManager = NXGetNamedObject(@"prototypeManager", NSApp);
id tempRuleList; 
char buffer[128];
int i, j;

	tempRuleList = [tempRuleManager ruleList];
	[cell setLeaf:YES];
	[cell setLoaded:YES];

	if ([[equationList objectAtIndex: row] isKindOfClassNamed:"Rule"])
	{
		bzero(buffer, 128);
		sprintf(buffer,"Rule: %d\n", [tempRuleList indexOfObject: [equationList objectAtIndex: row]]+1);
		[cell setStringValue:[NSString stringWithCString:buffer]];
	}
	else
	{
		[tempProtoManager findList: &i andIndex: &j ofTransition:[equationList objectAtIndex: row]];
		if (i>=0)
		{
			sprintf(buffer,"T:%s:%s", [[(ProtoEquation *)[[tempProtoManager transitionList] objectAtIndex: i] name] cString], 
				[[(ProtoEquation *)[[[tempProtoManager transitionList] objectAtIndex: i] objectAtIndex: j] name] cString]);
				[cell setStringValue:[NSString stringWithCString:buffer]];
		}
		else
		{
			[tempProtoManager findList: &i andIndex: &j ofSpecial:[equationList objectAtIndex: row]];
			if (i>=0)
			{
				sprintf(buffer,"S:%s:%s", [[(ProtoEquation *)[[tempProtoManager specialList] objectAtIndex: i] name] cString], 
					[[(ProtoEquation *)[[[tempProtoManager specialList] objectAtIndex: i] objectAtIndex: j] name] cString]);
				[cell setStringValue:[NSString stringWithCString:buffer]];
			}
		}
	}
}

- (void)browserHit:sender
{
	 
}

- (void)browserDoubleHit:sender
{
	 
}

@end
