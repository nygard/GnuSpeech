
#import "RuleManager.h"
#import "PhoneList.h"
#import "SymbolList.h"
#import "ParameterList.h"
#import "ProtoEquation.h"
#import <AppKit/NSApplication.h>
#import "DelegateResponder.h"


@implementation RuleManager

- init
{
int i;

	cacheValue = 1;

	matchLists = [[MonetList alloc] initWithCapacity: 4];
	for (i = 0; i<4; i++)
	{
		[matchLists addObject: [[PhoneList alloc] init]];
	}

	ruleList = [[RuleList alloc] initWithCapacity: 20];

	boolParser = [[BooleanParser alloc] init];

	/* Set up responder for cut/copy/paste operations */
	delegateResponder = [[DelegateResponder alloc] init];
	[delegateResponder setDelegate:self];


	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    id temp, temp1;

	[ruleMatrix setTarget:self];
	[ruleMatrix setAction:(SEL)(@selector(browserHit:))];
	[ruleMatrix setDoubleAction:(SEL)(@selector(browserDoubleHit:))];

	[boolParser setCategoryList:NXGetNamedObject("mainCategoryList", NSApp)];
	[boolParser setPhoneList:NXGetNamedObject("mainPhoneList", NSApp)];

	temp = [boolParser parseString:"phone"];
	temp1 = [boolParser parseString:"phone"];
	[ruleList seedListWith: temp : temp1];
}

- (void)browserHit:sender
{
id temp;
int index;
Rule *tempRule;
char string[256];


	index = [[sender matrixInColumn:0] selectedRow];
	tempRule = [ruleList objectAtIndex: index];

	temp = [controller inspector];
	[temp inspectRule:[ruleList objectAtIndex:index]];

	bzero(string, 256);
	[[tempRule getExpressionNumber:0] expressionString:string];
	[[expressionFields cellAtIndex:0] setStringValue:[NSString stringWithCString:string]];

	bzero(string, 256);
	[[tempRule getExpressionNumber:1] expressionString:string];
	[[expressionFields cellAtIndex:1] setStringValue:[NSString stringWithCString:string]];

	bzero(string, 256);
	[[tempRule getExpressionNumber:2] expressionString:string];
	[[expressionFields cellAtIndex:2] setStringValue:[NSString stringWithCString:string]];

	bzero(string, 256);
	[[tempRule getExpressionNumber:3] expressionString:string];
	[[expressionFields cellAtIndex:3] setStringValue:[NSString stringWithCString:string]];

	[self evaluateMatchLists];

	[[sender window] makeFirstResponder:delegateResponder]; 
}

- (void)browserDoubleHit:sender
{
	 
}

