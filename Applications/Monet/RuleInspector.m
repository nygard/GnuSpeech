
#import "RuleInspector.h"
#import "Inspector.h"
#import "RuleManager.h"
#import "PrototypeManager.h"
#import "ProtoEquation.h"
#import "FormulaExpression.h"
#import "TransitionView.h"
#import "SpecialView.h"

@implementation RuleInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [mainBrowser setTarget:self];
	[mainBrowser setAction:(SEL)(@selector(browserHit:))];
	[mainBrowser setDoubleAction:(SEL)(@selector(browserDoubleHit:))];

	[selectionBrowser setTarget:self];
	[selectionBrowser setAction:(SEL)(@selector(selectionBrowserHit:))];
	[selectionBrowser setDoubleAction:(SEL)(@selector(selectionBrowserDoubleHit:))];
}

- init
{
	currentBrowser = 0;
	return self;
}

- (void)inspectRule:rule
{
	currentRule = rule;
	[mainInspector setPopUpListView:popUpListView];
	[self setUpWindow:popUpList]; 
}

- (void)setUpWindow:sender
{
const char *temp;
char buffer[256];
id ruleManager;
int tempIndex;

	temp = [[[sender selectedCell] title] cString];
	switch(temp[0])
	{
		case 'C':
			[popUpList setTitle:@"Comment"];
			[mainInspector setGeneralView:commentView];

			[setCommentButton setTarget:self];
			[setCommentButton setAction:(SEL)(@selector(setComment:))];

			[revertCommentButton setTarget:self];
			[revertCommentButton setAction:(SEL)(@selector(revertComment:))];

			[commentText setString:[NSString stringWithCString:[currentRule comment]]];
			break;
		case 'G':
			[popUpList setTitle:@"General Information"];
			[mainInspector setGeneralView:genInfoBox];

			ruleManager = NXGetNamedObject(@"ruleManager", NSApp);
			tempIndex = [[ruleManager ruleList] indexOfObject:currentRule] + 1;
			[locationTextField setIntValue:tempIndex];
			[moveToField setIntValue:tempIndex];

			sprintf(buffer, "Consumes %d tokens.", [currentRule numberExpressions]);

			[consumeText setStringValue:[NSString stringWithCString:buffer]];

			break;
		case 'E': currentBrowser = 1;
			[popUpList setTitle:@"Equations"];
			[mainInspector setGeneralView:browserView];

			[mainBrowser setAllowsMultipleSelection:NO];

			[mainBrowser loadColumnZero];
			[selectionBrowser loadColumnZero];

			break;

		case 'P': currentBrowser = 2;
			[popUpList setTitle:@"Parameter Prototypes"];
			[mainInspector setGeneralView:browserView];

			[mainBrowser setAllowsMultipleSelection:YES];

			[mainBrowser loadColumnZero];
			[selectionBrowser loadColumnZero];

			break;

		case 'M': currentBrowser = 3;
			[popUpList setTitle:@"Meta Parameter Prototypes"];
			[mainInspector setGeneralView:browserView];

			[mainBrowser setAllowsMultipleSelection:NO];

			[mainBrowser loadColumnZero];
			[selectionBrowser loadColumnZero];

			break;

		case 'S': currentBrowser = 4;
			[popUpList setTitle:@"Special Prototypes"];
			[mainInspector setGeneralView:browserView];

			[mainBrowser setAllowsMultipleSelection:NO];

			[mainBrowser loadColumnZero];
			[selectionBrowser loadColumnZero];

			break;
	} 
}

- (void)beginEditting
{
const char *temp;

	temp = [[[popUpList selectedCell] title] cString];
	switch(temp[0])
	{
		case 'C':
			if(temp[1] == 'o')
			{
				[commentText selectAll:self];
			}
			else
			{
			
			}
			break;
		case 'P':
			break;
		case 'M':
			break;
		case 'S':
			break;
	} 
}


