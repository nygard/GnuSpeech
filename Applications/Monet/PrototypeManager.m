
#import "PrototypeManager.h"
#import "ProtoEquation.h"
#import "ProtoTemplate.h"
#import "MyController.h"
#import "RuleManager.h"
#import "Inspector.h"
#import "DelegateResponder.h"
#import "TransitionView.h"
#import "SpecialView.h"
#import <AppKit/NSPasteboard.h>

@implementation PrototypeManager

- init
{
	/* Set up Prototype equations major list */
	protoEquations = [[MonetList alloc] initWithCapacity:10];

	/* Set up Protytype transitions major list */
	protoTemplates = [[MonetList alloc] initWithCapacity:10];

	/* Set up Prototype Special Transitions major list */
	protoSpecial = [[MonetList alloc] initWithCapacity:10];

	/* Set up responder for cut/copy/paste operations */
	delegateResponder = [[DelegateResponder alloc] init];
	[delegateResponder setDelegate:self];

	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [protoBrowser setTarget:self];
	[protoBrowser setAction:(SEL)(@selector(browserHit:))];
	[protoBrowser setDoubleAction:(SEL)(@selector(browserDoubleHit:))];

	courier = [NSFont fontWithName:@"Courier" size:12];
	courierBold = [NSFont fontWithName:@"Courier-Bold" size:12];
}

