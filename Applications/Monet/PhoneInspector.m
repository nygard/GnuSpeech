#import "PhoneInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "CategoryNode.h"
#import "CategoryList.h"
#import "Inspector.h"
#import "NiftyMatrix.h"
#import "NiftyMatrixCat.h"
#import "NiftyMatrixCell.h"
#import "Parameter.h"
#import "Phone.h"
#import "Target.h" // Or Point.h
#import "TargetList.h"

@implementation PhoneInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSRect scrollRect, matrixRect;
    NSSize interCellSpacing = {0.0, 0.0};
    NSSize cellSize;

    [commentView retain];
    [niftyMatrixBox retain];
    [browserBox retain];
    [phonePopUpListView retain];

    [browser setTarget:self];
    [browser setAction:@selector(browserHit:)];
    [browser setDoubleAction:@selector(browserDoubleHit:)];

    /* set the niftyMatrixScrollView's attributes */
    [niftyMatrixScrollView setBorderType:NSBezelBorder];
    [niftyMatrixScrollView setHasVerticalScroller:YES];
    [niftyMatrixScrollView setHasHorizontalScroller:NO];

    /* get the niftyMatrixScrollView's dimensions */
    scrollRect = [niftyMatrixScrollView frame];

    /* determine the matrix bounds */
    matrixRect.origin = NSZeroPoint;
    matrixRect.size = [NSScrollView contentSizeForFrameSize:(scrollRect.size) hasHorizontalScroller:NO hasVerticalScroller:NO borderType:NSBezelBorder];
    NSLog(@"matrixRect: %@", NSStringFromRect(matrixRect));

    /* prepare a matrix to go inside our niftyMatrixScrollView */
    niftyMatrix = [[NiftyMatrix alloc] initWithFrame:matrixRect mode:NSRadioModeMatrix cellClass:[NiftyMatrixCell class] numberOfRows:0 numberOfColumns:1];

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

    [niftyMatrix insertCellWithStringValue:@"Phone"];

    [niftyMatrix grayAllCells];
    [niftyMatrix display];
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    currentPhone = nil;
    currentBrowser = 0;

    courierFont = [[NSFont fontWithName:@"Courier" size:12] retain];
    courierBoldFont = [[NSFont fontWithName:@"Courier-Bold" size:12] retain];

    return self;
}

- (void)dealloc;
{
    [commentView release];
    [niftyMatrixBox release];
    [browserBox release];
    [phonePopUpListView release];

    [currentPhone release];

    [courierFont release];
    [courierBoldFont release];

    [super dealloc];
}

- (void)setCurrentPhone:(Phone *)aPhone;
{
    if (aPhone == currentPhone)
        return;

    [currentPhone release];
    currentPhone = [aPhone retain];
}