- expressionString:(char *) string forRule:(int) index
{
Rule *tempRule;
char tempString[256];

	tempRule = [ruleList objectAtIndex: index];

	sprintf(string, "%d. ", index+1);

	bzero(tempString, 256);
	[[tempRule getExpressionNumber:0] expressionString:tempString];
	strcat(string,tempString);

	bzero(tempString, 256);
	[[tempRule getExpressionNumber:1] expressionString:tempString];
	strcat(string, " >> ");
	strcat(string,tempString);

	bzero(tempString, 256);
	[[tempRule getExpressionNumber:2] expressionString:tempString];
	if (strlen(tempString))
	{
		strcat(string, " >> ");
		strcat(string,tempString);
	}

	bzero(tempString, 256);
	[[tempRule getExpressionNumber:3] expressionString:tempString];
	if (strlen(tempString))
	{
		strcat(string, " >> ");
		strcat(string,tempString);
	}


	return self;
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
	if (sender == matchBrowser1)
	{
		return [[matchLists objectAtIndex:0]count];
	}
	else
	if (sender == matchBrowser2)
	{
		return [[matchLists objectAtIndex:1]count];
	}
	else
	if (sender == matchBrowser3)
	{
		return [[matchLists objectAtIndex:2]count];
	}
	else
	if (sender == matchBrowser4)
	{
		return [[matchLists objectAtIndex:3]count];
	}
	else
	if (sender == ruleMatrix)
		return [ruleList count];

	return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
Phone *tempPhone;
Rule *tempRule;
char string[2048], tempString[256];

	if (sender == matchBrowser1)
	{
		tempPhone = [[matchLists objectAtIndex:0 ] objectAtIndex: row];
		[cell setStringValue:[NSString stringWithCString:[tempPhone symbol]]];
	}
	else
	if (sender == matchBrowser2)
	{
		tempPhone = [[matchLists objectAtIndex:1 ] objectAtIndex: row];
		[cell setStringValue:[NSString stringWithCString:[tempPhone symbol]]];
	}
	else
	if (sender == matchBrowser3)
	{
		tempPhone = [[matchLists objectAtIndex:2 ] objectAtIndex: row];
		[cell setStringValue:[NSString stringWithCString:[tempPhone symbol]]];
	}
	else
	if (sender == matchBrowser4)
	{
		tempPhone = [[matchLists objectAtIndex:3 ] objectAtIndex: row];
		[cell setStringValue:[NSString stringWithCString:[tempPhone symbol]]];
	}
	else
	if (sender == ruleMatrix)
	{
		tempRule = [ruleList objectAtIndex: row];
		bzero(string, 2048);
		bzero(tempString, 256);

		sprintf(string, "%d. ", row+1);

		[[tempRule getExpressionNumber:0] expressionString:tempString];
		strcat(string, tempString);

		bzero(tempString, 256);
		[[tempRule getExpressionNumber:1] expressionString:tempString];
		strcat(string, " >> ");
		strcat(string, tempString);

		bzero(tempString, 256);
		[[tempRule getExpressionNumber:2] expressionString:tempString];
		if (strlen(tempString))
		{
			strcat(string, " >> ");
			strcat(string, tempString);
		}

		bzero(tempString, 256);
		[[tempRule getExpressionNumber:3] expressionString:tempString];
		if (strlen(tempString))
		{
			strcat(string, " >> ");
			strcat(string, tempString);
		}

		[cell setStringValue:[NSString stringWithCString:string]];

	}
	[cell setLeaf:YES];
}

- (void)setExpression1:sender
{
id tempList;
PhoneList *mainPhoneList = NXGetNamedObject("mainPhoneList", NSApp);
BooleanExpression *tempExpression;
char string[256];
int i;

	if ([[[sender cellAtIndex:0] stringValue] isEqualToString:@""])
	{
		[self realignExpressions];
		[sender selectTextAtIndex:0];
		return;
	}

	[boolParser setCategoryList:NXGetNamedObject("mainCategoryList", NSApp)];
	[boolParser setPhoneList:mainPhoneList];
	[boolParser setErrorOutput:errorTextField];

	tempExpression = [boolParser parseString:[[[sender cellAtIndex:0] stringValue] cString]];
	if (!tempExpression)
	{
		[sender selectTextAtIndex:0];
		NSBeep();
		return;
	}

	[sender selectTextAtIndex:1];


	tempList = [matchLists objectAtIndex:0];
	[tempList removeAllObjects];

	for (i = 0; i< [mainPhoneList count]; i++)
	{
		if ([tempExpression evaluate: [[mainPhoneList objectAtIndex: i] categoryList]])
		{
			[tempList addObject: [mainPhoneList objectAtIndex: i]];
		}
	}
	
	[tempExpression release];

	sprintf(string,"Total Matches: %d", [tempList count]);
	[matchBrowser1 setTitle:[NSString stringWithCString:string] ofColumn:0];
	[matchBrowser1 loadColumnZero];
	[self updateCombinations]; 
}