- (void)browserHit:sender
{
id temp, tempList, tempEntry;
int column = [protoBrowser selectedColumn];
int row = [[protoBrowser matrixInColumn:column] selectedRow];
char string[256];
id ruleManager = NXGetNamedObject("ruleManager", NSApp);


	temp = [controller inspector];

	if ([[sender matrixInColumn:0] selectedRow] !=(-1))
		[newButton setEnabled:YES];
	else
		[newButton setEnabled:NO];

	if (column == 0)
	{
		switch([[browserSelector selectedCell] tag])
		{
			case 0: [inputTextField setStringValue: [(ProtoEquation *)[protoEquations objectAtIndex:row] name]];
				break;
			case 1: [inputTextField setStringValue:[(ProtoEquation *)[protoTemplates objectAtIndex:row] name]];
				break;
			case 2: [inputTextField setStringValue:[(ProtoEquation *)[protoSpecial objectAtIndex:row] name]];
				break;
		}
		[inputTextField selectText:sender];
		[[sender window] makeFirstResponder:delegateResponder];
		[temp cleanInspectorWindow];
		return;
	}

	switch([[browserSelector selectedCell] tag])
	{
		case 0: 
			tempList = [protoEquations objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
			tempEntry = [tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
			bzero(string, 256);
			[[tempEntry expression] expressionString:string];
			[selectedOutput setStringValue:[NSString stringWithCString:string]];
			[removeButton setEnabled:!([ruleManager isEquationUsed:tempEntry] ||
				[self isEquationUsed:tempEntry] )] ;
			[temp inspectProtoEquation:tempEntry];
			break;
		case 1: 
			tempList = [protoTemplates objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
			tempEntry = [tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
			[removeButton setEnabled:![ruleManager isTransitionUsed:tempEntry]];
			[temp inspectProtoTransition:tempEntry];
			switch([(ProtoTemplate *) tempEntry type])
			{
				case DIPHONE:[selectedOutput setStringValue:@"Diphone"];
					break;
				case TRIPHONE:[selectedOutput setStringValue:@"Triphone"];
					break;
				case TETRAPHONE:[selectedOutput setStringValue:@"Tetraphone"];
					break;
			}
			break;
		case 2: 
			tempList = [protoSpecial objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
			tempEntry = [tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
			[removeButton setEnabled:![ruleManager isTransitionUsed:tempEntry]];
			[temp inspectProtoTransition:tempEntry];
			switch([(ProtoTemplate *) tempEntry type])
			{
				case DIPHONE:[selectedOutput setStringValue:@"Diphone"];
					break;
				case TRIPHONE:[selectedOutput setStringValue:@"Triphone"];
					break;
				case TETRAPHONE:[selectedOutput setStringValue:@"Tetraphone"];
					break;
			}
			break;
		default: printf("WHAT?\n");
			break;
	}

	[[sender window] makeFirstResponder:delegateResponder]; 
}

- (void)browserDoubleHit:sender
{
id temp, tempList;
int column = [protoBrowser selectedColumn];

	if (column == 0)
		return;

	switch([[browserSelector selectedCell] tag])
	{
		case 0: 
			break;
		case 1: 
			temp = NXGetNamedObject("transitionBuilder", NSApp);
			tempList = [protoTemplates objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
			[temp setTransition:[tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]]];
			[(TransitionView *)temp showWindow:[[protoBrowser window] windowNumber]];
			break;
		case 2: 
			temp = NXGetNamedObject("specialTransitionBuilder", NSApp);
			tempList = [protoSpecial objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
			[temp setTransition:[tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]]];
			[(TransitionView *)temp showWindow:[[protoBrowser window] windowNumber]];
			break;
		default: printf("WHAT?\n");
			break;
	} 
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
NamedList *tempList;

	switch([[browserSelector selectedCell] tag])
	{
		case 0: if (column == 0)
				return [protoEquations count];
			else
			{
				tempList = [protoEquations objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
				return [tempList count];
			}
			break;
		case 1: if (column == 0)
				return [protoTemplates count];
			else
			{
				tempList = [protoTemplates objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
				return [tempList count];
			}
			break;
		case 2: if (column == 0)
				return [protoSpecial count];
			else
			{
				tempList = [protoSpecial objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
				return [tempList count];
			}
			break;
		default: printf("WHAT?\n");
			break;
	}
	return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
id ruleManager = NXGetNamedObject("ruleManager", NSApp);
NamedList *tempList;
BOOL used = NO;

	switch([[browserSelector selectedCell] tag])
	{
		/* Equations */
		case 0: if (column == 0)
			{
				[cell setStringValue:[(ProtoEquation *)[protoEquations objectAtIndex:row] name]];
				[cell setLeaf:NO];
				[cell setLoaded:YES];
			}
			else
			{
				tempList = [protoEquations objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
				[cell setStringValue:[(ProtoEquation *)[tempList objectAtIndex:row] name]];
				[cell setLeaf:YES];
				[cell setLoaded:YES];
				used = [ruleManager isEquationUsed:[tempList objectAtIndex:row]];
				if (!used)
					used = [self isEquationUsed:[tempList objectAtIndex:row]];

				if (used)
					[cell setFont:courierBold];
				else
					[cell setFont:courier];

			}
			break;

		/* Templates */
		case 1: if (column == 0)
			{
				[cell setStringValue:[(ProtoEquation *)[protoTemplates objectAtIndex:row] name]];
				[cell setLeaf:NO];
				[cell setLoaded:YES];
			}
			else
			{
				tempList = [protoTemplates objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
				[cell setStringValue:[(ProtoEquation *)[tempList objectAtIndex:row] name]];
				[cell setLeaf:YES];
				[cell setLoaded:YES];
				used = [ruleManager isTransitionUsed:[tempList objectAtIndex:row]];

				if (used)
					[cell setFont:courierBold];
				else
					[cell setFont:courier];
			}
			break;
		/* Special Profiles */
		case 2: if (column == 0)
			{
				[cell setStringValue:[(ProtoEquation *)[protoSpecial objectAtIndex:row] name]];
				[cell setLeaf:NO];
				[cell setLoaded:YES];
			}
			else
			{
				tempList = [protoSpecial objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
				[cell setStringValue:[(ProtoEquation *)[tempList objectAtIndex:row] name]];
				[cell setLeaf:YES];
				[cell setLoaded:YES];
				used = [ruleManager isTransitionUsed:[tempList objectAtIndex:row]];

				if (used)
					[cell setFont:courierBold];
				else
					[cell setFont:courier];
			}
			break;
		default: printf("WHAT?\n");
			break;
	}
}

- (void)addCategory:sender
{
NamedList *tempList;

	switch([[browserSelector selectedCell] tag])
	{
		case 0: /* Test for Already Existing Name */
			tempList = [[NamedList alloc] initWithCapacity:10];
			[tempList setName:[inputTextField stringValue]];
			[protoEquations addObject: tempList];
			[protoBrowser loadColumnZero];
			break;
		case 1: /* Test for Already Existing Name */
			tempList = [[NamedList alloc] initWithCapacity:10];
			[tempList setName:[inputTextField stringValue]];
			[protoTemplates addObject: tempList];
			[protoBrowser loadColumnZero];
			break;
		case 2: /* Test for Already Existing Name */
			tempList = [[NamedList alloc] initWithCapacity:10];
			[tempList setName:[inputTextField stringValue]];
			[protoSpecial addObject: tempList];
			[protoBrowser loadColumnZero];
			break;
	} 
}

- (void)add:sender
{
NamedList *tempList;
ProtoEquation *tempEquation;

	switch([[browserSelector selectedCell] tag])
	{
		case 0: /* Test for Already Existing Name */
			tempList = [protoEquations objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
			tempEquation = [[ProtoEquation alloc] initWithName:[inputTextField stringValue]];
			[tempList addObject: tempEquation];
			[protoBrowser reloadColumn:1];
			break;
		case 1: /* Test for Already Existing Name */
			tempList = [protoTemplates objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
			tempEquation = [[ProtoTemplate alloc] initWithName:[inputTextField stringValue]];
			[tempList addObject: tempEquation];
			[protoBrowser reloadColumn:1];
			break;
		case 2: /* Test for Already Existing Name */
			tempList = [protoSpecial objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
			tempEquation = [[ProtoTemplate alloc] initWithName:[inputTextField stringValue]];
			[tempList addObject: tempEquation];
			[protoBrowser reloadColumn:1];
			break;
	} 
}

- (void)rename:sender
{
NamedList *temp = nil;
id tempList;
int column = [protoBrowser selectedColumn];

	printf("Rename: Column = %d\n", column);
	switch([[browserSelector selectedCell] tag])
	{
		case 0:
			if (column == 0)
			{
				temp = [protoEquations objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
				printf("Rename : %s\n", [[temp name] cString]);
			}
			else
			{
				tempList = [protoEquations objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
				temp = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
				printf("Rename: %s\n", [[temp name] cString]);
			}
			break;
		case 1:
			if (column == 0)
			{
				temp = [protoTemplates objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
				printf("Rename: %s\n", [[temp name] cString]);
			}
			else
			{
				tempList = [protoTemplates objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
				temp = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
				printf("Rename: %s\n", [[temp name] cString]);
			}
			break;

		case 2:
			if (column == 0)
			{
				temp = [protoSpecial objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
				printf("Rename: %s\n", [[temp name] cString]);
			}
			else
			{
				tempList = [protoSpecial objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
				temp = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
				printf("Rename: %s\n", [[temp name] cString]);
			}

	}


	[temp setName:[inputTextField stringValue]];
	[protoBrowser reloadColumn:column]; 
}

- (void)remove:sender
{
	 
}

- (void)setEquations:sender
{
id temp = [controller inspector];

	[newButton setTitle:@"New Equation"];
	[newButton setEnabled:NO];
	[outputBox setTitle:@"Selected Prototype Equation"];
	[outputBox display];
	[protoBrowser loadColumnZero];
	[temp cleanInspectorWindow]; 
}

- (void)setTransitions:sender
{
id temp = [controller inspector];

	[newButton setTitle:@"New Transition"];
	[newButton setEnabled:NO];
	[outputBox setTitle:@"Selected Prototype Transition Type"];
	[outputBox display];
	[protoBrowser loadColumnZero];
	[temp cleanInspectorWindow]; 
}

- (void)setSpecial:sender
{
id temp = [controller inspector];

	[newButton setTitle:@"New Special"];
	[newButton setEnabled:NO];
	[outputBox setTitle:@"Selected Prototype Transition Type"];
	[outputBox display];
	[protoBrowser loadColumnZero];
	[temp cleanInspectorWindow]; 
}

- equationList
{
	return protoEquations;
}

- transitionList
{
	return protoTemplates;
}

- specialList
{
	return protoSpecial;
}

- findEquationList: (const char *) list named: (const char *) name
{
id tempList;
int i, j;

	for (i = 0 ; i < [protoEquations count]; i++)
	{
		if ([[NSString stringWithCString:list] isEqualToString:[(ProtoEquation *)[protoEquations objectAtIndex:i] name]])
		{
			tempList = [protoEquations objectAtIndex:i];
			for (j = 0; j < [tempList count]; j++)
			{
				if ([[NSString stringWithCString:name] isEqualToString:[(ProtoEquation *)[tempList objectAtIndex: j] name]])
					return [tempList objectAtIndex: j];
			}
		}

	}
	return nil;
}

- findList: (int *) listIndex andIndex: (int *) index ofEquation: equation
{
int i, temp;

	for (i = 0 ; i < [protoEquations count]; i++)
	{
		temp = [[protoEquations objectAtIndex:i] indexOfObject:equation];
		if (temp != NSNotFound)
		{
			*listIndex = i;
			*index = temp;
			return self;
		}

	}
	*listIndex = (-1);
	return self;
}

- findEquation: (int) listIndex andIndex: (int) index
{
	return [[protoEquations objectAtIndex: listIndex] objectAtIndex: index];
}

- findTransitionList: (const char *) list named: (const char *) name
{
id tempList;
int i, j;

	for (i = 0 ; i < [protoTemplates count]; i++)
	{
		if ([[NSString stringWithCString:list] isEqualToString:[(ProtoEquation *)[protoTemplates objectAtIndex:i] name]])
		{
			tempList = [protoTemplates objectAtIndex:i];
			for (j = 0; j < [tempList count]; j++)
			{
				if ([[NSString stringWithCString:name] isEqualToString:[(ProtoEquation *)[tempList objectAtIndex: j] name]])
					return [tempList objectAtIndex: j];
			}
		}

	}
	return nil;
}

- findList: (int *) listIndex andIndex: (int *) index ofTransition: transition
{
int i, temp;

	for (i = 0 ; i < [protoTemplates count]; i++)
	{
		temp = [[protoTemplates objectAtIndex:i] indexOfObject:transition];
		if (temp != NSNotFound)
		{
			*listIndex = i;
			*index = temp;
			return self;
		}

	}
	*listIndex = (-1);
	return self;
}

- findTransition: (int) listIndex andIndex: (int) index
{
//	printf("Name: %s (%d)\n", [[protoTemplates objectAtIndex: listIndex] name], listIndex);
//	printf("\tCount: %d  index: %d  count: %d\n", [protoTemplates count], 
//		index, [[protoTemplates objectAtIndex: listIndex] count]);
	return [[protoTemplates objectAtIndex: listIndex] objectAtIndex: index];
}

- findSpecialList: (const char *) list named: (const char *) name
{
id tempList;
int i, j;

	for (i = 0 ; i < [protoSpecial count]; i++)
	{
		if ([[NSString stringWithCString:list] isEqualToString:[(ProtoEquation *)[protoSpecial objectAtIndex:i] name]])
		{
			tempList = [protoSpecial objectAtIndex:i];
			for (j = 0; j < [tempList count]; j++)
			{
				if ([[NSString stringWithCString:name] isEqualToString:[(ProtoEquation *)[tempList objectAtIndex: j] name]])
					return [tempList objectAtIndex: j];
			}
		}

	}
	return nil;
}

- findList: (int *) listIndex andIndex: (int *) index ofSpecial: transition
{
int i, temp;

	for (i = 0 ; i < [protoSpecial count]; i++)
	{
		temp = [[protoSpecial objectAtIndex:i] indexOfObject:transition];
		if (temp != NSNotFound)
		{
			*listIndex = i;
			*index = temp;
			return self;
		}

	}
	*listIndex = (-1);
	return self;
}

- findSpecial: (int) listIndex andIndex: (int) index
{
	return [[protoSpecial objectAtIndex: listIndex] objectAtIndex: index];
}

- (BOOL) isEquationUsed: anEquation
{
int i, j;
id tempList;

	for(i = 0; i<[protoTemplates count];i++)
	{
		tempList = [protoTemplates objectAtIndex:i];
		for(j = 0; j<[tempList count]; j++)
		{
			if ([[tempList objectAtIndex:j] isEquationUsed:anEquation])
				return YES;
		}
	}

	for(i = 0; i<[protoSpecial count];i++)
	{
		tempList = [protoSpecial objectAtIndex:i];
		for(j = 0; j<[tempList count]; j++)
		{
			if ([[tempList objectAtIndex:j] isEquationUsed:anEquation])
				return YES;
		}
	}
	return NO;

}

- (void)cut:(id)sender
{
	printf("PrototypeManager: cut\n");
}

NSString *equString = @"ProtoEquation";
NSString *tranString = @"ProtoTransition";
NSString *specialString = @"ProtoSpecial";

- (void)copy:(id)sender
{
NSPasteboard *myPasteboard;
NSMutableData *mdata;
NSArchiver *typed = NULL;
NSString *dataType;
int column = [protoBrowser selectedColumn];
int retValue;
id tempList, tempEntry;


	myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];

	printf("PrototypeManager: copy  |%s|\n", [[myPasteboard name] cString]);

	mdata = [NSMutableData dataWithCapacity: 16];
	typed = [[NSArchiver alloc] initForWritingWithMutableData: mdata];

	if (column != 1)
	{
		NSBeep();
		printf("Don't support copying a whole sublist yet \n");
		[typed release];
		return;
	}
	else
	switch([[browserSelector selectedCell] tag])
	{
		/* Equations */
		case 0: tempList = [protoEquations objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
			tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
			[tempEntry encodeWithCoder:typed];
			dataType = equString;
			retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
			[myPasteboard setData: mdata forType: equString];
			printf("Ret from Pasteboard: %d\n", retValue);
			break;

		/* Transitions */
		case 1: tempList = [protoTemplates objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
			tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
			[tempEntry encodeWithCoder:typed];
			dataType = tranString;
			retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
			[myPasteboard setData: mdata forType: tranString];
			printf("Ret from Pasteboard: %d\n", retValue);
			break;

		/* Special Transitions */
		case 2: tempList = [protoSpecial objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
			tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
			[tempEntry encodeWithCoder:typed];
			dataType = specialString;
			retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
			[myPasteboard setData: mdata forType: specialString];
			printf("Ret from Pasteboard: %d\n", retValue);
			break;
	}
	[typed release];
}

- (void)paste:(id)sender
{
NSPasteboard *myPasteboard;
NSData *mdata;
NSArchiver *typed = NULL;
NSArray *dataTypes;
id temp, tempList;
int column = [protoBrowser selectedColumn];

	myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];
	printf("PrototypeManager: paste  changeCount = %d  |%s|\n", [myPasteboard changeCount], [[myPasteboard name] cString]);


	dataTypes = [myPasteboard types];

	if ([[dataTypes objectAtIndex: 0] isEqual: equString])
	{
		if (column == (-1))
		{
			NSBeep();
			return;
		}
		mdata = [myPasteboard dataForType:equString];
		typed = [[NSUnarchiver alloc] initForReadingWithData: mdata];
		temp = [[ProtoEquation alloc] init];
		[temp initWithCoder:typed];
		[typed release];

		tempList = [protoEquations objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
		if (column == 1)
			[tempList insertObject: temp atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
		else
			[tempList addObject: temp];

		[protoBrowser reloadColumn:1];
		return;
	}
	else
	if ([[dataTypes objectAtIndex: 0] isEqual: tranString])
	{
		if (column == (-1))
		{
			NSBeep();
			return;
		}
		mdata = [myPasteboard dataForType:tranString];
		typed = [[NSUnarchiver alloc] initForReadingWithData: mdata];
		temp = [[ProtoTemplate alloc] init];
		[temp initWithCoder:typed];
		[typed release];

		tempList = [protoTemplates objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
		if (column == 1)
			[tempList insertObject: temp atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
		else
			[tempList addObject: temp];

		[protoBrowser reloadColumn:1];
		return;
	}
	else
	if ([[dataTypes objectAtIndex: 0] isEqual: specialString])
	{
		if (column == (-1))
		{
			NSBeep();
			return;
		}
		mdata = [myPasteboard dataForType:specialString];
		typed = [[NSUnarchiver alloc] initForReadingWithData: mdata];
		temp = [[ProtoTemplate alloc] init];
		[temp initWithCoder:typed];
		[typed release];

		tempList = [protoSpecial objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
		if (column == 1)
			[tempList insertObject: temp atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
		else
			[tempList addObject: temp];

		[protoBrowser reloadColumn:1];
		return;
	}
	NSBeep();
}

- (void)readPrototypesFrom:(NSArchiver *)stream
{
	[protoEquations release];
	[protoTemplates release];
	[protoSpecial release];

	protoEquations = [[stream decodeObject] retain];
	protoTemplates = [[stream decodeObject] retain];
	protoSpecial = [[stream decodeObject] retain]; 
}

#ifdef NeXT
- _readPrototypesFrom:(NXTypedStream *)stream
{
        [protoEquations release];
        [protoTemplates release];
        [protoSpecial release];

	NS_DURING
        protoEquations = NXReadObject(stream);
        protoTemplates = NXReadObject(stream);
        protoSpecial = NXReadObject(stream);
	NS_HANDLER
	  NSLog(@"Got Exception reading NeXT style prototypes");
	NS_ENDHANDLER
//      [[[protoTemplates objectAt: 0] objectAt:1] setType:3];
//      [[[protoTemplates objectAt: 0] objectAt:2] setType:4];

        return self;
}
#endif

- (void)writePrototypesTo:(NSArchiver *)stream
{
	[stream encodeObject:protoEquations];
	[stream encodeObject:protoTemplates];
	[stream encodeObject:protoSpecial]; 
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
  id temp = [controller inspector];
id tempList, tempEntry;
int column = [protoBrowser selectedColumn];

	printf("Column = %d\n", column);
	if (column != 1)
	{
		[temp cleanInspectorWindow];
		return;
	}

	switch([[browserSelector selectedCell] tag])
	{
		case 0: 
			tempList = [protoEquations objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
			tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
			[temp inspectProtoEquation:tempEntry];
			break;
		case 1: 
			tempList = [protoTemplates objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
			tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
			[temp inspectProtoTransition:tempEntry];
			break;
		case 2: 
			tempList = [protoSpecial objectAtIndex: [[protoBrowser matrixInColumn:0] selectedRow]];
			tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
			[temp inspectProtoTransition:tempEntry];
			break;
		default: [temp cleanInspectorWindow];
			break;
	}
}

- (BOOL)windowShouldClose:(id)sender
{
id temp;
	temp = [controller inspector];
	[temp cleanInspectorWindow];

	return YES;
}

- (void)windowDidResignMain:(NSNotification *)notification
{
    id temp;
	temp = [controller inspector];
	[temp cleanInspectorWindow];
}


@end
