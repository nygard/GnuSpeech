#import "PrototypeManager.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "NSString-Extensions.h"

#import "AppController.h"
#import "DelegateResponder.h"
#import "FormulaExpression.h"
#import "GSXMLFunctions.h"
#import "Inspector.h"
#import "MonetList.h"
#import "NamedList.h"
#import "MMEquation.h"
#import "ProtoTemplate.h"
#import "RuleManager.h"
#import "TransitionView.h"

#import "MModel.h"

@implementation PrototypeManager

- (id)init;
{
    if ([super init] == nil)
        return nil;

    model = nil;

    /* Set up responder for cut/copy/paste operations */
    delegateResponder = [[DelegateResponder alloc] init];
    [delegateResponder setDelegate:self];

    return self;
}

- (void)dealloc;
{
    [model release];

    [courierFont release];
    [courierBoldFont release];

    [delegateResponder setDelegate:nil];
    [delegateResponder release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [protoBrowser setTarget:self];
    [protoBrowser setAction:@selector(browserHit:)];
    [protoBrowser setDoubleAction:@selector(browserDoubleHit:)];

    // TODO (2004-03-03): Check these fonts.
    courierFont = [[NSFont fontWithName:@"Courier" size:12] retain];
    courierBoldFont = [[NSFont fontWithName:@"Courier-Bold" size:12] retain];
    NSLog(@"courierFont: %@", courierFont);
    NSLog(@"courierBoldFont: %@", courierBoldFont);

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == model)
        return;

    [model release];
    model = [newModel retain];
}