- (void)setExpression2:sender
{
id tempList;
PhoneList *mainPhoneList = NXGetNamedObject("mainPhoneList", NSApp);
BooleanExpression *tempExpression;
char string[256];
int i;

	if ([[[sender cellAtIndex:1] stringValue] isEqualToString:@""])
	{
		[self realignExpressions];
		[sender selectTextAtIndex:0];
		return;
	}

	[boolParser setCategoryList:NXGetNamedObject("mainCategoryList", NSApp)];
	[boolParser setPhoneList:mainPhoneList];
	[boolParser setErrorOutput:errorTextField];

	tempExpression = [boolParser parseString:[[[sender cellAtIndex:1] stringValue] cString]];
	if (!tempExpression)
	{
		[sender selectTextAtIndex:1];
		NSBeep();
		return;
	}

	[sender selectTextAtIndex:2];


	tempList = [matchLists objectAtIndex:1];
	[tempList removeAllObjects];

	for (i = 0; i< [mainPhoneList count]; i++)
	{
		if ([tempExpression evaluate: [[mainPhoneList objectAtIndex: i] categoryList]])
		{
			[tempList addObject: [mainPhoneList objectAtIndex: i]];
		}
	}
	
	[tempExpression release];

	sprintf(string,"Total Matches: %d", [tempList count]);
	[matchBrowser2 setTitle:[NSString stringWithCString:string] ofColumn:0];
	[matchBrowser2 loadColumnZero];
	[self updateCombinations]; 
}

- (void)setExpression3:sender
{
id tempList;
PhoneList *mainPhoneList = NXGetNamedObject("mainPhoneList", NSApp);
BooleanExpression *tempExpression;
char string[256];
int i;

	if ([[[sender cellAtIndex:2] stringValue] isEqualToString:@""])
	{
		[self realignExpressions];
		[sender selectTextAtIndex:0];
		return;
	}

	[boolParser setCategoryList:NXGetNamedObject("mainCategoryList", NSApp)];
	[boolParser setPhoneList:mainPhoneList];
	[boolParser setErrorOutput:errorTextField];

	tempExpression = [boolParser parseString:[[[sender cellAtIndex:2] stringValue] cString]];
	if (!tempExpression)
	{
		[sender selectTextAtIndex:2];
		NSBeep();
		return;
	}

	[sender selectTextAtIndex:3];


	tempList = [matchLists objectAtIndex:2];
	[tempList removeAllObjects];

	for (i = 0; i< [mainPhoneList count]; i++)
	{
		if ([tempExpression evaluate: [[mainPhoneList objectAtIndex: i] categoryList]])
		{
			[tempList addObject: [mainPhoneList objectAtIndex: i]];
		}
	}
	
	[tempExpression release];

	sprintf(string,"Total Matches: %d", [tempList count]);
	[matchBrowser3 setTitle:[NSString stringWithCString:string] ofColumn:0];
	[matchBrowser3 loadColumnZero];
	[self updateCombinations]; 
}

- (void)setExpression4:sender
{
id tempList;
PhoneList *mainPhoneList = NXGetNamedObject("mainPhoneList", NSApp);
BooleanExpression *tempExpression;
char string[256];
int i;

	if ([[[sender cellAtIndex:3] stringValue] isEqualToString:@""])
	{
		[self realignExpressions];
		[sender selectTextAtIndex:0];
		return;
	}

	[boolParser setCategoryList:NXGetNamedObject("mainCategoryList", NSApp)];
	[boolParser setPhoneList:mainPhoneList];
	[boolParser setErrorOutput:errorTextField];

	tempExpression = [boolParser parseString:[[[sender cellAtIndex:3] stringValue] cString]];
	if (!tempExpression)
	{
		[sender selectTextAtIndex:3];
		NSBeep();
		return;
	}

	[sender selectTextAtIndex:0];


	tempList = [matchLists objectAtIndex:3];
	[tempList removeAllObjects];

	for (i = 0; i< [mainPhoneList count]; i++)
	{
		if ([tempExpression evaluate: [[mainPhoneList objectAtIndex: i] categoryList]])
		{
			[tempList addObject: [mainPhoneList objectAtIndex: i]];
		}
	}
	
	[tempExpression release];

	sprintf(string,"Total Matches: %d", [tempList count]);
	[matchBrowser4 setTitle:[NSString stringWithCString:string] ofColumn:0];
	[matchBrowser4 loadColumnZero];
	[self updateCombinations]; 
}

