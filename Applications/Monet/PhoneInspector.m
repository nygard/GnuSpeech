
#import "PhoneInspector.h"
#import "Inspector.h"
#import "NiftyMatrix.h"
#import "NiftyMatrixCat.h"
#import "NiftyMatrixCell.h"
#import "MyController.h"


@implementation PhoneInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSRect scrollRect, matrixRect;
NSSize interCellSpacing = {0.0, 0.0};
NSSize cellSize;

	[browser setTarget:self];
	[browser setAction:(SEL)(@selector(browserHit:))];
	[browser setDoubleAction:(SEL)(@selector(browserDoubleHit:))];

	/* set the niftyMatrixScrollView's attributes */
	[niftyMatrixScrollView setBorderType:NSBezelBorder];
	[niftyMatrixScrollView setHasVerticalScroller:YES];
	[niftyMatrixScrollView setHasHorizontalScroller:NO];

	/* get the niftyMatrixScrollView's dimensions */
	scrollRect = [niftyMatrixScrollView frame];

	/* determine the matrix bounds */
	(matrixRect.size) = [NSScrollView contentSizeForFrameSize:(scrollRect.size) hasHorizontalScroller:NO hasVerticalScroller:NO borderType:NSBezelBorder];

	/* prepare a matrix to go inside our niftyMatrixScrollView */
	niftyMatrix = [[NiftyMatrix allocWithZone:[self zone]] initWithFrame:matrixRect mode:NSRadioModeMatrix cellClass:[NiftyMatrixCell class] numberOfRows:0 numberOfColumns:1];

	/* we don't want any space between the matrix's cells  */
	[niftyMatrix setIntercellSpacing:interCellSpacing];

	/* resize the matrix's cells and size the matrix to contain them */
	cellSize = [niftyMatrix cellSize];
	cellSize.width = NSWidth(matrixRect) + 0.1;
	[niftyMatrix setCellSize:cellSize];
	[niftyMatrix sizeToCells];
	[niftyMatrix setAutosizesCells:YES];

	/*
	 * when the user clicks in the matrix and then drags the mouse out of niftyMatrixScrollView's contentView,
	 * we want the matrix to scroll 
	 */

	[niftyMatrix setAutoscroll:YES];

	/* stick the matrix in our niftyMatrixScrollView */
	[niftyMatrixScrollView setDocumentView:niftyMatrix];

	/* set things up so that the matrix will resize properly */
	[[niftyMatrix superview] setAutoresizesSubviews:YES];
	[niftyMatrix setAutoresizingMask:NSViewWidthSizable];

	/* set the matrix's single-click actions */
	[niftyMatrix setTarget:self];
	[niftyMatrix setAction:@selector(itemsChanged:)];
	//[niftyMatrix allowEmptySel:YES];

	[niftyMatrix insertCellWithStringValue:"Phone"];

	[niftyMatrix grayAllCells];
	[niftyMatrix display];
}

- init
{

	currentPhone = nil;
	currentBrowser = 0;

	courier = [NSFont fontWithName:@"Courier" size:12];
	courierBold = [NSFont fontWithName:@"Courier-Bold" size:12];


	return self;


}

- (void)itemsChanged:sender
{
CategoryList *tempList;
CategoryNode *tempNode;
NSArray *list;
id tempCell;
id mainCategoryList;
int i;

	tempList = [currentPhone categoryList];
	mainCategoryList = NXGetNamedObject(@"mainCategoryList", NSApp);
	list = [niftyMatrix cells];
	for(i = 0 ; i<[list count]; i++)
	{
		tempCell = [list objectAtIndex:i];
		if ([tempCell toggleValue])
		{
			if (![tempList findSymbol:[[tempCell stringValue] cString]])
			{
				tempNode = [mainCategoryList findSymbol:[[tempCell stringValue] cString]];
				[tempList addObject:tempNode];
			}
		}
		else
		{
			if ((tempNode = [tempList findSymbol:[[tempCell stringValue] cString]]))
			{
				[tempList removeObject:tempNode];
			}
		}

	} 
}

- (void)inspectPhone:phone
{
	currentPhone = phone;
	[mainInspector setPopUpListView:phonePopUpListView];
	[self setUpWindow:phonePopUpList]; 
}

