#import "PointInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "Inspector.h"
#import "FormulaExpression.h"
#import "MonetList.h"
#import "Point.h"
#import "ProtoEquation.h"
#import "PrototypeManager.h"
#import "ProtoTemplate.h"
#import "TransitionView.h"

@implementation PointInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    [expressionBrowser setTarget:self];
    [expressionBrowser setAction:@selector(browserHit:)];
    [expressionBrowser setDoubleAction:@selector(browserDoubleHit:)];
}

- (void)inspectPoint:(GSMPoint *)point;
{
    /* Hack for Single Point Inspections */
    if ([point isKindOfClass:[GSMPoint class]]) {
        currentPoint = point;
        [mainInspector setPopUpListView:popUpListView];
        [self setUpWindow:popUpList];
    } else if ([point count] == 1) {
        currentPoint = [point objectAtIndex:0];
        [mainInspector setPopUpListView:popUpListView];
        [self setUpWindow:popUpList];
    } else {
        [mainInspector cleanInspectorWindow];
        [mainInspector setGeneralView:multipleListView];
    }
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    NSString *str;
    PrototypeManager *tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
    id tempCell;
    int index1, index2;

    str = [[sender selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
#if 0
        [mainInspector setGeneralView: commentView];

        [setCommentButton setTarget:self];
        [setCommentButton setAction:@selector(setComment:)];

        [revertCommentButton setTarget:self];
        [revertCommentButton setAction:@selector(revertComment:)];

        [commentText setText:[currentParameter comment]];
#endif
    } else if ([str hasPrefix:@"G"]) {
        NSString *path;

        [mainInspector setGeneralView:valueBox];
        [expressionBrowser loadColumnZero];

        [valueField setDoubleValue:[currentPoint value]];
        switch ([currentPoint type]) {
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

        tempCell = [currentPoint expression];
        if (tempCell) {
            [currentTimingField setStringValue:[[tempCell expression] expressionString]];
        } else {
            [currentTimingField setStringValue:[NSString stringWithFormat:@"Fixed: %.3f ms", [currentPoint freeTime]]];
        }
        [tempProto findList:&index1 andIndex:&index2 ofEquation:tempCell];

        path = [NSString stringWithFormat:@"/%@/%@",
                         [(ProtoEquation *)[[tempProto equationList] objectAtIndex:index1] name],
                         [(ProtoEquation *)[[[tempProto equationList] objectAtIndex:index1] objectAtIndex:index2] name]];
        NSLog(@"Path = |%@|", path);
        [expressionBrowser setPath:path];
    }
}

- (void)beginEditting;
{
    NSString *str;

    str = [[popUpList selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        //[commentText selectAll:self];
    } else if ([str hasPrefix:@"D"]) {
        [valueField selectText: self];
    }
}

- (IBAction)browserHit:(id)sender;
{
    int listIndex, index;
    PrototypeManager *prototypeManager = NXGetNamedObject(@"prototypeManager", NSApp);
    ProtoEquation *temp;

    if ([sender selectedColumn] == 1) {
        listIndex = [[sender matrixInColumn:0] selectedRow];
        index = [[sender matrixInColumn:1] selectedRow];
        // TODO (2004-03-06): Fixing suspected bug in original code
        temp = [prototypeManager findEquation:listIndex andIndex:index];
        [currentPoint setExpression:temp];

        [currentTimingField setStringValue:[[temp expression] expressionString]];

        [NXGetNamedObject(@"transitionBuilder", NSApp) display];
        [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];

    }
}

- (IBAction)browserDoubleHit:(id)sender;
{
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    int index;

    if (column == 0)
        return [[NXGetNamedObject(@"prototypeManager", NSApp) equationList] count];

    index = [[sender matrixInColumn:0] selectedRow];
    return [[[NXGetNamedObject(@"prototypeManager", NSApp) equationList] objectAtIndex:index] count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    PrototypeManager *temp;
    id list, tempCell;
    int index;

    temp = NXGetNamedObject(@"prototypeManager", NSApp);
    index = [[sender matrixInColumn:0] selectedRow];
    [cell setLoaded:YES];

    list = [temp equationList];
    if (column == 0) {
        [cell setStringValue:[(ProtoEquation *)[list objectAtIndex:row] name]];
        [cell setLeaf:NO];
    } else {
        tempCell = [[list objectAtIndex:index] objectAtIndex:row];
        [cell setStringValue:[(ProtoEquation *)tempCell name]];

//        if ([[tempCell expression] maxPhone] >[currentPoint type])
//            [cell setEnabled:NO];
//        else
//            [cell setEnabled:YES];
        [cell setLeaf:YES];
    }
}

- (IBAction)setValue:(id)sender;
{
    TransitionView *temp = NXGetNamedObject(@"transitionBuilder", NSApp);

    [currentPoint setValue:[sender doubleValue]];
    [temp display];
    [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];
}

- (IBAction)setType1:(id)sender;
{
    TransitionView *temp = NXGetNamedObject(@"transitionBuilder", NSApp);

    [type2Button setState:0];
    [type3Button setState:0];
    [currentPoint setType:DIPHONE];
    [temp display];
    [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];
}

- (IBAction)setType2:(id)sender;
{
    TransitionView *temp = NXGetNamedObject(@"transitionBuilder", NSApp);

    [type1Button setState:0];
    [type3Button setState:0];
    [currentPoint setType:TRIPHONE];
    [temp display];
    [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];
}

- (IBAction)setType3:(id)sender;
{
    TransitionView *temp = NXGetNamedObject(@"transitionBuilder", NSApp);

    [type1Button setState:0];
    [type2Button setState:0];
    [currentPoint setType:TETRAPHONE];
    [temp display];
    [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];
}

- (IBAction)setPhantom:(id)sender;
{
    [currentPoint setPhantom:[sender state]];
}

@end