/*===========================================================================

	Method: realignExpressions
	Purpose: The purpose of this method is to align the sub-expressions 
		if one happens to have been removed.

===========================================================================*/
- (void)realignExpressions
{
	
	if ([[[expressionFields cellAtIndex:0] stringValue] isEqualToString:@""])
	{
		[[expressionFields cellAtIndex:0] setStringValue:[[expressionFields cellAtIndex:1] stringValue]];
		[[expressionFields cellAtIndex:1] setStringValue:@""];
	}

	if ([[[expressionFields cellAtIndex:1] stringValue] isEqualToString:@""])
	{
		[[expressionFields cellAtIndex:1] setStringValue:[[expressionFields cellAtIndex:2] stringValue]];
		[[expressionFields cellAtIndex:2] setStringValue:@""];
	}
	if ([[[expressionFields cellAtIndex:2] stringValue] isEqualToString:@""])
	{
		[[expressionFields cellAtIndex:2] setStringValue:[[expressionFields cellAtIndex:3] stringValue]];
		[[expressionFields cellAtIndex:3] setStringValue:@""];
	}

	if ([[[expressionFields cellAtIndex:3] stringValue] isEqualToString:@""])
	{
		[expressions removeObjectAtIndex:3];
	}

	[self evaluateMatchLists]; 
}

- (void)evaluateMatchLists
{
int i, j;
id tempList;
PhoneList *mainPhoneList = NXGetNamedObject("mainPhoneList", NSApp);
char string[256];

	for (j = 0; j<4; j++)
	{
		tempList = [matchLists objectAtIndex:j];
		[tempList removeAllObjects];

		for (i = 0; i< [mainPhoneList count]; i++)
		{
			if ([[expressions objectAtIndex: j] evaluate: [[mainPhoneList objectAtIndex: i] categoryList]])
			{
				[tempList addObject: [mainPhoneList objectAtIndex: i]];
			}
		}
	}

	sprintf(string,"Total Matches: %d", [[matchLists objectAtIndex:0] count]);
	[matchBrowser1 setTitle:[NSString stringWithCString:string] ofColumn:0];
	[matchBrowser1 loadColumnZero];

	sprintf(string,"Total Matches: %d", [[matchLists objectAtIndex:1] count]);
	[matchBrowser2 setTitle:[NSString stringWithCString:string] ofColumn:0];
	[matchBrowser2 loadColumnZero];

	sprintf(string,"Total Matches: %d", [[matchLists objectAtIndex:2] count]);
	[matchBrowser3 setTitle:[NSString stringWithCString:string] ofColumn:0];
	[matchBrowser3 loadColumnZero];

	sprintf(string,"Total Matches: %d", [[matchLists objectAtIndex:3] count]);
	[matchBrowser4 setTitle:[NSString stringWithCString:string] ofColumn:0];
	[matchBrowser4 loadColumnZero];

	[self updateCombinations]; 
}

- (void)updateCombinations
{
int temp = 0, temp1 = 0;
int i;

	temp = [[matchLists objectAtIndex:0] count];

	for (i = 1; i<4; i++)
		if ((temp1 = [[matchLists objectAtIndex:i] count]))
			temp*=temp1;

	[possibleCombinations setIntValue:temp]; 
}

- (void)updateRuleDisplay
{
	[ruleMatrix loadColumnZero]; 
}