- (void)setUpWindow:sender
{
const char *temp;
id tempCell;
CategoryList *tempList, *mainCategoryList;
int i;

	temp = [[[sender selectedCell] title] cString];
	switch(temp[0])
	{
		case 'C':
			if(temp[1] == 'o')
			{
				[phonePopUpList setTitle:@"Comment"];
				[mainInspector setGeneralView:commentView];

				[setCommentButton setTarget:self];
				[setCommentButton setAction:(SEL)(@selector(setComment:))];

				[revertCommentButton setTarget:self];
				[revertCommentButton setAction:(SEL)(@selector(revertComment:))];

				[commentText setString:[NSString stringWithCString:[currentPhone comment]]];
			}
			else
			{
				tempList = [currentPhone categoryList];
				mainCategoryList = NXGetNamedObject(@"mainCategoryList", NSApp);
				[niftyMatrix removeAllCells];

				for (i = 0; i<[tempList count]; i++)
				{
//					printf("Inserting %s\n", [[tempList objectAtIndex:i] symbol]);
					[niftyMatrix insertCellWithStringValue:[[tempList objectAtIndex:i] symbol]];
					if ([[tempList objectAtIndex:i] native])
					{
						tempCell = [niftyMatrix findCellNamed:[[tempList objectAtIndex:i] symbol]];
						[tempCell lock];
					}
				}
				[niftyMatrix ungrayAllCells];
				tempCell = [niftyMatrix findCellNamed:"phone"];
				[tempCell lock];

				for (i = 0; i<[mainCategoryList count]; i++)
				{
					temp = [[mainCategoryList objectAtIndex:i] symbol];
					if ( ![niftyMatrix findCellNamed:temp])
					{
						[niftyMatrix insertCellWithStringValue:temp];
						tempCell = [niftyMatrix findCellNamed:temp];
						[tempCell setToggleValue:0];
					}
				}

				[niftyMatrix display];
	
				[mainInspector setGeneralView:niftyMatrixBox];
				[phonePopUpList setTitle:@"Categories"];
			}
			break;
		case 'P':
			currentBrowser = 1;
			currentMainList = NXGetNamedObject(@"mainParameterList", NSApp);
			[browser setTitle:@"Parameter" ofColumn:0];
			[mainInspector setGeneralView:browserBox];
			[phonePopUpList setTitle:@"Parameter Targets"];
			[browser loadColumnZero];
			break;
		case 'M':
			currentBrowser = 2;
			currentMainList = NXGetNamedObject(@"mainMetaParameterList", NSApp);
			[browser setTitle:@"Meta Parameter" ofColumn:0];
			[mainInspector setGeneralView:browserBox];
			[phonePopUpList setTitle:@"Meta Parameter Targets"];
			[browser loadColumnZero];
			break;
		case 'S':
			currentBrowser = 3;
			currentMainList = NXGetNamedObject(@"mainSymbolList", NSApp);
			[browser setTitle:@"Symbol" ofColumn:0];
			[mainInspector setGeneralView:browserBox];
			[phonePopUpList setTitle:@"Symbols"];
			[browser loadColumnZero];
			break;
	}
	[minText setStringValue:@"--"];
	[maxText setStringValue:@"--"];
	[defText setStringValue:@"--"]; 
}

