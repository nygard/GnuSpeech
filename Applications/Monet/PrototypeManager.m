#import "PrototypeManager.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AppController.h"
#import "DelegateResponder.h"
#import "FormulaExpression.h"
#import "Inspector.h"
#import "MonetList.h"
#import "NamedList.h"
#import "ProtoEquation.h"
#import "ProtoTemplate.h"
#import "RuleManager.h"
#import "TransitionView.h"

@implementation PrototypeManager

- (id)init;
{
    if ([super init] == nil)
        return nil;

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

- (void)dealloc;
{
    [protoEquations release];
    [protoTemplates release];
    [protoSpecial release];
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

- (IBAction)browserHit:(id)sender;
{
    id temp, tempList, tempEntry;
    int column = [protoBrowser selectedColumn];
    int row = [[protoBrowser matrixInColumn:column] selectedRow];
    RuleManager *ruleManager = NXGetNamedObject(@"ruleManager", NSApp);

    temp = [controller inspector];

    if ([[sender matrixInColumn:0] selectedRow] != -1)
        [newButton setEnabled:YES];
    else
        [newButton setEnabled:NO];

    if (column == 0) {
        switch ([[browserSelector selectedCell] tag]) {
          case 0:
              [inputTextField setStringValue:[(NamedList *)[protoEquations objectAtIndex:row] name]];
              break;
          case 1:
              [inputTextField setStringValue:[(NamedList *)[protoTemplates objectAtIndex:row] name]];
              break;
          case 2:
              [inputTextField setStringValue:[(NamedList *)[protoSpecial objectAtIndex:row] name]];
              break;
        }
        [inputTextField selectText:sender];
        [[sender window] makeFirstResponder:delegateResponder];
        [temp cleanInspectorWindow];
        return;
    }

    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          tempList = [protoEquations objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          tempEntry = [tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
          [selectedOutput setStringValue:[[tempEntry expression] expressionString]];
          [removeButton setEnabled:!([ruleManager isEquationUsed:tempEntry] || [self isEquationUsed:tempEntry] )] ;
          [temp inspectProtoEquation:tempEntry];
          break;
      case 1:
          tempList = [protoTemplates objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          tempEntry = [tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
          [removeButton setEnabled:![ruleManager isTransitionUsed:tempEntry]];
          [temp inspectProtoTransition:tempEntry];
          switch ([(ProtoTemplate *)tempEntry type]) {
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
          tempList = [protoSpecial objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          tempEntry = [tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
          [removeButton setEnabled:![ruleManager isTransitionUsed:tempEntry]];
          [temp inspectProtoTransition:tempEntry];
          switch ([(ProtoTemplate *)tempEntry type]) {
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

    [[sender window] makeFirstResponder:delegateResponder];
}

- (IBAction)browserDoubleHit:(id)sender;
{
    id temp, tempList;
    int column = [protoBrowser selectedColumn];

    if (column == 0)
        return;

    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          break;
      case 1:
          temp = NXGetNamedObject(@"transitionBuilder", NSApp);
          tempList = [protoTemplates objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          [temp setTransition:[tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]]];
          [(TransitionView *)temp showWindow:[[protoBrowser window] windowNumber]];
          break;
      case 2:
          temp = NXGetNamedObject(@"specialTransitionBuilder", NSApp);
          tempList = [protoSpecial objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
          [temp setTransition:[tempList objectAtIndex:[[sender matrixInColumn:1] selectedRow]]];
          [(TransitionView *)temp showWindow:[[protoBrowser window] windowNumber]];
          break;
      default:
          NSLog(@"WHAT?");
          break;
    }
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    NamedList *tempList;

    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          if (column == 0)
              return [protoEquations count];
          else {
              tempList = [protoEquations objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              return [tempList count];
          }
          break;
      case 1:
          if (column == 0)
              return [protoTemplates count];
          else {
              tempList = [protoTemplates objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              return [tempList count];
          }
          break;
      case 2:
          if (column == 0)
              return [protoSpecial count];
          else {
              tempList = [protoSpecial objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              return [tempList count];
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
    NamedList *tempList;
    BOOL used = NO;

    switch ([[browserSelector selectedCell] tag]) {
        /* Equations */
      case 0:
          if (column == 0) {
              [cell setStringValue:[(NamedList *)[protoEquations objectAtIndex:row] name]];
              [cell setLeaf:NO];
              [cell setLoaded:YES];
          } else {
              tempList = [protoEquations objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              [cell setStringValue:[(ProtoEquation *)[tempList objectAtIndex:row] name]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              used = [ruleManager isEquationUsed:[tempList objectAtIndex:row]];
              if (!used)
                  used = [self isEquationUsed:[tempList objectAtIndex:row]];

              if (used)
                  [cell setFont:courierBoldFont];
              else
                  [cell setFont:courierFont];
          }
          break;

          /* Templates */
      case 1:
          if (column == 0) {
              [cell setStringValue:[(ProtoEquation *)[protoTemplates objectAtIndex:row] name]];
              [cell setLeaf:NO];
              [cell setLoaded:YES];
          } else {
              tempList = [protoTemplates objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              [cell setStringValue:[(ProtoEquation *)[tempList objectAtIndex:row] name]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              used = [ruleManager isTransitionUsed:[tempList objectAtIndex:row]];

              if (used)
                  [cell setFont:courierBoldFont];
              else
                  [cell setFont:courierFont];
          }
          break;
          /* Special Profiles */
      case 2:
          if (column == 0) {
              [cell setStringValue:[(ProtoEquation *)[protoSpecial objectAtIndex:row] name]];
              [cell setLeaf:NO];
              [cell setLoaded:YES];
          } else {
              tempList = [protoSpecial objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
              [cell setStringValue:[(ProtoEquation *)[tempList objectAtIndex:row] name]];
              [cell setLeaf:YES];
              [cell setLoaded:YES];
              used = [ruleManager isTransitionUsed:[tempList objectAtIndex:row]];

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
          [protoEquations addObject:newList];
          [newList release];
          [protoBrowser loadColumnZero];
          break;
      case 1: /* Test for Already Existing Name */
          newList = [[NamedList alloc] initWithCapacity:10];
          [newList setName:[inputTextField stringValue]];
          [protoTemplates addObject:newList];
          [newList release];
          [protoBrowser loadColumnZero];
          break;
      case 2: /* Test for Already Existing Name */
          newList = [[NamedList alloc] initWithCapacity:10];
          [newList setName:[inputTextField stringValue]];
          [protoSpecial addObject:newList];
          [newList release];
          [protoBrowser loadColumnZero];
          break;
    }
}

- (IBAction)add:(id)sender;
{
    NamedList *tempList;
    ProtoEquation *tempEquation;

    switch ([[browserSelector selectedCell] tag]) {
      case 0: /* Test for Already Existing Name */
          tempList = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          tempEquation = [[ProtoEquation alloc] initWithName:[inputTextField stringValue]];
          [tempList addObject:tempEquation];
          [protoBrowser reloadColumn:1];
          break;
      case 1: /* Test for Already Existing Name */
          tempList = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          tempEquation = [[ProtoTemplate alloc] initWithName:[inputTextField stringValue]];
          [tempList addObject:tempEquation];
          [protoBrowser reloadColumn:1];
          break;
      case 2: /* Test for Already Existing Name */
          tempList = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          tempEquation = [[ProtoTemplate alloc] initWithName:[inputTextField stringValue]];
          [tempList addObject:tempEquation];
          [protoBrowser reloadColumn:1];
          break;
    }
}

- (IBAction)rename:(id)sender;
{
    NamedList *temp = nil;
    id tempList;
    int column = [protoBrowser selectedColumn];

    NSLog(@"Rename: Column = %d", column);
    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          if (column == 0) {
              temp = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              NSLog(@"Rename : %s", [[temp name] cString]);
          } else {
              tempList = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              temp = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          }
          break;
      case 1:
          if (column == 0) {
              temp = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          } else {
              tempList = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              temp = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          }
          break;

      case 2:
          if (column == 0) {
              temp = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          } else {
              tempList = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              temp = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          }
    }


    [temp setName:[inputTextField stringValue]];
    [protoBrowser reloadColumn:column];
}

- (IBAction)remove:(id)sender;
{
}

- (IBAction)setEquations:(id)sender;
{
    id temp = [controller inspector];

    [newButton setTitle:@"New Equation"];
    [newButton setEnabled:NO];
    [outputBox setTitle:@"Selected Prototype Equation"];
    [outputBox display];
    [protoBrowser loadColumnZero];
    [temp cleanInspectorWindow];
}

- (IBAction)setTransitions:(id)sender;
{
    id temp = [controller inspector];

    [newButton setTitle:@"New Transition"];
    [newButton setEnabled:NO];
    [outputBox setTitle:@"Selected Prototype Transition Type"];
    [outputBox display];
    [protoBrowser loadColumnZero];
    [temp cleanInspectorWindow];
}

- (IBAction)setSpecial:(id)sender;
{
    id temp = [controller inspector];

    [newButton setTitle:@"New Special"];
    [newButton setEnabled:NO];
    [outputBox setTitle:@"Selected Prototype Transition Type"];
    [outputBox display];
    [protoBrowser loadColumnZero];
    [temp cleanInspectorWindow];
}

- (MonetList *)equationList;
{
    return protoEquations;
}

- (MonetList *)transitionList;
{
    return protoTemplates;
}

- (MonetList *)specialList;
{
    return protoSpecial;
}

// TODO (2004-03-06): Find equation named "named" in list named "list"
// Change to findEquationNamed:(NSString *)anEquationName inList:(NSString *)aListName;
// TODO (2004-03-06): Merge these three sets of methods, since they're practically identical.
- (ProtoEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
{
    int i, j;

    for (i = 0 ; i < [protoEquations count]; i++) {
        NamedList *currentList;

        currentList = [protoEquations objectAtIndex:i];
        if ([aListName isEqualToString:[currentList name]]) {
            for (j = 0; j < [currentList count]; j++) {
                ProtoEquation *anEquation;

                anEquation = [currentList objectAtIndex:j];
                if ([anEquationName isEqualToString:[anEquation name]])
                    return anEquation;
            }
        }
    }

    return nil;
}

- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(ProtoEquation *)anEquation;
{
    int i, temp;

    for (i = 0 ; i < [protoEquations count]; i++) {
        temp = [[protoEquations objectAtIndex:i] indexOfObject:anEquation];
        if (temp != NSNotFound) {
            *listIndex = i;
            *equationIndex = temp;
            return;
        }
    }

    *listIndex = -1;
    // TODO (2004-03-06): This might be where/how the large list indexes were archived.
}

- (ProtoEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;
{
    //NSLog(@"-> %s, listIndex: %d, index: %d", _cmd, listIndex, index);
    if (listIndex < 0 || listIndex > [protoEquations count]) {
        NSLog(@"-[%@ %s]: listIndex: %d out of range.  index: %d", NSStringFromClass([self class]), _cmd, listIndex, index);
        return nil;
    }

    return [[protoEquations objectAtIndex:listIndex] objectAtIndex:equationIndex];
}

- (ProtoEquation *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
{
    int i, j;

    for (i = 0 ; i < [protoTemplates count]; i++) {
        NamedList *currentList;

        currentList = [protoTemplates objectAtIndex:i];
        if ([aListName isEqualToString:[currentList name]]) {
            for (j = 0; j < [currentList count]; j++) {
                ProtoEquation *anEquation;

                anEquation = [currentList objectAtIndex:j];
                if ([aTransitionName isEqualToString:[anEquation name]])
                    return anEquation;
            }
        }
    }

    return nil;
}

- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(ProtoEquation *)aTransition;
{
    int i, temp;

    for (i = 0 ; i < [protoTemplates count]; i++) {
        temp = [[protoTemplates objectAtIndex:i] indexOfObject:aTransition];
        if (temp != NSNotFound) {
            *listIndex = i;
            *transitionIndex = temp;
            return;
        }
    }

    *listIndex = -1;
}

- (ProtoEquation *)findTransition:(int)listIndex andIndex:(int)transitionIndex;
{
    //NSLog(@"Name: %@ (%d)\n", [[protoTemplates objectAtIndex: listIndex] name], listIndex);
    //NSLog(@"\tCount: %d  index: %d  count: %d\n", [protoTemplates count], index, [[protoTemplates objectAtIndex: listIndex] count]);
    return [[protoTemplates objectAtIndex:listIndex] objectAtIndex:transitionIndex];
}

- (ProtoEquation *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
{
    int i, j;

    for (i = 0 ; i < [protoSpecial count]; i++) {
        NamedList *currentList;

        currentList = [protoSpecial objectAtIndex:i];
        if ([aListName isEqualToString:[currentList name]]) {
            for (j = 0; j < [currentList count]; j++) {
                ProtoEquation *anEquation;

                anEquation = [currentList objectAtIndex:j];
                if ([aSpecialName isEqualToString:[anEquation name]])
                    return anEquation;
            }
        }
    }

    return nil;
}

- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(ProtoEquation *)aTransition;
{
    int i, temp;

    for (i = 0 ; i < [protoSpecial count]; i++) {
        temp = [[protoSpecial objectAtIndex:i] indexOfObject:aTransition];
        if (temp != NSNotFound) {
            *listIndex = i;
            *specialIndex = temp;
            return;
        }
    }

    *listIndex = -1;
}

- (ProtoEquation *)findSpecial:(int)listIndex andIndex:(int)specialIndex;
{
    return [[protoSpecial objectAtIndex:listIndex] objectAtIndex:specialIndex];
}

- (BOOL)isEquationUsed:(ProtoEquation *)anEquation;
{
    int i, j;
    NamedList *currentList;

    for (i = 0; i < [protoTemplates count]; i++) {
        currentList = [protoTemplates objectAtIndex:i];
        for (j = 0; j < [currentList count]; j++) {
            if ([[currentList objectAtIndex:j] isEquationUsed:anEquation])
                return YES;
        }
    }

    for (i = 0; i < [protoSpecial count]; i++) {
        currentList = [protoSpecial objectAtIndex:i];
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

static NSString *equString = @"ProtoEquation";
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
    id tempList, tempEntry;

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
             tempList = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
             tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
             [tempEntry encodeWithCoder:typed];
             dataType = equString;
             retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
             [myPasteboard setData:mdata forType:equString];
             NSLog(@"Ret from Pasteboard: %d", retValue);
             break;

             /* Transitions */
         case 1:
             tempList = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
             tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
             [tempEntry encodeWithCoder:typed];
             dataType = tranString;
             retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
             [myPasteboard setData:mdata forType:tranString];
             NSLog(@"Ret from Pasteboard: %d", retValue);
             break;

             /* Special Transitions */
         case 2:
             tempList = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
             tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
             [tempEntry encodeWithCoder:typed];
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
    id temp, tempList;
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
        temp = [[ProtoEquation alloc] init];
        [temp initWithCoder:typed];
        [typed release];

        tempList = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
        if (column == 1)
            [tempList insertObject:temp atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
        else
            [tempList addObject:temp];

        [protoBrowser reloadColumn:1];
    } else if ([[dataTypes objectAtIndex: 0] isEqual: tranString]) {
        mdata = [myPasteboard dataForType:tranString];
        typed = [[NSUnarchiver alloc] initForReadingWithData:mdata];
        temp = [[ProtoTemplate alloc] init];
        [temp initWithCoder:typed];
        [typed release];

        tempList = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
        if (column == 1)
            [tempList insertObject:temp atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
        else
            [tempList addObject:temp];

        [protoBrowser reloadColumn:1];
    } else if ([[dataTypes objectAtIndex:0] isEqual:specialString]) {
        mdata = [myPasteboard dataForType:specialString];
        typed = [[NSUnarchiver alloc] initForReadingWithData:mdata];
        temp = [[ProtoTemplate alloc] init];
        [temp initWithCoder:typed];
        [typed release];

        tempList = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
        if (column == 1)
            [tempList insertObject:temp atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
        else
            [tempList addObject:temp];

        [protoBrowser reloadColumn:1];
    } else {
        NSBeep();
    }
}

- (void)readPrototypesFrom:(NSArchiver *)stream;
{
    MonetList *aList;

    [self _setProtoEquations:nil];
    [self _setProtoTemplates:nil];
    [self _setProtoSpecial:nil];

    aList = [stream decodeObject];
    [self _setProtoEquations:aList];

    aList = [stream decodeObject];
    [self _setProtoTemplates:aList];

    aList = [stream decodeObject];
    [self _setProtoSpecial:aList];
}

- (void)writePrototypesTo:(NSArchiver *)stream;
{
    [stream encodeObject:protoEquations];
    [stream encodeObject:protoTemplates];
    [stream encodeObject:protoSpecial];
}

- (void)windowDidBecomeMain:(NSNotification *)notification;
{
    id temp = [controller inspector];
    id tempList, tempEntry;
    int column = [protoBrowser selectedColumn];

    NSLog(@"Column = %d", column);
    if (column != 1) {
        [temp cleanInspectorWindow];
        return;
    }

    switch ([[browserSelector selectedCell] tag]) {
      case 0:
          tempList = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
          [temp inspectProtoEquation:tempEntry];
          break;
      case 1:
          tempList = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
          [temp inspectProtoTransition:tempEntry];
          break;
      case 2:
          tempList = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          tempEntry = [tempList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
          [temp inspectProtoTransition:tempEntry];
          break;
      default:
          [temp cleanInspectorWindow];
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

- (void)_setProtoEquations:(MonetList *)newProtoEquations;
{
    if (newProtoEquations == protoEquations)
        return;

    [protoEquations release];
    protoEquations = [newProtoEquations retain];
}

- (void)_setProtoTemplates:(MonetList *)newProtoTemplates;
{
    if (newProtoTemplates == protoTemplates)
        return;

    [protoTemplates release];
    protoTemplates = [newProtoTemplates retain];
}

- (void)_setProtoSpecial:(MonetList *)newProtoSpecial;
{
    if (newProtoSpecial == protoSpecial)
        return;

    [protoSpecial release];
    protoSpecial = [newProtoSpecial retain];
}

@end