- (void)add:sender
{
char string[1024];
PhoneList *mainPhoneList = NXGetNamedObject("mainPhoneList", NSApp);
BooleanExpression *exp1=nil, *exp2=nil, *exp3=nil, *exp4=nil;

	[boolParser setCategoryList:NXGetNamedObject("mainCategoryList", NSApp)];
	[boolParser setPhoneList:mainPhoneList];
	[boolParser setErrorOutput:errorTextField];

	if ([[[expressionFields cellAtIndex:0] stringValue] length])
		exp1 = [boolParser parseString:[[[expressionFields cellAtIndex:0] stringValue] cString]];
	if ([[[expressionFields cellAtIndex:1] stringValue] length])
		exp2 = [boolParser parseString:[[[expressionFields cellAtIndex:1] stringValue] cString]];
	if ([[[expressionFields cellAtIndex:2] stringValue] length])
		exp3 = [boolParser parseString:[[[expressionFields cellAtIndex:2] stringValue] cString]];
	if ([[[expressionFields cellAtIndex:3] stringValue] length])
		exp4 = [boolParser parseString:[[[expressionFields cellAtIndex:3] stringValue] cString]];

	[ruleList addRuleExp1: exp1 exp2: exp2 exp3: exp3 exp4: exp4];
	
	sprintf(string,"Total Rules: %d", [ruleList count]);
	[ruleMatrix setTitle:[NSString stringWithCString:string] ofColumn:0];
	[ruleMatrix loadColumnZero]; 
}

- (void)rename:sender
{
PhoneList *mainPhoneList = NXGetNamedObject("mainPhoneList", NSApp);
BooleanExpression *exp1=nil, *exp2=nil, *exp3=nil, *exp4=nil;
int index = [[ruleMatrix matrixInColumn:0] selectedRow];

	[boolParser setCategoryList:NXGetNamedObject("mainCategoryList", NSApp)];
	[boolParser setPhoneList:mainPhoneList];
	[boolParser setErrorOutput:errorTextField];

	if ([[[expressionFields cellAtIndex:0] stringValue] length])
		exp1 = [boolParser parseString:[[[expressionFields cellAtIndex:0] stringValue] cString]];
	if ([[[expressionFields cellAtIndex:1] stringValue] length])
		exp2 = [boolParser parseString:[[[expressionFields cellAtIndex:1] stringValue] cString]];
	if ([[[expressionFields cellAtIndex:2] stringValue] length])
		exp3 = [boolParser parseString:[[[expressionFields cellAtIndex:2] stringValue] cString]];
	if ([[[expressionFields cellAtIndex:3] stringValue] length])
		exp4 = [boolParser parseString:[[[expressionFields cellAtIndex:3] stringValue] cString]];

	[ruleList changeRuleAt: index exp1: exp1 exp2: exp2 exp3: exp3 exp4: exp4];
	
	[ruleMatrix loadColumnZero]; 
}

- (void)remove:sender
{
int index = [[ruleMatrix matrixInColumn:0] selectedRow];

	[ruleList removeObjectAtIndex: index];
	[ruleMatrix loadColumnZero]; 
}