- (void)browserHit:sender
{
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
id tempCell;
int index, index1, index2;
char buffer[256];

	index = [[sender matrixInColumn:0] selectedRow];
	switch(currentBrowser)
	{
		case 1: tempCell = [[currentRule symbols] objectAtIndex: index];
			[tempProto findList: &index1 andIndex: &index2 ofEquation: tempCell];
			sprintf(buffer, "/%s/%s", [[(ProtoEquation *)[[tempProto equationList] objectAtIndex:index1] name] cString],
				[[(ProtoEquation *)[[[tempProto equationList] objectAtIndex:index1] objectAtIndex: index2] name] cString]);
			printf("Path = |%s|\n", buffer);
			[selectionBrowser setPath:[NSString stringWithCString:buffer]];

			break;

		case 2: tempCell = [[currentRule parameterList] objectAtIndex: index];
			[tempProto findList: &index1 andIndex: &index2 ofTransition: tempCell];
			sprintf(buffer, "/%s/%s", [[(ProtoEquation *)[[tempProto transitionList] objectAtIndex:index1] name] cString],
				[[(ProtoEquation *)[[[tempProto transitionList] objectAtIndex:index1] objectAtIndex: index2] name] cString]);
			printf("Path = |%s|\n", buffer);
			[selectionBrowser setPath:[NSString stringWithCString:buffer]];

			break;
		case 3: tempCell = [[currentRule metaParameterList] objectAtIndex: index];
			[tempProto findList: &index1 andIndex: &index2 ofTransition: tempCell];
			sprintf(buffer, "/%s/%s", [[(ProtoEquation *)[[tempProto transitionList] objectAtIndex:index1] name] cString],
				[[(ProtoEquation *)[[[tempProto transitionList] objectAtIndex:index1] objectAtIndex: index2] name] cString]);
			[selectionBrowser setPath:[NSString stringWithCString:buffer]];
			break;

		case 4: tempCell = [currentRule getSpecialProfile:index];
			[tempProto findList: &index1 andIndex: &index2 ofSpecial: tempCell];
			sprintf(buffer, "/%s/%s", [[(ProtoEquation *)[[tempProto specialList] objectAtIndex:index1] name] cString],
				[[(ProtoEquation *)[[[tempProto specialList] objectAtIndex:index1] objectAtIndex: index2] name] cString]);
			[selectionBrowser setPath:[NSString stringWithCString:buffer]];

			break;
	} 
}

- (void)browserDoubleHit:sender
{
id transitionBuilder = NXGetNamedObject(@"transitionBuilder", NSApp);
id specialTransitionBuilder = NXGetNamedObject(@"specialTransitionBuilder", NSApp);
id tempCell;
int index;

	index = [[sender matrixInColumn:0] selectedRow];
	switch(currentBrowser)
	{
		case 1: 
			break;

		case 2: tempCell = [[currentRule parameterList] objectAtIndex: index];
			[transitionBuilder setTransition:tempCell];
			[(SpecialView *)transitionBuilder showWindow:[[sender window] windowNumber]];
			break;

		case 3: 
			break;

		case 4: tempCell = [currentRule getSpecialProfile:index];
			[specialTransitionBuilder setTransition:tempCell];
			[(SpecialView *)specialTransitionBuilder showWindow:[[sender window] windowNumber]];

			break;
	} 
}

- (void)selectionBrowserHit:sender
{
int listIndex, index, parameterIndex, i;
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
id temp;
NSArray *selectedList, *cellList;

	if ([sender selectedColumn] == 1)
	{
		listIndex = [[sender matrixInColumn:0] selectedRow];
		index = [[sender matrixInColumn:1] selectedRow];
		parameterIndex = [[mainBrowser matrixInColumn:0] selectedRow];
		switch(currentBrowser)
		{
			case 1: temp = [tempProto findEquation:listIndex andIndex:    index];
				[[currentRule symbols] replaceObjectAtIndex: parameterIndex withObject: temp];
				/* Wait for setup */
				break;
			case 2: 
				selectedList = [mainBrowser selectedCells];
				temp = [tempProto findTransition:listIndex andIndex:    index];
				cellList = [[mainBrowser matrixInColumn:0] cells];

				for(i = 0; i<[selectedList count]; i++)
				{
					[[currentRule parameterList] replaceObjectAtIndex:[cellList indexOfObject:[selectedList objectAtIndex:i]]
						withObject:temp];
//					printf("%d Index in list %d\n", i, [cellList indexOfObject:[selectedList objectAtIndex:i]]);
				}
				break;
			case 3: temp = [tempProto findTransition:listIndex andIndex:    index]; 
				[[currentRule metaParameterList] replaceObjectAtIndex: parameterIndex withObject: temp];
				break;
			case 4: temp = [tempProto findSpecial:listIndex andIndex:    index];
				[currentRule setSpecialProfile: parameterIndex to: temp];
				break;
		}		
	} 
}