- (void)beginEditting
{
const char *temp;

	temp = [[[phonePopUpList selectedCell] title] cString];
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
id tempParameter;
id tempList;

	tempParameter = [currentMainList objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
	switch(currentBrowser)
	{
		case 1: [currentPhone parameterList]; tempList = currentPhone;
			[[valueField cellAtIndex:0] setDoubleValue:[[tempList objectAtIndex:[[browser matrixInColumn:0] selectedRow]] value]];
			[valueField selectTextAtIndex:0];
			break;
		case 2: [currentPhone metaParameterList]; tempList = currentPhone;
			[[valueField cellAtIndex:0] setDoubleValue:[[tempList objectAtIndex:[[browser matrixInColumn:0] selectedRow]] value]];
			[valueField selectTextAtIndex:0];
			break;
		case 3: [currentPhone symbolList]; tempList = currentPhone;
			[[valueField cellAtIndex:0] setDoubleValue:[[tempList objectAtIndex:[[browser matrixInColumn:0] selectedRow]] value]];
			[valueField selectTextAtIndex:0];
			break;
		default:
			return;
	}

	if ((currentBrowser == 1) || (currentBrowser == 2) || (currentBrowser == 3))
	{
		[minText setDoubleValue: (double)[tempParameter minimumValue]];
		[maxText setDoubleValue: (double)[tempParameter maximumValue]];
		[defText setDoubleValue:[tempParameter defaultValue]];
	} 
}

- (void)browserDoubleHit:sender
{
id tempParameter;
double tempDefault;

	tempParameter = [currentMainList objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
	switch(currentBrowser)
	{
		case 1:
			tempDefault = [tempParameter defaultValue];
			tempParameter = [[currentPhone parameterList] objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
			[tempParameter setValue:tempDefault];
			[tempParameter setDefault:YES];
			[browser loadColumnZero];
			break;
		case 2:
			tempDefault = [tempParameter defaultValue];
			tempParameter = [[currentPhone metaParameterList] objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
			[tempParameter setValue:tempDefault];
			[tempParameter setDefault:YES];
			[browser loadColumnZero];
		case 3:
			tempDefault = [tempParameter defaultValue];
			tempParameter = [[currentPhone symbolList] objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
			[tempParameter setValue:tempDefault];
			[tempParameter setDefault:YES];
			[browser loadColumnZero];
		default:
			break;
	} 
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
	switch(currentBrowser)
	{
		case 1: 
			return [[currentPhone parameterList] count];
		case 2:
			return [[currentPhone metaParameterList] count];
		case 3:
			return [[currentPhone symbolList] count];
		default:
			return 0;
	}
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
id list;
char string[256], string2[32];
int i;
	switch(currentBrowser)
	{
		case 1: list = [currentPhone parameterList]; 
			break;
		case 2:	list = [currentPhone metaParameterList];
			break;
		case 3: list = [currentPhone symbolList];
			break;
		default:
			return;
	}

	bzero(string, 256);
	bzero(string2, 32);

	sprintf(string2, "%10.2f", [[list objectAtIndex:row] value]);
	strcpy(string, [[currentMainList objectAtIndex:row] symbol]);
	for(i = strlen(string); i<20; i++)
		string[i] = ' ';

	strcat(string, string2);

        [cell setStringValue:[NSString stringWithCString:string]];
	if ([[list objectAtIndex:row] isDefault])
		[cell setFont:courierBold];
	else
		[cell setFont:courier];
        [cell setLeaf:YES];
}

- (void)setComment:sender
{
	[currentPhone setComment: [[commentText string] cString]];
}

- (void)revertComment:sender
{
	[commentText setString:[NSString stringWithCString:[currentPhone comment]]]; 
}

- (void)setValueNextText:sender
{
int row;
id temp, tempList;

	row = [[browser matrixInColumn:0] selectedRow];
	switch(currentBrowser)
	{
		case 1: tempList = [currentPhone parameterList];
			temp = [tempList objectAtIndex:row];
			[temp setValue:[[valueField cellAtIndex:0] doubleValue]];
			if ([[valueField cellAtIndex:0] doubleValue] == [[currentMainList objectAtIndex:row] defaultValue])
				[temp setDefault:YES];
			else
				[temp setDefault:NO];
			break;

		case 2: tempList = [currentPhone metaParameterList];
			temp = [tempList objectAtIndex:row];
			[temp setValue:[[valueField cellAtIndex:0] doubleValue]];
			if ([[valueField cellAtIndex:0] doubleValue] == [[currentMainList objectAtIndex:row] defaultValue])
				[temp setDefault:YES];
			else
				[temp setDefault:NO];
			break;

		case 3: tempList = [currentPhone symbolList];
			temp = [tempList objectAtIndex:row];
			[temp setValue:[[valueField cellAtIndex:0] doubleValue]];
			if ([[valueField cellAtIndex:0] doubleValue] == [[currentMainList objectAtIndex:row] defaultValue])
				[temp setDefault:YES];
			else
				[temp setDefault:NO];
			break;

		default:
			break;
	}

	[browser loadColumnZero];
	row++;
	if (row>=[[[browser matrixInColumn:0] cells] count]) row = 0;
	[[browser matrixInColumn:0] selectCellAtRow:row column:0];

	[self browserHit:browser]; 
}


@end