- (void)parseRule:sender
{
int i, j, dummy, phones = 0;
MonetList *tempList, *phoneList;
PhoneList *mainPhoneList;
Phone *tempPhone;
Rule *tempRule;
char string[1024];
double ruleSymbols[5] = {0.0, 0.0, 0.0, 0.0, 0.0}; 

	tempList = [[MonetList alloc] initWithCapacity:4];
	phoneList = [[MonetList alloc] initWithCapacity:4];
	mainPhoneList = NXGetNamedObject("mainPhoneList", NSApp);

	if ( ([[[phone1 cellAtIndex:0] stringValue] isEqualToString:@""]) || ([[[phone2 cellAtIndex:0] stringValue] isEqualToString:@""]) )
	{
		[ruleOutput setStringValue:@"You need at least to phones to parse."];
		return;
	}

	tempPhone = [mainPhoneList binarySearchPhone:[[[phone1 cellAtIndex:0] stringValue] cString] index:&dummy];
	if (!tempPhone)
	{
		sprintf(string, "Unknown phone: \"%s\"", [[[phone1 cellAtIndex:0] stringValue] cString]);
		[ruleOutput setStringValue:[NSString stringWithCString:string]];
		return;
	}
	[tempList addObject: [tempPhone categoryList]];
	[phoneList addObject: tempPhone];
	phones++;

	tempPhone = [mainPhoneList binarySearchPhone:[[[phone2 cellAtIndex:0] stringValue] cString] index:&dummy];
	if (!tempPhone)
	{
		sprintf(string, "Unknown phone: \"%s\"", [[[phone2 cellAtIndex:0] stringValue] cString]);
		[ruleOutput setStringValue:[NSString stringWithCString:string]];
		return;
	}
	[tempList addObject: [tempPhone categoryList]];
	[phoneList addObject: tempPhone];
	phones++;

	if ([[[phone3 cellAtIndex:0] stringValue] length])
	{
		tempPhone = [mainPhoneList binarySearchPhone:[[[phone3 cellAtIndex:0] stringValue] cString] index:&dummy];
		if (!tempPhone)
		{
			sprintf(string, "Unknown phone: \"%s\"", [[[phone3 cellAtIndex:0] stringValue] cString]);
			[ruleOutput setStringValue:[NSString stringWithCString:string]];
			return;
		}
		[tempPhone categoryList];
		[tempList addObject:tempPhone];
		[phoneList addObject: tempPhone];

		phones++;
	}

	if ([[[phone4 cellAtIndex:0] stringValue] length])
	{
		tempPhone = [mainPhoneList binarySearchPhone:[[[phone4 cellAtIndex:0] stringValue] cString] index:&dummy];
		if (!tempPhone)
		{
			sprintf(string, "Unknown phone: \"%s\"", [[[phone4 cellAtIndex:0] stringValue] cString]);
			[ruleOutput setStringValue:[NSString stringWithCString:string]];
			return;
		}
		[tempPhone categoryList];
		[tempList addObject:tempPhone];
		[phoneList addObject: tempPhone];

		phones++;
	}

//	printf("TempList count = %d\n", [tempList count]);

	for(i = 0; i< [ruleList count]; i++)
	{
		tempRule = [ruleList objectAtIndex:i];
		if ([tempRule numberExpressions]<=[tempList count])
			if ([[ruleList objectAtIndex:i] matchRule: tempList])
			{
				bzero(string, 1024);
				[self expressionString: string forRule:i];
				[ruleOutput setStringValue:[NSString stringWithCString:string]];
				[consumedTokens setIntValue:[tempRule numberExpressions]];
				ruleSymbols[0] = [[tempRule getExpressionSymbol:0]
                                                evaluate: ruleSymbols phones: phoneList andCacheWith: cacheValue++];
				ruleSymbols[2] = [[tempRule getExpressionSymbol:2]
                                                evaluate: ruleSymbols phones: phoneList andCacheWith: cacheValue++];
				ruleSymbols[3] = [[tempRule getExpressionSymbol:3]
                                                evaluate: ruleSymbols phones: phoneList andCacheWith: cacheValue++];
				ruleSymbols[4] = [[tempRule getExpressionSymbol:4]
                                                evaluate: ruleSymbols phones: phoneList andCacheWith: cacheValue++];
				ruleSymbols[1] = [[tempRule getExpressionSymbol:1]
                                                evaluate: ruleSymbols phones: phoneList andCacheWith: cacheValue++];
				for(j = 0; j<5; j++)
				{
					[[durationOutput cellAtIndex:j] setDoubleValue:ruleSymbols[j]];
				}
				[tempList release];
				return;
			}
	}
	NSBeep();
	[ruleOutput setStringValue:@"Cannot find rule"];
	[consumedTokens setIntValue:0];
	[tempList release]; 
}

- ruleList
{
	return ruleList;
}


- (void)addParameter
{
	[ruleList makeObjectsPerform: (SEL)(@selector(addDefaultParameter))]; 
}

- (void)addMetaParameter
{
	[ruleList makeObjectsPerform: (SEL)(@selector(addDefaultMetaParameter))]; 
}

- (void)removeParameter:(int)index
{
int i;
	for (i = 0; i< [ruleList count]; i++)
		[[ruleList objectAtIndex:i] removeParameter:index]; 
}

- (void)removeMetaParameter:(int)index
{
int i;
	for (i = 0; i< [ruleList count]; i++)
		[[ruleList objectAtIndex:i] removeMetaParameter:index]; 
}