- (void)selectionBrowserDoubleHit:sender
{
	 
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
int index;

	if (sender == mainBrowser)
	{
		switch(currentBrowser)
		{
			case 1: /* Equations */
				return 5;
			case 2: /* parameters and their special profiles */
			case 4:
				return [NXGetNamedObject(@"mainParameterList", NSApp) count];
			case 3:
				return [NXGetNamedObject(@"mainMetaParameterList", NSApp) count];
				break;

		}
	}
	else
	{
		switch(currentBrowser)
		{
			case 1: if (column == 0)
					return [[NXGetNamedObject(@"prototypeManager", NSApp) equationList] count];
				else
				{
					index = [[sender matrixInColumn:0] selectedRow];
					return [[[NXGetNamedObject(@"prototypeManager",NSApp) equationList] objectAtIndex: index] count];
				}
				break;
			case 2:
			case 3: if (column == 0)
					return [[NXGetNamedObject(@"prototypeManager", NSApp) transitionList] count];
				else
				{
					index = [[sender matrixInColumn:0] selectedRow];
					return [[[NXGetNamedObject(@"prototypeManager",NSApp) transitionList]
							objectAtIndex: index] count];
				}
				break;
			case 4: if (column == 0)
					return [[NXGetNamedObject(@"prototypeManager", NSApp) specialList] count];
				else
				{
					index = [[sender matrixInColumn:0] selectedRow];
					return [[[NXGetNamedObject(@"prototypeManager",NSApp) specialList]
							objectAtIndex: index] count];
				}
		}
	}
	return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
id temp, list, tempCell;
int index;

	if (sender == mainBrowser)
	{
		switch(currentBrowser)
		{
			case 1: /* Equations */
				switch(row)
				{
					case 0: [cell setStringValue:@"Rule Duration"];
						break;
					case 1: [cell setStringValue:@"Beat"];
						break;
					case 2: [cell setStringValue:@"Mark 1"];
						break;
					case 3: [cell setStringValue:@"Mark 2"];
						if ([currentRule numberExpressions]<3)
							[cell setEnabled:NO];
						else
							[cell setEnabled:YES];
						break;
					case 4: [cell setStringValue:@"Mark 3"];
						if ([currentRule numberExpressions]<4)
							[cell setEnabled:NO];
						else
							[cell setEnabled:YES];
						break;
				}
				[cell setLeaf:YES];
				[cell setLoaded:YES];
				break;
			case 4:
			case 2: temp = NXGetNamedObject(@"mainParameterList", NSApp);
				[cell setStringValue:[NSString stringWithCString:[[temp objectAtIndex:row] symbol]]];
				[cell setLeaf:YES];
				[cell setLoaded:YES];
				break;
			case 3: temp = NXGetNamedObject(@"mainMetaParameterList", NSApp);
				[cell setStringValue:[NSString stringWithCString:[[temp objectAtIndex:row] symbol]]];
				[cell setLeaf:YES];
				[cell setLoaded:YES];
				break;

		}
	}
	else
	{
		temp = NXGetNamedObject(@"prototypeManager", NSApp);
		index = [[sender matrixInColumn:0] selectedRow];
		[cell setLoaded:YES];

		switch(currentBrowser)
		{
			case 1:	list = [temp equationList];
				if (column == 0)
				{
					[cell setStringValue:[(ProtoTemplate *)[list objectAtIndex:row] name]];
					[cell setLeaf:NO];
				}
				else
				{
					tempCell = [[list objectAtIndex:index] objectAtIndex:row];
					[cell setStringValue: [(ProtoTemplate *)tempCell name]];

//					if ([[tempCell expression] maxPhone] >=[currentRule numberExpressions])
//						[cell setEnabled:NO];
//					else
//						[cell setEnabled:YES];

					[cell setLeaf:YES];
				}
				break;
			case 2: list = [temp transitionList];
				if (column == 0)
				{
					[cell setStringValue:[(ProtoTemplate *)[list objectAtIndex:row] name]];
					[cell setLeaf:NO];
				}
				else
				{
					tempCell = [[list objectAtIndex:index] objectAtIndex:row];

					[cell setStringValue:[(ProtoTemplate *)tempCell name]];
					[cell setLeaf:YES];
					if ([currentRule numberExpressions] != [(ProtoTemplate *)tempCell type])
						[cell setEnabled:NO];
					else
						[cell setEnabled:YES];
				}
				break;
			case 3: list = [temp transitionList];
				if (column == 0)
				{
					[cell setStringValue:[(ProtoTemplate *)[list objectAtIndex:row] name]];
					[cell setLeaf:NO];
				}
				else
				{
					tempCell = [[list objectAtIndex:index] objectAtIndex:row];

					[cell setStringValue:[(ProtoTemplate *)tempCell name]];
					[cell setLeaf:YES];
					if ([currentRule numberExpressions] != [(ProtoTemplate *)tempCell type])
						[cell setEnabled:NO];
					else
						[cell setEnabled:YES];

				}
				break;

			case 4: list = [temp specialList];
				if (column == 0)
				{
					[cell setStringValue:[(ProtoTemplate *)[list objectAtIndex:row] name]];
					[cell setLeaf:NO];
				}
				else
				{
					tempCell = [[list objectAtIndex:index] objectAtIndex:row];

					[cell setStringValue:[(ProtoTemplate *)tempCell name]];
					[cell setLeaf:YES];
				}
				break;

		}
	}
}

- (void)setComment:sender
{
	[currentRule setComment: [[commentText string] cString]];
}

- (void)revertComment:sender
{
	[commentText setString:[NSString stringWithCString:[currentRule comment]]]; 
}

- (void)moveRule:sender
{
id ruleManager, ruleList;
int location = [moveToField intValue] - 1;

	ruleManager = NXGetNamedObject(@"ruleManager", NSApp);

	ruleList = [ruleManager ruleList];

	if ((location < 0) || (location >= [ruleList count]-1))
	{
		NSBeep();
		[moveToField selectText:self];
		return;
	}

	[ruleList removeObject: currentRule];
	[ruleList insertObject: currentRule atIndex: location];
	[ruleManager updateRuleDisplay]; 
}

@end
