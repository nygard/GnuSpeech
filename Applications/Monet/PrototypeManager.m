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
    NamedList *aList;
    ProtoEquation *aProtoEquation;
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
              [inputTextField setStringValue:[(NamedList *)[protoEquations objectAtIndex:row] name]];
              break;
          case 1:
              [inputTextField setStringValue:[(NamedList *)[protoTemplates objectAtIndex:row] name]];
              break;
          case 2:
              [inputTextField setStringValue:[(NamedList *)[protoSpecial objectAtIndex:row] name]];
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
          aList = [protoEquations objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          aProtoEquation = [aList objectAtIndex:[[sender matrixInColumn:1] selectedRow]];
          str = [[aProtoEquation expression] expressionString];
          if (str == nil)
              str = @"";
          [selectedOutput setStringValue:str];
          [removeButton setEnabled:!([ruleManager isEquationUsed:aProtoEquation] || [self isEquationUsed:aProtoEquation] )] ;
          [inspector inspectProtoEquation:aProtoEquation];
          break;
      case 1:
          aList = [protoTemplates objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
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
          aList = [protoSpecial objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
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
          aList = [protoTemplates objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
          [transitionBuilder setTransition:[aList objectAtIndex:[[sender matrixInColumn:1] selectedRow]]];
          [transitionBuilder showWindow:[[protoBrowser window] windowNumber]];
          break;
      case 2:
          transitionBuilder = NXGetNamedObject(@"specialTransitionBuilder", NSApp);
          aList = [protoSpecial objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
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
              return [protoEquations count];
          else {
              aList = [protoEquations objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              return [aList count];
          }
          break;
      case 1:
          if (column == 0)
              return [protoTemplates count];
          else {
              aList = [protoTemplates objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              return [aList count];
          }
          break;
      case 2:
          if (column == 0)
              return [protoSpecial count];
          else {
              aList = [protoSpecial objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
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
              [cell setStringValue:[(NamedList *)[protoEquations objectAtIndex:row] name]];
              [cell setLeaf:NO];
              [cell setLoaded:YES];
          } else {
              aList = [protoEquations objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              [cell setStringValue:[(ProtoEquation *)[aList objectAtIndex:row] name]];
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
              [cell setStringValue:[(NamedList *)[protoTemplates objectAtIndex:row] name]];
              [cell setLeaf:NO];
              [cell setLoaded:YES];
          } else {
              aList = [protoTemplates objectAtIndex:[[sender matrixInColumn:0] selectedRow]];
              [cell setStringValue:[(ProtoEquation *)[aList objectAtIndex:row] name]];
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
              [cell setStringValue:[(NamedList *)[protoSpecial objectAtIndex:row] name]];
              [cell setLeaf:NO];
              [cell setLoaded:YES];
          } else {
              aList = [protoSpecial objectAtIndex: [[sender matrixInColumn:0] selectedRow]];
              [cell setStringValue:[(ProtoEquation *)[aList objectAtIndex:row] name]];
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
    NamedList *aList;
    ProtoEquation *newEquation;
    ProtoTemplate *newTemplate;

    switch ([[browserSelector selectedCell] tag]) {
      case 0: /* Test for Already Existing Name */
          aList = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          newEquation = [[ProtoEquation alloc] initWithName:[inputTextField stringValue]];
          [aList addObject:newEquation];
          [newEquation release];
          [protoBrowser reloadColumn:1];
          break;
      case 1: /* Test for Already Existing Name */
          aList = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
          newTemplate = [[ProtoTemplate alloc] initWithName:[inputTextField stringValue]];
          [aList addObject:newTemplate];
          [newTemplate release];
          [protoBrowser reloadColumn:1];
          break;
      case 2: /* Test for Already Existing Name */
          aList = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
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
              temp = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              NSLog(@"Rename : %s", [[temp name] cString]);
          } else {
              aList = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              temp = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          }
          break;
      case 1:
          if (column == 0) {
              temp = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          } else {
              aList = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              temp = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          }
          break;

      case 2:
          if (column == 0) {
              temp = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          } else {
              aList = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
              temp = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
              NSLog(@"Rename: %s", [[temp name] cString]);
          }
    }

    [(NamedList *)temp setName:[inputTextField stringValue]]; // Might also be a ProtoEquation or ProtoTemplate
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
                NSLog(@"**************************************** %s, class = %@", _cmd, NSStringFromClass([anEquation class]));
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
    NamedList *aList;
    ProtoEquation *aProtoEquation;
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
             aList = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
             aProtoEquation = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
             [aProtoEquation encodeWithCoder:typed];
             dataType = equString;
             retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
             [myPasteboard setData:mdata forType:equString];
             NSLog(@"Ret from Pasteboard: %d", retValue);
             break;

             /* Transitions */
         case 1:
             aList = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
             aProtoTemplate = [aList objectAtIndex:[[protoBrowser matrixInColumn:1] selectedRow]];
             [aProtoTemplate encodeWithCoder:typed];
             dataType = tranString;
             retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
             [myPasteboard setData:mdata forType:tranString];
             NSLog(@"Ret from Pasteboard: %d", retValue);
             break;

             /* Special Transitions */
         case 2:
             aList = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
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
    ProtoEquation *aProtoEquation;
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
        aProtoEquation = [[ProtoEquation alloc] init];
        [aProtoEquation initWithCoder:typed];
        [typed release];

        aList = [protoEquations objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
        if (column == 1)
            [aList insertObject:aProtoEquation atIndex:[[protoBrowser matrixInColumn:1] selectedRow]+1];
        else
            [aList addObject:aProtoEquation];
        [aProtoEquation release];

        [protoBrowser reloadColumn:1];
    } else if ([[dataTypes objectAtIndex: 0] isEqual: tranString]) {
        mdata = [myPasteboard dataForType:tranString];
        typed = [[NSUnarchiver alloc] initForReadingWithData:mdata];
        aProtoTemplate = [[ProtoTemplate alloc] init];
        [aProtoTemplate initWithCoder:typed];
        [typed release];

        aList = [protoTemplates objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
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

        aList = [protoSpecial objectAtIndex:[[protoBrowser matrixInColumn:0] selectedRow]];
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
    Inspector *inspector = [controller inspector];
    NamedList *aList;
    ProtoEquation *aProtoEquation;
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
          aList = [protoEquations objectAtIndex:selectedColumn0Row];
          aProtoEquation = [aList objectAtIndex:selectedColumn1Row];
          [inspector inspectProtoEquation:aProtoEquation];
          break;
      case 1:
          aList = [protoTemplates objectAtIndex:selectedColumn0Row];
          aProtoTemplate = [aList objectAtIndex:selectedColumn1Row];
          [inspector inspectProtoTransition:aProtoTemplate];
          break;
      case 2:
          aList = [protoSpecial objectAtIndex:selectedColumn0Row];
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

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [self _appendXMLForProtoEquationsToString:resultString level:level];
    [self _appendXMLForProtoTemplatesToString:resultString level:level];
    [self _appendXMLForProtoSpecialsToString:resultString level:level];
}

- (void)_appendXMLForProtoEquationsToString:(NSMutableString *)resultString level:(int)level;
{
    NamedList *namedList;
    int count, index;

    [resultString indentToLevel:level];
    [resultString appendString:@"<proto-equations>\n"];
    count = [protoEquations count];
    for (index = 0; index < count; index++) {
        namedList = [protoEquations objectAtIndex:index];
        [namedList appendXMLToString:resultString elementName:@"group" level:level + 1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</proto-equations>\n"];
}

- (void)_appendXMLForProtoTemplatesToString:(NSMutableString *)resultString level:(int)level;
{
    NamedList *namedList;
    int count, index;

    [resultString indentToLevel:level];
    [resultString appendString:@"<proto-templates>\n"];
    count = [protoTemplates count];
    for (index = 0; index < count; index++) {
        namedList = [protoTemplates objectAtIndex:index];
        [namedList appendXMLToString:resultString elementName:@"group" level:level + 1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</proto-templates>\n"];
}

- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(int)level;
{
    NamedList *namedList;
    int count, index;

    [resultString indentToLevel:level];
    [resultString appendString:@"<proto-specials>\n"];
    count = [protoSpecial count];
    for (index = 0; index < count; index++) {
        namedList = [protoSpecial objectAtIndex:index];
        [namedList appendXMLToString:resultString elementName:@"group" level:level + 1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</proto-specials>\n"];
}

@end
