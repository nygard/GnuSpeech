#import "RuleInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "Inspector.h"
#import "NamedList.h"
#import "Rule.h"
#import "RuleList.h"
#import "RuleManager.h"
#import "Parameter.h"
#import "ParameterList.h"
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
    [commentView retain];
    [genInfoBox retain];
    [browserView retain];
    [popUpListView retain];

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

- (void)dealloc;
{
    [commentView release];
    [genInfoBox release];
    [browserView release];
    [popUpListView release];

    [currentRule release];

    [super dealloc];
}

- (void)setCurrentRule:(Rule *)aRule;
{
    if (aRule == currentRule)
        return;

    [currentRule release];
    currentRule = [aRule retain];
}

- (void)inspectRule:(Rule *)aRule;
{
    [self setCurrentRule:aRule];
    [mainInspector setPopUpListView:popUpListView];
    [self setUpWindow:popUpList];
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    NSString *str;
    RuleManager *ruleManager;
    int tempIndex;

    str = [[sender selectedCell] title];
    NSLog(@"%s, str: %@", _cmd, str);
    if ([str hasPrefix:@"C"]) {
        [popUpList setTitle:@"Comment"];
        [mainInspector setGeneralView:commentView];

        [setCommentButton setTarget:self];
        [setCommentButton setAction:@selector(setComment:)];

        [revertCommentButton setTarget:self];
        [revertCommentButton setAction:@selector(revertComment:)];

        if ([currentRule comment] != nil)
            [commentText setString:[currentRule comment]];
        else
            [commentText setString:@""];
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


- (IBAction)browserHit:(id)sender;
{
    PrototypeManager *prototypeManager = NXGetNamedObject(@"prototypeManager", NSApp);
    id tempCell;
    int index, index1, index2;
    NSString *str;

    index = [[sender matrixInColumn:0] selectedRow];
    switch (currentBrowser) {
      case 1:
          tempCell = [[currentRule symbols] objectAtIndex:index];
          [prototypeManager findList:&index1 andIndex:&index2 ofEquation:tempCell];
          str = [NSString stringWithFormat:@"/%@/%@",
                          [(NamedList *)[[prototypeManager equationList] objectAtIndex:index1] name],
                          [(ProtoEquation *)[[[prototypeManager equationList] objectAtIndex:index1] objectAtIndex:index2] name]];
          NSLog(@"Path = |%@|\n", str);
          [selectionBrowser setPath:str];
          break;

      case 2:
          tempCell = [[currentRule parameterList] objectAtIndex:index];
          [prototypeManager findList:&index1 andIndex:&index2 ofTransition:tempCell];
          str = [NSString stringWithFormat:@"/%@/%@",
                          [(NamedList *)[[prototypeManager transitionList] objectAtIndex:index1] name],
                          [(ProtoEquation *)[[[prototypeManager transitionList] objectAtIndex:index1] objectAtIndex:index2] name]];
          NSLog(@"Path = |%@|\n", str);
          [selectionBrowser setPath:str];
          break;

      case 3:
          tempCell = [[currentRule metaParameterList] objectAtIndex:index];
          [prototypeManager findList:&index1 andIndex:&index2 ofTransition:tempCell];
          str = [NSString stringWithFormat:@"/%@/%@",
                          [(NamedList *)[[prototypeManager transitionList] objectAtIndex:index1] name],
                          [(ProtoEquation *)[[[prototypeManager transitionList] objectAtIndex:index1] objectAtIndex:index2] name]];
          [selectionBrowser setPath:str];
          break;

      case 4:
          tempCell = [currentRule getSpecialProfile:index];
          [prototypeManager findList:&index1 andIndex:&index2 ofSpecial:tempCell];
          str = [NSString stringWithFormat:@"/%@/%@",
                          [(NamedList *)[[prototypeManager specialList] objectAtIndex:index1] name],
                          [(ProtoEquation *)[[[prototypeManager specialList] objectAtIndex:index1] objectAtIndex:index2] name]];
          [selectionBrowser setPath:str];
          break;
    }
}

- (IBAction)browserDoubleHit:(id)sender;
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

- (IBAction)selectionBrowserHit:(id)sender;
{
    int listIndex, index, parameterIndex, i;
    PrototypeManager *prototypeManager = NXGetNamedObject(@"prototypeManager", NSApp);
    id temp;
    NSArray *selectedList, *cellList;

    if ([sender selectedColumn] == 1) {
        listIndex = [[sender matrixInColumn:0] selectedRow];
        index = [[sender matrixInColumn:1] selectedRow];
        parameterIndex = [[mainBrowser matrixInColumn:0] selectedRow];
        switch (currentBrowser) {
          case 1:
              temp = [prototypeManager findEquation:listIndex andIndex:index];
              [[currentRule symbols] replaceObjectAtIndex:parameterIndex withObject:temp];
              /* Wait for setup */
              break;
          case 2:
              selectedList = [mainBrowser selectedCells];
              temp = [prototypeManager findTransition:listIndex andIndex:index];
              cellList = [[mainBrowser matrixInColumn:0] cells];

              for (i = 0; i < [selectedList count]; i++) {
                  [[currentRule parameterList] replaceObjectAtIndex:[cellList indexOfObject:[selectedList objectAtIndex:i]]
                                               withObject:temp];
                  //NSLog(@"%d Index in list %d", i, [cellList indexOfObject:[selectedList objectAtIndex:i]]);
              }
              break;
          case 3:
              temp = [prototypeManager findTransition:listIndex andIndex:index];
              [[currentRule metaParameterList] replaceObjectAtIndex:parameterIndex withObject:temp];
              break;
          case 4:
              temp = [prototypeManager findSpecial:listIndex andIndex:index];
              [currentRule setSpecialProfile:parameterIndex to:temp];
              break;
        }
    }
}

- (IBAction)selectionBrowserDoubleHit:(id)sender;
{
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    int index;
    NSLog(@"%s, column: %d", _cmd, column);

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
          {
              ParameterList *mainParameterList;

              mainParameterList = NXGetNamedObject(@"mainParameterList", NSApp);
              [cell setStringValue:[[mainParameterList objectAtIndex:row] symbol]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              break;
          }
          case 3:
          {
              ParameterList *mainMetaParameterList;

              mainMetaParameterList = NXGetNamedObject(@"mainMetaParameterList", NSApp);
              [cell setStringValue:[[mainMetaParameterList objectAtIndex:row] symbol]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              break;
          }
        }
    } else {
        PrototypeManager *prototypeManager;

        prototypeManager = NXGetNamedObject(@"prototypeManager", NSApp);
        index = [[sender matrixInColumn:0] selectedRow];
        [cell setLoaded:YES];

        switch (currentBrowser) {
          case 1:
              list = [prototypeManager equationList];
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
              list = [prototypeManager transitionList];
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
              list = [prototypeManager transitionList];
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
              list = [prototypeManager specialList];
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

- (IBAction)setComment:(id)sender;
{
    NSString *newComment;

    newComment = [[commentText string] copy]; // Need to copy, becuase it's mutable and owned by the NSTextView
    [currentRule setComment:newComment];
    [newComment release];
}

- (IBAction)revertComment:(id)sender;
{
    if ([currentRule comment] != nil)
        [commentText setString:[currentRule comment]];
    else
        [commentText setString:@""];
}

- (IBAction)moveRule:(id)sender;
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