- (IBAction)browserHit:(id)sender;
{
    NamedList *aList;
    MMEquation *aMMEquation;
    ProtoTemplate *aProtoTemplate;
    Inspector *inspector;
    int column = [protoBrowser selectedColumn];
    int row = [[protoBrowser matrixInColumn:column] selectedRow];
    RuleManager *ruleManager = NXGetNamedObject(@"ruleManager", NSApp);
    NSString *str;

    inspector = [controller inspector];

    if ([[sender matrixInColumn:0] selectedRow] != -1)
        [newButton setEnabled:YES];
    else
        [newButton setEnabled:NO];

    if (column == 0) {
        switch ([[browserSelector selectedCell] tag]) {
          case 0:
              [inputTextField setStringValue:[(NamedList *)[[model equations] objectAtIndex:row] name]];
              break;
          case 1:
              [inputTextField setStringValue:[(NamedList *)[[model transitions] objectAtIndex:row] name]];
              break;
          case 2:
              [inputTextField setStringValue:[(NamedList *)[[model specialTransitions] objectAtIndex:row] name]];
              break;
        }
        [selectedOutput setStringValue:@""];
        //[inputTextField selectText:sender];
        //[[sender window] makeFirstResponder:delegateResponder];
        [inspector cleanInspectorWindow];
        return;
    }

    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          aList = [[model equations] objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          aMMEquation = [aList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
          str = [[aMMEquation expression] expressionString];
          if (str == nil)
              str = @"";
          [selectedOutput setStringValue:str];
          [removeButton setEnabled:!([ruleManager isEquationUsed:aMMEquation] || [self isEquationUsed:aMMEquation] )] ;
          [inspector inspectMMEquation:aMMEquation];
          break;
      case 1:
          aList = [[model transitions] objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          aProtoTemplate = [aList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
          [removeButton setEnabled:![ruleManager isTransitionUsed:aProtoTemplate]];
          [inspector inspectProtoTransition:aProtoTemplate];
          switch ([aProtoTemplate type]) {
            case DIPHONE:
                [selectedOutput setStringValue:@"Diphone"];
                break;
            case TRIPHONE:
                [selectedOutput setStringValue:@"Triphone"];
                break;
            case TETRAPHONE:
                [selectedOutput setStringValue:@"Tetraphone"];
                break;
          }
          break;
      case 2:
          aList = [[model specialTransitions] objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          aProtoTemplate = [aList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
          [removeButton setEnabled:![ruleManager isTransitionUsed:aProtoTemplate]];
          [inspector inspectProtoTransition:aProtoTemplate];
          switch ([aProtoTemplate type]) {
            case DIPHONE:
                [selectedOutput setStringValue:@"Diphone"];
                break;
            case TRIPHONE:
                [selectedOutput setStringValue:@"Triphone"];
                break;
            case TETRAPHONE:
                [selectedOutput setStringValue:@"Tetraphone"];
                break;
          }
          break;
      default:
          NSLog(@"WHAT?");
          break;
    }

    //[[sender window] makeFirstResponder:delegateResponder];
}

- (IBAction)browserDoubleHit:(id)sender;
{
    TransitionView *transitionBuilder;
    NamedList *aList;
    int column = [protoBrowser selectedColumn];

    if (column == 0)
        return;

    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          break;
      case 1:
          transitionBuilder = NXGetNamedObject(@"transitionBuilder", NSApp);
          aList = [[model transitions] objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          [transitionBuilder setTransition:[aList objectAtIndex:[[sender matrixInColumn:1] selectedRow]]];
          [transitionBuilder showWindow:[[protoBrowser window] windowNumber]];
          break;
      case 2:
          transitionBuilder = NXGetNamedObject(@"specialTransitionBuilder", NSApp);
          aList = [[model specialTransitions] objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
          [transitionBuilder setTransition:[aList objectAtIndex:[[sender matrixInColumn:1] selectedRow]]];
          [transitionBuilder showWindow:[[protoBrowser window] windowNumber]];
          break;
      default:
          NSLog(@"WHAT?");
          break;
    }
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    NamedList *aList;

    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          if (column == 0)
              return [[model equations] count];
          else {
              aList = [[model equations] objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              return [aList count];
          }
          break;
      case 1:
          if (column == 0)
              return [[model transitions] count];
          else {
              aList = [[model transitions] objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              return [aList count];
          }
          break;
      case 2:
          if (column == 0)
              return [[model specialTransitions] count];
          else {
              aList = [[model specialTransitions] objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              return [aList count];
          }
          break;
      default:
          NSLog(@"WHAT?");
          break;
    }

    return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    RuleManager *ruleManager = NXGetNamedObject(@"ruleManager", NSApp);
    NamedList *aList;
    BOOL used = NO;

    switch ([[browserSelector selectedCell] tag]) {
        /* Equations */
      case 0:
          if (column == 0) {
              [cell setStringValue:[(NamedList *)[[model equations] objectAtIndex:row] name]];
              [cell setLeaf:NO];
              [cell setLoaded:YES];
          } else {
              aList = [[model equations] objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              [cell setStringValue:[(MMEquation *)[aList objectAtIndex:row] name]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              used = [ruleManager isEquationUsed:[aList objectAtIndex:row]];
              if (!used)
                  used = [self isEquationUsed:[aList objectAtIndex:row]];

              if (used)
                  [cell setFont:courierBoldFont];
              else
                  [cell setFont:courierFont];
          }
          break;

          /* Templates */
      case 1:
          if (column == 0) {
              [cell setStringValue:[(NamedList *)[[model transitions] objectAtIndex:row] name]];
              [cell setLeaf:NO];
              [cell setLoaded:YES];
          } else {
              aList = [[model transitions] objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              [cell setStringValue:[(MMEquation *)[aList objectAtIndex:row] name]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              used = [ruleManager isTransitionUsed:[aList objectAtIndex:row]];

              if (used)
                  [cell setFont:courierBoldFont];
              else
                  [cell setFont:courierFont];
          }
          break;
          /* Special Profiles */
      case 2:
          if (column == 0) {
              [cell setStringValue:[(NamedList *)[[model specialTransitions] objectAtIndex:row] name]];
              [cell setLeaf:NO];
              [cell setLoaded:YES];
          } else {
              aList = [[model specialTransitions] objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
              [cell setStringValue:[(MMEquation *)[aList objectAtIndex:row] name]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              used = [ruleManager isTransitionUsed:[aList objectAtIndex:row]];

              if (used)
                  [cell setFont:courierBoldFont];
              else
                  [cell setFont:courierFont];
          }
          break;
      default:
          NSLog(@"WHAT?");
          break;
    }
}

- (IBAction)addCategory:(id)sender;
{
    NamedList *newList;

    switch ([[browserSelector selectedCell] tag]) {
      case 0: /* Test for Already Existing Name */
          newList = [[NamedList alloc] initWithCapacity:10];
          [newList setName:[inputTextField stringValue]];
          [[model equations] addObject:newList];
          [newList release];
          [protoBrowser loadColumnZero];
          break;
      case 1: /* Test for Already Existing Name */
          newList = [[NamedList alloc] initWithCapacity:10];
          [newList setName:[inputTextField stringValue]];
          [[model transitions] addObject:newList];
          [newList release];
          [protoBrowser loadColumnZero];
          break;
      case 2: /* Test for Already Existing Name */
          newList = [[NamedList alloc] initWithCapacity:10];
          [newList setName:[inputTextField stringValue]];
          [[model specialTransitions] addObject:newList];
          [newList release];
          [protoBrowser loadColumnZero];
          break;
    }
}

- (IBAction)add:(id)sender;
{
    NamedList *aList;
    MMEquation *newEquation;
    ProtoTemplate *newTemplate;

    switch ([[browserSelector selectedCell] tag]) {
      case 0: /* Test for Already Existing Name */
          aList = [[model equations] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          newEquation = [[MMEquation alloc] initWithName:[inputTextField stringValue]];
          [aList addObject:newEquation];
          [newEquation release];
          [protoBrowser reloadColumn:1];
          break;
      case 1: /* Test for Already Existing Name */
          aList = [[model transitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          newTemplate = [[ProtoTemplate alloc] initWithName:[inputTextField stringValue]];
          [aList addObject:newTemplate];
          [newTemplate release];
          [protoBrowser reloadColumn:1];
          break;
      case 2: /* Test for Already Existing Name */
          aList = [[model specialTransitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          newTemplate = [[ProtoTemplate alloc] initWithName:[inputTextField stringValue]];
          [aList addObject:newTemplate];
          [newTemplate release];
          [protoBrowser reloadColumn:1];
          break;
    }
}

// TODO (2004-03-06): It looks like this can rename lists or equations?
- (IBAction)rename:(id)sender;
{
    id temp = nil;
    NamedList *aList;
    int column = [protoBrowser selectedColumn];

    NSLog(@"Rename: Column = %d", column);
    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          if (column == 0) {
              temp = [[model equations] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              NSLog(@"Rename : %s", [[temp name] cString]);
          } else {
              aList = [[model equations] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              temp = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          }
          break;
      case 1:
          if (column == 0) {
              temp = [[model transitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          } else {
              aList = [[model transitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              temp = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          }
          break;

      case 2:
          if (column == 0) {
              temp = [[model specialTransitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          } else {
              aList = [[model specialTransitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              temp = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          }
    }

    [(NamedList *)temp setName:[inputTextField stringValue]]; // Might also be a MMEquation or ProtoTemplate
    [protoBrowser reloadColumn:column];
}

- (IBAction)remove:(id)sender;
{
}

- (IBAction)setEquations:(id)sender;
{
    Inspector *inspector = [controller inspector];

    [newButton setTitle:@"New Equation"];
    [newButton setEnabled:NO];
    [outputBox setTitle:@"Selected Prototype Equation"];
    [outputBox display];
    [protoBrowser loadColumnZero];
    [inspector cleanInspectorWindow];
}

- (IBAction)setTransitions:(id)sender;
{
    Inspector *inspector = [controller inspector];

    [newButton setTitle:@"New Transition"];
    [newButton setEnabled:NO];
    [outputBox setTitle:@"Selected Prototype Transition Type"];
    [outputBox display];
    [protoBrowser loadColumnZero];
    [inspector cleanInspectorWindow];
}

- (IBAction)setSpecial:(id)sender;
{
    Inspector *inspector = [controller inspector];

    [newButton setTitle:@"New Special"];
    [newButton setEnabled:NO];
    [outputBox setTitle:@"Selected Prototype Transition Type"];
    [outputBox display];
    [protoBrowser loadColumnZero];
    [inspector cleanInspectorWindow];
}

- (MonetList *)equationList;
{
    return [model equations];
}

- (MonetList *)transitionList;
{
    return [model transitions];
}

- (MonetList *)specialList;
{
    return [model specialTransitions];
}

// Keeping for compatibility, for now
- (MMEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
{
    return [[self model] findEquationList:aListName named:anEquationName];
}

- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(MMEquation *)anEquation;
{
    [[self model] findList:listIndex andIndex:equationIndex ofEquation:anEquation];
}

- (MMEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;
{
    return [[self model] findEquation:listIndex andIndex:equationIndex];
}

- (MMEquation *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
{
    return [[self model] findTransitionList:aListName named:aTransitionName];
}

- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(MMEquation *)aTransition;
{
    [[self model] findList:listIndex andIndex:transitionIndex ofTransition:aTransition];
}

- (MMEquation *)findTransition:(int)listIndex andIndex:(int)transitionIndex;
{
    return [[self model] findTransition:listIndex andIndex:transitionIndex];
}

- (ProtoTemplate *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
{
    return [[self model] findSpecialList:aListName named:aSpecialName];
}

- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(ProtoTemplate *)aTransition;
{
    [[self model] findList:listIndex andIndex:specialIndex ofSpecial:aTransition];
}

- (ProtoTemplate *)findSpecial:(int)listIndex andIndex:(int)specialIndex;
{
    return [[self model] findSpecial:listIndex andIndex:specialIndex];
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    int i, j;
    NamedList *currentList;

    for (i = 0; i < [[model transitions] count]; i++) {
        currentList = [[model transitions] objectAtIndex:i];
        for (j = 0; j < [currentList count]; j++) {
            if ([[currentList objectAtIndex:j] isEquationUsed:anEquation])
                return YES;
        }
    }

    for (i = 0; i < [[model specialTransitions] count]; i++) {
        currentList = [[model specialTransitions] objectAtIndex:i];
        for (j = 0; j < [currentList count]; j++) {
            if ([[currentList objectAtIndex:j] isEquationUsed:anEquation])
                return YES;
        }
    }

    return NO;
}

- (IBAction)cut:(id)sender;
{
    NSLog(@"PrototypeManager: cut");
}

static NSString *equString = @"MMEquation";
static NSString *tranString = @"ProtoTransition";
static NSString *specialString = @"ProtoSpecial";

- (IBAction)copy:(id)sender;
{
    NSPasteboard *myPasteboard;
    NSMutableData *mdata;
    NSArchiver *typed = nil;
    NSString *dataType;
    int column = [protoBrowser selectedColumn];
    int retValue;
    NamedList *aList;
    MMEquation *aMMEquation;
    ProtoTemplate *aProtoTemplate;

    myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];

    NSLog(@"PrototypeManager: copy  |%@|\n", [myPasteboard name]);

    mdata = [NSMutableData dataWithCapacity:16];
    typed = [[NSArchiver alloc] initForWritingWithMutableData:mdata];

    if (column != 1) {
        NSBeep();
        NSLog(@"Don't support copying a whole sublist yet");
        [typed release];
        return;
   } else
       switch ([[browserSelector selectedCell] tag]) {
           /* Equations */
         case 0:
             aList = [[model equations] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
             aMMEquation = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
             [aMMEquation encodeWithCoder:typed];
             dataType = equString;
             retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
             [myPasteboard setData:mdata forType:equString];
             NSLog(@"Ret from Pasteboard: %d", retValue);
             break;

             /* Transitions */
         case 1:
             aList = [[model transitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
             aProtoTemplate = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
             [aProtoTemplate encodeWithCoder:typed];
             dataType = tranString;
             retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
             [myPasteboard setData:mdata forType:tranString];
             NSLog(@"Ret from Pasteboard: %d", retValue);
             break;

             /* Special Transitions */
         case 2:
             aList = [[model specialTransitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
             aProtoTemplate = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
             [aProtoTemplate encodeWithCoder:typed];
             dataType = specialString;
             retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
             [myPasteboard setData:mdata forType:specialString];
             NSLog(@"Ret from Pasteboard: %d", retValue);
             break;
       }

    [typed release];
}

- (IBAction)paste:(id)sender;
{
    NSPasteboard *myPasteboard;
    NSData *mdata;
    NSArchiver *typed = nil;
    NSArray *dataTypes;
    NamedList *aList;
    MMEquation *aMMEquation;
    ProtoTemplate *aProtoTemplate;
    int column = [protoBrowser selectedColumn];

    myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];
    NSLog(@"PrototypeManager: paste  changeCount = %d  |%@|\n", [myPasteboard changeCount], [myPasteboard name]);

    dataTypes = [myPasteboard types];

    if (column == -1) {
        NSBeep();
        return;
    }

    if ([[dataTypes objectAtIndex:0] isEqual:equString]) {
        mdata = [myPasteboard dataForType:equString];
        typed = [[NSUnarchiver alloc] initForReadingWithData:mdata];
        aMMEquation = [[MMEquation alloc] init];
        [aMMEquation initWithCoder:typed];
        [typed release];

        aList = [[model equations] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
        if (column == 1)
            [aList insertObject:aMMEquation atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
        else
            [aList addObject:aMMEquation];
        [aMMEquation release];

        [protoBrowser reloadColumn:1];
    } else if ([[dataTypes objectAtIndex: 0] isEqual: tranString]) {
        mdata = [myPasteboard dataForType:tranString];
        typed = [[NSUnarchiver alloc] initForReadingWithData:mdata];
        aProtoTemplate = [[ProtoTemplate alloc] init];
        [aProtoTemplate initWithCoder:typed];
        [typed release];

        aList = [[model transitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
        if (column == 1)
            [aList insertObject:aProtoTemplate atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
        else
            [aList addObject:aProtoTemplate];
        [aProtoTemplate release];

        [protoBrowser reloadColumn:1];
    } else if ([[dataTypes objectAtIndex:0] isEqual:specialString]) {
        mdata = [myPasteboard dataForType:specialString];
        typed = [[NSUnarchiver alloc] initForReadingWithData:mdata];
        aProtoTemplate = [[ProtoTemplate alloc] init];
        [aProtoTemplate initWithCoder:typed];
        [typed release];

        aList = [[model specialTransitions] objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
        if (column == 1)
            [aList insertObject:aProtoTemplate atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
        else
            [aList addObject:aProtoTemplate];
        [aProtoTemplate release];

        [protoBrowser reloadColumn:1];
    } else {
        NSBeep();
    }
}

- (void)windowDidBecomeMain:(NSNotification *)notification;
{
    Inspector *inspector = [controller inspector];
    NamedList *aList;
    MMEquation *aMMEquation;
    ProtoTemplate *aProtoTemplate;
    int column = [protoBrowser selectedColumn];
    int selectedColumn0Row, selectedColumn1Row;

    NSLog(@"Column = %d", column);
    if (column != 1) {
        [inspector cleanInspectorWindow];
        return;
    }

    selectedColumn0Row = [[protoBrowser matrixInColumn:0] selectedRow];
    selectedColumn1Row = [[protoBrowser matrixInColumn:1] selectedRow];
    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          aList = [[model equations] objectAtIndex:selectedColumn0Row];
          aMMEquation = [aList objectAtIndex:selectedColumn1Row];
          [inspector inspectMMEquation:aMMEquation];
          break;
      case 1:
          aList = [[model transitions] objectAtIndex:selectedColumn0Row];
          aProtoTemplate = [aList objectAtIndex:selectedColumn1Row];
          [inspector inspectProtoTransition:aProtoTemplate];
          break;
      case 2:
          aList = [[model specialTransitions] objectAtIndex:selectedColumn0Row];
          aProtoTemplate = [aList objectAtIndex:selectedColumn1Row];
          [inspector inspectProtoTransition:aProtoTemplate];
          break;
      default:
          [inspector cleanInspectorWindow];
          break;
    }
}

- (BOOL)windowShouldClose:(id)sender;
{
    [[controller inspector] cleanInspectorWindow];

    return YES;
}

- (void)windowDidResignMain:(NSNotification *)notification;
{
    [[controller inspector] cleanInspectorWindow];
}

@end