- (BOOL) isCategoryUsed: aCategory
{
	return [ruleList isCategoryUsed:aCategory];
}

- (BOOL) isEquationUsed: anEquation
{
	return [ruleList isEquationUsed:anEquation];
}
- (BOOL) isTransitionUsed: aTransition
{
	return [ruleList isTransitionUsed: aTransition];
}

- findEquation: anEquation andPutIn: aList
{
	return [ruleList findEquation:anEquation andPutIn:  aList]; 
}

- findTemplate: aTemplate andPutIn: aList
{
	return [ruleList findTemplate:aTemplate andPutIn:  aList]; 
}

- (void)cut:(id)sender
{
	printf("RuleManager: cut\n");
}

NSString *ruleString = @"Rule";

- (void)copy:(id)sender
{
NSPasteboard *myPasteboard;
NSMutableData *mdata;
NSArchiver *typed = NULL;
NSString *dataType;
int retValue, column = [ruleMatrix selectedColumn];
id tempEntry;

	myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];

	printf("RuleManager: copy  |%s|\n", [[myPasteboard name] cString]);

	mdata = [NSMutableData dataWithCapacity: 16];
	typed = [[NSArchiver alloc] initForWritingWithMutableData: mdata];

	if (column != 0)
	{
		NSBeep();
		printf("Nothing selected\n");
		return;
	}

	tempEntry = [ruleList objectAtIndex:[[ruleMatrix matrixInColumn: 0] selectedRow]];
	[tempEntry encodeWithCoder:typed];

	dataType = ruleString;
	retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];

	[myPasteboard setData: mdata forType:ruleString];

	[typed release];
}

- (void)paste:(id)sender
{
NSPasteboard *myPasteboard;
NSData *mdata;
NSArchiver *typed = NULL;
NSArray *dataTypes;
int row = [[ruleMatrix matrixInColumn: 0] selectedRow];
id temp;

	myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];
	printf("RuleManager: paste  changeCount = %d  |%s|\n", [myPasteboard changeCount], [[myPasteboard name] cString]);

	dataTypes = [myPasteboard types];
	if ([[dataTypes objectAtIndex: 0] isEqual: ruleString])
	{
		NSBeep();
		return;
	}

	mdata = [myPasteboard dataForType: ruleString];
	typed = [[NSUnarchiver alloc] initForReadingWithData: mdata];
	temp = [[Rule alloc] init];
	[temp initWithCoder:typed];
	[typed release];

	if (row == (-1))
		[ruleList insertObject: temp atIndex: [ruleList count]-1];
	else
		[ruleList insertObject: temp atIndex: row+1];

	[ruleMatrix loadColumnZero];
}

- (void)readDegasFileFormat:(FILE *)fp
{
	[ruleList readDegasFileFormat:(FILE *) fp]; 
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
int i;

	matchLists = [[MonetList alloc] initWithCapacity: 4];
	for (i = 0; i<4; i++)
	{
		[matchLists addObject: [[PhoneList alloc] init]];
	}

	boolParser = [[BooleanParser alloc] init];

	ruleList = [[aDecoder decodeObject] retain];

	[self applicationDidFinishLaunching: nil];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:ruleList];
}


- (void)readRulesFrom:(NSArchiver *)stream
{
	[ruleList release];

	cacheValue = 1;

	ruleList = [[stream decodeObject] retain]; 
}

#ifdef NeXT
- _readRulesFrom:(NXTypedStream *)stream
{
        [ruleList release];

        cacheValue = 1;

        ruleList = NXReadObject(stream);

        return self;
}
#endif

- (void)writeRulesTo:(NSArchiver *)stream
{

	[stream encodeObject:ruleList]; 
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    id temp;
int index = 0;

	temp = [controller inspector];
	index = [[ruleMatrix matrixInColumn:0] selectedRow];
	if (temp)
	{
		if ( index == (-1))
			[temp cleanInspectorWindow];
		else
			[temp inspectRule:[ruleList objectAtIndex:index]];
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