- (void)inspectPhone:(Phone *)aPhone;
{
    [self setCurrentPhone:aPhone];
    [mainInspector setPopUpListView:phonePopUpListView];
    [self setUpWindow:phonePopUpList];
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    NSString *str;
    id tempCell;
    CategoryList *tempList, *mainCategoryList;
    int i;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    str = [[sender selectedCell] title];
    NSLog(@"str: %@", str);

    if ([str hasPrefix:@"Co"]) {
        [phonePopUpList setTitle:@"Comment"];
        [mainInspector setGeneralView:commentView];

        [setCommentButton setTarget:self];
        [setCommentButton setAction:@selector(setComment:)];

        [revertCommentButton setTarget:self];
        [revertCommentButton setAction:@selector(revertComment:)];

        if ([currentPhone comment] != nil)
            [commentText setString:[currentPhone comment]];
        else
            [commentText setString:@""];
    } else if ([str hasPrefix:@"C"]) {
        tempList = [currentPhone categoryList];
        mainCategoryList = NXGetNamedObject(@"mainCategoryList", NSApp);
        [niftyMatrix removeAllCells];

        for (i = 0; i < [tempList count]; i++) {
            //NSLog(@"Inserting %@", [[tempList objectAtIndex:i] symbol]);
            [niftyMatrix insertCellWithStringValue:[[tempList objectAtIndex:i] symbol]];
            if ([[tempList objectAtIndex:i] isNative]) {
                tempCell = [niftyMatrix findCellNamed:[[tempList objectAtIndex:i] symbol]];
                [tempCell lock];
            }
        }
        [niftyMatrix ungrayAllCells];
        tempCell = [niftyMatrix findCellNamed:@"phone"];
        [tempCell lock];

        for (i = 0; i < [mainCategoryList count]; i++) {
            str = [[mainCategoryList objectAtIndex:i] symbol];
            if ( ![niftyMatrix findCellNamed:str]) {
                [niftyMatrix insertCellWithStringValue:str];
                tempCell = [niftyMatrix findCellNamed:str];
                [tempCell setToggleValue:0];
            }
        }

        [niftyMatrix display];

        [mainInspector setGeneralView:niftyMatrixBox];
        [phonePopUpList setTitle:@"Categories"];
    } else if ([str hasPrefix:@"P"]) {
        currentBrowser = 1;
        currentMainList = NXGetNamedObject(@"mainParameterList", NSApp);
        [browser setTitle:@"Parameter" ofColumn:0];
        [mainInspector setGeneralView:browserBox];
        [phonePopUpList setTitle:@"Parameter Targets"];
        [browser loadColumnZero];
    } else if ([str hasPrefix:@"M"]) {
        currentBrowser = 2;
        currentMainList = NXGetNamedObject(@"mainMetaParameterList", NSApp);
        [browser setTitle:@"Meta Parameter" ofColumn:0];
        [mainInspector setGeneralView:browserBox];
        [phonePopUpList setTitle:@"Meta Parameter Targets"];
        [browser loadColumnZero];
    } else if ([str hasPrefix:@"S"]) {
        currentBrowser = 3;
        currentMainList = NXGetNamedObject(@"mainSymbolList", NSApp);
        [browser setTitle:@"Symbol" ofColumn:0];
        [mainInspector setGeneralView:browserBox];
        [phonePopUpList setTitle:@"Symbols"];
        [browser loadColumnZero];
    }

    [minText setStringValue:@"--"];
    [maxText setStringValue:@"--"];
    [defText setStringValue:@"--"];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (void)beginEditting;
{
    NSString *str;

    str = [[phonePopUpList selectedCell] title];
    if ([str hasPrefix:@"Co"]) {
        [commentText selectAll:self];
    } else if ([str hasPrefix:@"C"]) {
    } else if ([str hasPrefix:@"P"]) {
    } else if ([str hasPrefix:@"M"]) {
    } else if ([str hasPrefix:@"S"]) {
    }
}

- (IBAction)browserHit:(id)sender;
{
    id tempParameter;
    id tempList;
    double value;

    tempParameter = [currentMainList objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
    switch (currentBrowser) {
      case 1:
          [currentPhone parameterList];
          tempList = currentPhone;
          value = [(Target *)[tempList objectAtIndex:[[browser matrixInColumn:0] selectedRow]] value];
          [[valueField cellAtIndex:0] setDoubleValue:value];
          [valueField selectTextAtIndex:0];
          break;
      case 2:
          [currentPhone metaParameterList];
          tempList = currentPhone;
          value = [(Target *)[tempList objectAtIndex:[[browser matrixInColumn:0] selectedRow]] value];
          [[valueField cellAtIndex:0] setDoubleValue:value];
          [valueField selectTextAtIndex:0];
          break;
      case 3:
          [currentPhone symbolList];
          tempList = currentPhone;
          value = [(Target *)[tempList objectAtIndex:[[browser matrixInColumn:0] selectedRow]] value];
          [[valueField cellAtIndex:0] setDoubleValue:value];
          [valueField selectTextAtIndex:0];
          break;
      default:
          return;
    }

    if ((currentBrowser == 1) || (currentBrowser == 2) || (currentBrowser == 3)) {
        [minText setDoubleValue: (double)[tempParameter minimumValue]];
        [maxText setDoubleValue: (double)[tempParameter maximumValue]];
        [defText setDoubleValue:[tempParameter defaultValue]];
    }
}

- (IBAction)browserDoubleHit:(id)sender;
{
    id tempParameter;
    double tempDefault;

    tempParameter = [currentMainList objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
    switch (currentBrowser) {
      case 1:
          tempDefault = [tempParameter defaultValue];
          tempParameter = [[currentPhone parameterList] objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
          [tempParameter setValue:tempDefault];
          [tempParameter setIsDefault:YES];
          [browser loadColumnZero];
          break;
      case 2:
          tempDefault = [tempParameter defaultValue];
          tempParameter = [[currentPhone metaParameterList] objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
          [tempParameter setValue:tempDefault];
          [tempParameter setIsDefault:YES];
          [browser loadColumnZero];
      case 3:
          tempDefault = [tempParameter defaultValue];
          tempParameter = [[currentPhone symbolList] objectAtIndex:[[browser matrixInColumn:0] selectedRow]];
          [tempParameter setValue:tempDefault];
          [tempParameter setIsDefault:YES];
          [browser loadColumnZero];
      default:
          break;
    }
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    switch (currentBrowser) {
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

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    TargetList *list;
    NSString *str;

    switch (currentBrowser) {
      case 1:
          list = [currentPhone parameterList];
          break;
      case 2:
          list = [currentPhone metaParameterList];
          break;
      case 3:
          list = [currentPhone symbolList];
          break;
      default:
          return;
    }

    str = [NSString stringWithFormat:@"%20@ %10.2f", [[currentMainList objectAtIndex:row] symbol], [(Target *)[list objectAtIndex:row] value]];

    [cell setStringValue:str];
    if ([[list objectAtIndex:row] isDefault])
        [cell setFont:courierBoldFont];
    else
        [cell setFont:courierFont];
    [cell setLeaf:YES];
}

- (IBAction)itemsChanged:(id)sender;
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
    for (i = 0 ; i < [list count]; i++) {
        tempCell = [list objectAtIndex:i];
        if ([tempCell toggleValue]) {
            if (![tempList findSymbol:[tempCell stringValue]])  {
                tempNode = [mainCategoryList findSymbol:[tempCell stringValue]];
                [tempList addObject:tempNode];
            }
        } else {
            if ((tempNode = [tempList findSymbol:[tempCell stringValue]])) {
                [tempList removeObject:tempNode];
            }
        }
    }
}

- (IBAction)setComment:(id)sender;
{
    [currentPhone setComment:[commentText string]];
}

- (IBAction)revertComment:(id)sender;
{
    if ([currentPhone comment] != nil)
        [commentText setString:[currentPhone comment]];
    else
        [commentText setString:@""];
}

- (IBAction)setValueNextText:(id)sender;
{
    int row;
    id temp, tempList;

    row = [[browser matrixInColumn:0] selectedRow];
    switch (currentBrowser) {
      case 1:
          tempList = [currentPhone parameterList];
          temp = [tempList objectAtIndex:row];
          [temp setValue:[[valueField cellAtIndex:0] doubleValue]];
          if ([[valueField cellAtIndex:0] doubleValue] == [[currentMainList objectAtIndex:row] defaultValue])
              [temp setIsDefault:YES];
          else
              [temp setIsDefault:NO];
          break;

      case 2:
          tempList = [currentPhone metaParameterList];
          temp = [tempList objectAtIndex:row];
          [temp setValue:[[valueField cellAtIndex:0] doubleValue]];
          if ([[valueField cellAtIndex:0] doubleValue] == [[currentMainList objectAtIndex:row] defaultValue])
              [temp setIsDefault:YES];
          else
              [temp setIsDefault:NO];
          break;

      case 3:
          tempList = [currentPhone symbolList];
          temp = [tempList objectAtIndex:row];
          [temp setValue:[[valueField cellAtIndex:0] doubleValue]];
          if ([[valueField cellAtIndex:0] doubleValue] == [[currentMainList objectAtIndex:row] defaultValue])
              [temp setIsDefault:YES];
          else
              [temp setIsDefault:NO];
          break;

      default:
          break;
    }

    [browser loadColumnZero];
    row++;
    if (row >= [[[browser matrixInColumn:0] cells] count])
        row = 0;
    [[browser matrixInColumn:0] selectCellAtRow:row column:0];

    [self browserHit:browser];
}


@end
