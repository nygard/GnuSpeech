#import "RuleInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "Inspector.h"
#import "Rule.h"
#import "RuleList.h"
#import "RuleManager.h"
#import "Parameter.h"
#import "ProtoEquation.h"
#import "ProtoTemplate.h"
#import "PrototypeManager.h"
#import "SpecialView.h"
#import "TransitionView.h"

#ifdef PORTING
#import "FormulaExpression.h"
#endif

@implementation RuleInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    [mainBrowser setTarget:self];
    [mainBrowser setAction:@selector(browserHit:)];
    [mainBrowser setDoubleAction:@selector(browserDoubleHit:)];

    [selectionBrowser setTarget:self];
    [selectionBrowser setAction:@selector(selectionBrowserHit:)];
    [selectionBrowser setDoubleAction:@selector(selectionBrowserDoubleHit:)];
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    currentBrowser = 0;

    return self;
}

- (void)inspectRule:rule;
{
    currentRule = rule;
    [mainInspector setPopUpListView:popUpListView];
    [self setUpWindow:popUpList];
}

- (void)setUpWindow:(id)sender;
{
    NSString *str;
    RuleManager *ruleManager;
    int tempIndex;

    str = [[sender selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        [popUpList setTitle:@"Comment"];
        [mainInspector setGeneralView:commentView];

        [setCommentButton setTarget:self];
        [setCommentButton setAction:@selector(setComment:)];

        [revertCommentButton setTarget:self];
        [revertCommentButton setAction:@selector(revertComment:)];

        [commentText setString:[currentRule comment]];
    } else if ([str hasPrefix:@"G"]) {
        [popUpList setTitle:@"General Information"];
        [mainInspector setGeneralView:genInfoBox];

        ruleManager = NXGetNamedObject(@"ruleManager", NSApp);
        tempIndex = [[ruleManager ruleList] indexOfObject:currentRule] + 1;
        [locationTextField setIntValue:tempIndex];
        [moveToField setIntValue:tempIndex];

        [consumeText setStringValue:[NSString stringWithFormat:@"Consumes %d tokens.", [currentRule numberExpressions]]];
    } else if ([str hasPrefix:@"E"]) {
        currentBrowser = 1;
        [popUpList setTitle:@"Equations"];
        [mainInspector setGeneralView:browserView];

        [mainBrowser setAllowsMultipleSelection:NO];

        [mainBrowser loadColumnZero];
        [selectionBrowser loadColumnZero];
    } else if ([str hasPrefix:@"P"]) {
        currentBrowser = 2;
        [popUpList setTitle:@"Parameter Prototypes"];
        [mainInspector setGeneralView:browserView];

        [mainBrowser setAllowsMultipleSelection:YES];

        [mainBrowser loadColumnZero];
        [selectionBrowser loadColumnZero];
    } else if ([str hasPrefix:@"M"]) {
        currentBrowser = 3;
        [popUpList setTitle:@"Meta Parameter Prototypes"];
        [mainInspector setGeneralView:browserView];

        [mainBrowser setAllowsMultipleSelection:NO];

        [mainBrowser loadColumnZero];
        [selectionBrowser loadColumnZero];
    } else if ([str hasPrefix:@"S"]) {
        currentBrowser = 4;
        [popUpList setTitle:@"Special Prototypes"];
        [mainInspector setGeneralView:browserView];

        [mainBrowser setAllowsMultipleSelection:NO];

        [mainBrowser loadColumnZero];
        [selectionBrowser loadColumnZero];
    }
}

- (void)beginEditting;
{
    NSString *str;

    str = [[popUpList selectedCell] title];
    if ([str hasPrefix:@"Co"]) {
        [commentText selectAll:self];
    } else if ([str hasPrefix:@"C"]) {
    } else if ([str hasPrefix:@"P"]) {
    } else if ([str hasPrefix:@"M"]) {
    } else if ([str hasPrefix:@"S"]) {
    }
}


- (void)browserHit:(id)sender;
{
    PrototypeManager *tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
    id tempCell;
    int index, index1, index2;
    NSString *str;

    index = [[sender matrixInColumn:0] selectedRow];
    switch (currentBrowser) {
      case 1:
          tempCell = [[currentRule symbols] objectAtIndex:index];
          [tempProto findList:&index1 andIndex:&index2 ofEquation:tempCell];
          str = [NSString stringWithFormat:@"/%@/%@",
                          [(ProtoEquation *)[[tempProto equationList] objectAtIndex:index1] name],
                          [(ProtoEquation *)[[[tempProto equationList] objectAtIndex:index1] objectAtIndex:index2] name]];
          NSLog(@"Path = |%@|\n", str);
          [selectionBrowser setPath:str];
          break;

      case 2:
          tempCell = [[currentRule parameterList] objectAtIndex:index];
          [tempProto findList:&index1 andIndex:&index2 ofTransition:tempCell];
          str = [NSString stringWithFormat:@"/%@/%@",
                          [(ProtoEquation *)[[tempProto transitionList] objectAtIndex:index1] name],
                          [(ProtoEquation *)[[[tempProto transitionList] objectAtIndex:index1] objectAtIndex:index2] name]];
          NSLog(@"Path = |%@|\n", str);
          [selectionBrowser setPath:str];
          break;

      case 3:
          tempCell = [[currentRule metaParameterList] objectAtIndex:index];
          [tempProto findList:&index1 andIndex:&index2 ofTransition:tempCell];
          str = [NSString stringWithFormat:@"/%@/%@",
                          [(ProtoEquation *)[[tempProto transitionList] objectAtIndex:index1] name],
                          [(ProtoEquation *)[[[tempProto transitionList] objectAtIndex:index1] objectAtIndex:index2] name]];
          [selectionBrowser setPath:str];
          break;

      case 4:
          tempCell = [currentRule getSpecialProfile:index];
          [tempProto findList:&index1 andIndex:&index2 ofSpecial:tempCell];
          str = [NSString stringWithFormat:@"/%@/%@",
                          [(ProtoEquation *)[[tempProto specialList] objectAtIndex:index1] name],
                          [(ProtoEquation *)[[[tempProto specialList] objectAtIndex:index1] objectAtIndex:index2] name]];
          [selectionBrowser setPath:str];
          break;
    }
}

- (void)browserDoubleHit:(id)sender;
{
    TransitionView *transitionBuilder = NXGetNamedObject(@"transitionBuilder", NSApp);
    TransitionView *specialTransitionBuilder = NXGetNamedObject(@"specialTransitionBuilder", NSApp);
    id tempCell;
    int index;

    index = [[sender matrixInColumn:0] selectedRow];
    switch (currentBrowser) {
      case 1:
          break;

      case 2:
          tempCell = [[currentRule parameterList] objectAtIndex:index];
          [transitionBuilder setTransition:tempCell];
          [(SpecialView *)transitionBuilder showWindow:[[sender window] windowNumber]];
          break;

      case 3:
          break;

      case 4:
          tempCell = [currentRule getSpecialProfile:index];
          [specialTransitionBuilder setTransition:tempCell];
          [(SpecialView *)specialTransitionBuilder showWindow:[[sender window] windowNumber]];

          break;
    }
}

- (void)selectionBrowserHit:(id)sender;
{
    int listIndex, index, parameterIndex, i;
    PrototypeManager *tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
    id temp;
    NSArray *selectedList, *cellList;

    if ([sender selectedColumn] == 1) {
        listIndex = [[sender matrixInColumn:0] selectedRow];
        index = [[sender matrixInColumn:1] selectedRow];
        parameterIndex = [[mainBrowser matrixInColumn:0] selectedRow];
        switch (currentBrowser) {
          case 1:
              temp = [tempProto findEquation:listIndex andIndex:index];
              [[currentRule symbols] replaceObjectAtIndex:parameterIndex withObject:temp];
              /* Wait for setup */
              break;
          case 2:
              selectedList = [mainBrowser selectedCells];
              temp = [tempProto findTransition:listIndex andIndex:index];
              cellList = [[mainBrowser matrixInColumn:0] cells];

              for (i = 0; i < [selectedList count]; i++) {
                  [[currentRule parameterList] replaceObjectAtIndex:[cellList indexOfObject:[selectedList objectAtIndex:i]]
                                               withObject:temp];
                  //NSLog(@"%d Index in list %d", i, [cellList indexOfObject:[selectedList objectAtIndex:i]]);
              }
              break;
          case 3:
              temp = [tempProto findTransition:listIndex andIndex:index];
              [[currentRule metaParameterList] replaceObjectAtIndex:parameterIndex withObject:temp];
              break;
          case 4:
              temp = [tempProto findSpecial:listIndex andIndex:index];
              [currentRule setSpecialProfile:parameterIndex to:temp];
              break;
        }
    }
}

- (void)selectionBrowserDoubleHit:(id)sender;
{
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    int index;

    if (sender == mainBrowser) {
        switch (currentBrowser) {
          case 1: /* Equations */
              return 5;
          case 2: /* parameters and their special profiles */
          case 4:
              return [NXGetNamedObject(@"mainParameterList", NSApp) count];
          case 3:
              return [NXGetNamedObject(@"mainMetaParameterList", NSApp) count];
              break;
        }
    } else {
        switch (currentBrowser) {
          case 1:
              if (column == 0)
                  return [[NXGetNamedObject(@"prototypeManager", NSApp) equationList] count];
              else {
                  index = [[sender matrixInColumn:0] selectedRow];
                  return [[[NXGetNamedObject(@"prototypeManager", NSApp) equationList] objectAtIndex:index] count];
              }
              break;
          case 2:
          case 3:
              if (column == 0)
                  return [[NXGetNamedObject(@"prototypeManager", NSApp) transitionList] count];
              else {
                  index = [[sender matrixInColumn:0] selectedRow];
                  return [[[NXGetNamedObject(@"prototypeManager", NSApp) transitionList] objectAtIndex:index] count];
              }
              break;
          case 4:
              if (column == 0)
                  return [[NXGetNamedObject(@"prototypeManager", NSApp) specialList] count];
              else {
                  index = [[sender matrixInColumn:0] selectedRow];
                  return [[[NXGetNamedObject(@"prototypeManager", NSApp) specialList] objectAtIndex:index] count];
              }
        }
    }

    return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    PrototypeManager *temp;
    id list, tempCell;
    int index;

    if (sender == mainBrowser) {
        switch (currentBrowser) {
          case 1: /* Equations */
              switch (row) {
                case 0:
                    [cell setStringValue:@"Rule Duration"];
                    break;
                case 1:
                    [cell setStringValue:@"Beat"];
                    break;
                case 2:
                    [cell setStringValue:@"Mark 1"];
                    break;
                case 3:
                    [cell setStringValue:@"Mark 2"];
                    if ([currentRule numberExpressions] < 3)
                        [cell setEnabled:NO];
                    else
                        [cell setEnabled:YES];
                    break;
                case 4:
                    [cell setStringValue:@"Mark 3"];
                    if ([currentRule numberExpressions] < 4)
                        [cell setEnabled:NO];
                    else
                        [cell setEnabled:YES];
                    break;
              }
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              break;
          case 4:
          case 2:
              temp = NXGetNamedObject(@"mainParameterList", NSApp);
              [cell setStringValue:[[temp objectAtIndex:row] symbol]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              break;
          case 3:
              temp = NXGetNamedObject(@"mainMetaParameterList", NSApp);
              [cell setStringValue:[[temp objectAtIndex:row] symbol]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              break;
        }
    } else {
        temp = NXGetNamedObject(@"prototypeManager", NSApp);
        index = [[sender matrixInColumn:0] selectedRow];
        [cell setLoaded:YES];

        switch (currentBrowser) {
          case 1:
              list = [temp equationList];
              if (column == 0) {
                  [cell setStringValue:[(ProtoTemplate *)[list objectAtIndex:row] name]];
                  [cell setLeaf:NO];
              } else {
                  tempCell = [[list objectAtIndex:index] objectAtIndex:row];
                  [cell setStringValue:[(ProtoTemplate *)tempCell name]];

//                  if ([[tempCell expression] maxPhone] >= [currentRule numberExpressions])
//                      [cell setEnabled:NO];
//                  else
//                      [cell setEnabled:YES];

                  [cell setLeaf:YES];
              }
              break;
          case 2:
              list = [temp transitionList];
              if (column == 0) {
                  [cell setStringValue:[(ProtoTemplate *)[list objectAtIndex:row] name]];
                  [cell setLeaf:NO];
              } else {
                  tempCell = [[list objectAtIndex:index] objectAtIndex:row];

                  [cell setStringValue:[(ProtoTemplate *)tempCell name]];
                  [cell setLeaf:YES];
                  if ([currentRule numberExpressions] != [(ProtoTemplate *)tempCell type])
                      [cell setEnabled:NO];
                  else
                      [cell setEnabled:YES];
              }
              break;
          case 3:
              list = [temp transitionList];
              if (column == 0) {
                  [cell setStringValue:[(ProtoTemplate *)[list objectAtIndex:row] name]];
                  [cell setLeaf:NO];
              } else {
                  tempCell = [[list objectAtIndex:index] objectAtIndex:row];

                  [cell setStringValue:[(ProtoTemplate *)tempCell name]];
                  [cell setLeaf:YES];
                  if ([currentRule numberExpressions] != [(ProtoTemplate *)tempCell type])
                      [cell setEnabled:NO];
                  else
                      [cell setEnabled:YES];
              }
              break;

          case 4:
              list = [temp specialList];
              if (column == 0) {
                  [cell setStringValue:[(ProtoTemplate *)[list objectAtIndex:row] name]];
                  [cell setLeaf:NO];
              } else {
                  tempCell = [[list objectAtIndex:index] objectAtIndex:row];

                  [cell setStringValue:[(ProtoTemplate *)tempCell name]];
                  [cell setLeaf:YES];
              }
              break;
        }
    }
}

- (void)setComment:(id)sender;
{
    [currentRule setComment:[commentText string]];
}

- (void)revertComment:(id)sender;
{
    [commentText setString:[currentRule comment]];
}

- (void)moveRule:(id)sender;
{
    RuleManager *ruleManager;
    RuleList *ruleList;
    int location = [moveToField intValue] - 1;

    ruleManager = NXGetNamedObject(@"ruleManager", NSApp);

    ruleList = [ruleManager ruleList];

    if ((location < 0) || (location >= [ruleList count]-1)) {
        NSBeep();
        [moveToField selectText:self];
        return;
    }

    [ruleList removeObject:currentRule];
    [ruleList insertObject:currentRule atIndex: location];
    [ruleManager updateRuleDisplay];
}

@end
