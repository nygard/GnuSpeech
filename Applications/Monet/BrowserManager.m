#import "BrowserManager.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "CategoryList.h"
#import "CategoryNode.h"
#import "Inspector.h"
#import "MonetList.h"
#import "MyController.h"
#import "Parameter.h"
#import "ParameterList.h"
#import "Phone.h"
#import "PhoneList.h"
#import "RuleManager.h"
#import "Symbol.h"
#import "SymbolList.h"

@implementation BrowserManager

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (BOOL)becomeFirstResponder;
{
    NSLog(@"Now First Responder");
    return YES;
}

- (BOOL)resignFirstResponder;
{
    NSLog(@"Resigning first responder");
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    [browser setTarget:self];
    [browser setAction:@selector(browserHit:)];
    [browser setDoubleAction:@selector(browserDoubleHit:)];

    [[browser window] makeFirstResponder:self];

    list[0] = NXGetNamedObject(@"mainPhoneList", NSApp);
    list[1] = NXGetNamedObject(@"mainCategoryList", NSApp);
    list[2] = NXGetNamedObject(@"mainParameterList", NSApp);
    list[3] = NXGetNamedObject(@"mainMetaParameterList", NSApp);
    list[4] = NXGetNamedObject(@"mainSymbolList", NSApp);

    currentList = 0;

    courier = [NSFont fontWithName:@"Courier" size:12];
    courierBold = [NSFont fontWithName:@"Courier-Bold" size:12]; // TODO (2004-03-02): Should use NSFontManager instead.
}

- (void)setCurrentList:sender;
{
    NSString *title;
    id inspector;

    title = [[sender selectedCell] title];
    if ([title hasPrefix:@"C"]) {
        currentList = 1;
    } else if ([title hasPrefix:@"F"]) {
        currentList = 4;
    } else if ([title hasPrefix:@"M"]) {
        currentList = 3;
    } else if ([title hasPrefix:@"Ph"]) {
        currentList = 0;
    } else if ([title hasPrefix:@"P"]) {
        currentList = 2;
    }

    [browser setTitle:[NSString stringWithFormat:@"Total: %d", [list[currentList] count]] ofColumn:0];
    [browser loadColumnZero];

    inspector = [controller inspector];
    if (inspector)
        [inspector cleanInspectorWindow];
}

- (void)updateBrowser;
{
    [browser setTitle:[NSString stringWithFormat:@"Total: %d", [list[currentList] count]] ofColumn:0];
    [browser loadColumnZero];
}

- (void)updateLists;
{
    list[0] = NXGetNamedObject(@"mainPhoneList", NSApp);
    list[1] = NXGetNamedObject(@"mainCategoryList", NSApp);
    list[2] = NXGetNamedObject(@"mainParameterList", NSApp);
    list[3] = NXGetNamedObject(@"mainMetaParameterList", NSApp);
    list[4] = NXGetNamedObject(@"mainSymbolList", NSApp);
}

- (void)addObjectToCurrentList:tempEntry;
{
    int row = [[browser matrixInColumn:0] selectedRow];
    id temp;

    if (row == -1) {
        switch (currentList) {
          case 0:
              break;
          case 1:
              break;
          case 2:
              break;
          case 3:
              break;
          case 4:
              break;
        }
    } else {
        temp = [list[currentList] objectAtIndex:row];
        [tempEntry setSymbol:[temp symbol]];
        [list[currentList] replaceObjectAtIndex:row withObject:tempEntry];
    }
}

- (void)browserHit:sender;
{
    id temp;
    int index;

    [[browser window] makeFirstResponder:self];
    temp = [controller inspector];
    index = [[sender matrixInColumn:0] selectedRow];
    if (temp) {
        if (index == -1) {
            [temp cleanInspectorWindow];
            return;
        }

        switch (currentList) {
          case 0:
              [temp inspectPhone:[list[currentList] objectAtIndex:index]];
              break;
          case 1:
              [temp inspectCategory:[list[currentList] objectAtIndex:index]];
              break;
          case 2:
              [temp inspectParameter:[list[currentList] objectAtIndex:index]];
              break;
          case 3:
              [temp inspectMetaParameter:[list[currentList] objectAtIndex:index]];
              break;
          case 4:
              [temp inspectSymbol:[list[currentList] objectAtIndex:index]];
              break;
        }
    }
}

- (void)browserDoubleHit:sender;
{
    id temp;
    int index;

    temp = [controller inspector];
    index = [[sender matrixInColumn:0] selectedRow];

    if (!temp) {
        [controller displayInspectorWindow:self];
        temp = [controller inspector];
        switch (currentList) {
          case 0:
              [temp inspectPhone:[list[currentList] objectAtIndex:index]];
              break;
          case 1:
              [temp inspectCategory:[list[currentList] objectAtIndex:index]];
              break;
          case 2:
              [temp inspectParameter:[list[currentList] objectAtIndex:index]];
              break;
          case 3:
              [temp inspectMetaParameter:[list[currentList] objectAtIndex:index]];
              break;
          case 4:
              [temp inspectSymbol:[list[currentList] objectAtIndex:index]];
              break;
        }
    }

    [temp beginEdittingCurrentInspector];
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    return [list[currentList] count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    id ruleManager = NXGetNamedObject(@"ruleManager", NSApp);

    /* Get CategoryNode Object From Category List (indexed by row) */
    [cell setStringValue:[[list[currentList] objectAtIndex:row] symbol]];
    [cell setLeaf:YES];

    switch (currentList) {
      case 0:
          break;
      case 1:
          if ([ruleManager isCategoryUsed:[list[currentList] objectAtIndex:row]])
              [cell setFont:courierBold];
          else
              [cell setFont:courier];
          break;
      case 2:
          break;
      case 3:
          break;
      case 4:
          break;
      default:
          break;
    }
}

- (void)add:sender;
{
    if (![list[currentList] findByName:[nameField stringValue]])
    {
        [list[currentList] addNewValue:[nameField stringValue]];
        [browser loadColumnZero];

        switch (currentList) {
          case 2:
              [controller addParameter];
              break;
          case 3:
              [controller addMetaParameter];
              break;
          case 4:
              [controller addSymbol];
              break;

          default:
              break;
        }
    } else
        NSBeep();

    [nameField selectTextAtIndex:0];
}

- (void)rename:sender;
{
    id temp, cell;

    if ([list[currentList] findByName:[nameField stringValue]]) {
        NSBeep();
        return;
    }

    cell = [browser selectedCell];
    if (cell) {
        temp = [list[currentList] findByName:[[browser selectedCell] stringValue]];
        [list[currentList] changeSymbolOf:temp to:[nameField stringValue]];
    }
    [browser loadColumnZero];
    [nameField selectTextAtIndex:0];
}

- (void)remove:sender;
{
    id temp, cell;
    int index;

    cell = [browser selectedCell];
    if (cell) {
        temp = [list[currentList] findByName:[[browser selectedCell] stringValue]];
        if (temp) {
            index = [list[currentList] indexOfObject:temp];
            switch (currentList) {
              case 2:
                  [(MyController *)controller removeParameter:index];
                  //[list[0] removeParameter:index];
                  break;
              case 3:
                  [(MyController *)controller removeMetaParameter:index];
                  //[list[0] removeMetaParameter:index];
                  break;
              case 4:
                  [(PhoneList *)(list[0]) removeSymbol:index];
                  break;
              default:
                  break;
            }

            [list[currentList] removeObject:temp];
        }

        [browser loadColumnZero];
    }

    [nameField selectTextAtIndex:0];
}

- (void)cut:(id)sender;
{
    NSLog(@"Cut");
}

static NSString *phoneString = @"Phone";
static NSString *categoryString = @"Category";
static NSString *parameterString = @"Parameter";
static NSString *metaParameterString = @"MetaParameter";
static NSString *symbolString = @"Symbol";

- (void)copy:(id)sender;
{
    NSPasteboard *myPasteboard;
    NSArchiver *typed = nil;
    NSMutableData *mdata;
    NSString *dataType;
    int row = [[browser matrixInColumn:0] selectedRow];
    int retValue;
    id tempEntry;

    myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];

    mdata = [NSMutableData dataWithCapacity:16];
    typed = [[NSArchiver alloc] initForWritingWithMutableData:mdata];

    tempEntry = [list[currentList] objectAtIndex:row];
    [tempEntry encodeWithCoder:typed];

    switch (currentList) {
      case 0:
          dataType = phoneString;
          break;
      case 1:
          dataType = categoryString;
          break;
      case 2:
          dataType = parameterString;
          break;
      case 3:
          dataType = metaParameterString;
          break;
      case 4:
          dataType = symbolString;
          break;
    }

    retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];
    [myPasteboard setData:mdata forType:dataType];

    [typed release];
}

- (void)paste:(id)sender;
{
    NSPasteboard *myPasteboard;
    NSArchiver *typed = nil;
    NSData *mdata;
    NSArray *dataTypes;
    NSString *dataType;
    id tempEntry;

    myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];
    dataTypes = [myPasteboard types];
    dataType = [dataTypes objectAtIndex:0];
    switch (currentList) {
      case 0:
          if (![dataType isEqual:phoneString]) {
              NSBeep();
              return;
          }

          tempEntry = [[Phone alloc] init];
          mdata = [myPasteboard dataForType:phoneString];
          typed = [[NSUnarchiver alloc] initForReadingWithData:mdata];
          [tempEntry initWithCoder:typed];
          [typed release];
          [tempEntry release];

          tempEntry = [list[0] makePhoneUniqueName:tempEntry];
          [list[0] addPhoneObject:tempEntry];
          [browser loadColumnZero];
          [browser setPath:[tempEntry symbol]];
          break;

      case 1:
          if (![dataType isEqual:categoryString]) {
              NSBeep();
              return;
          }

          tempEntry = [[CategoryNode alloc] init];
          break;

      case 2:
          if (![dataType isEqual:parameterString]) {
              NSBeep();
              return;
          }

          tempEntry = [[Parameter alloc] init];
          break;

      case 3:
          if (![dataType isEqual:metaParameterString]) {
              NSBeep();
              return;
          }

          tempEntry = [[Parameter alloc] init];
          break;

      case 4:
          if (![dataType isEqual:symbolString]) {
              NSBeep();
              return;
          }

          tempEntry = [[Symbol alloc] init];
          break;
    }
#warning TODO (2004-03-02): Check earliest sources.  It looks like most of the pasting is not implemeneted, and this leaks.
}

- (void)windowDidBecomeMain:(NSNotification *)notification;
{
    id temp;
    int index = 0;

    temp = [controller inspector];
    index = [[browser matrixInColumn:0] selectedRow];
    if (temp) {
        if (index == -1)
            [temp cleanInspectorWindow];
        else
            switch (currentList) {
              case 0:
                  [temp inspectPhone:[list[currentList] objectAtIndex:index]];
                  break;
              case 1:
                  [temp inspectCategory:[list[currentList] objectAtIndex:index]];
                  break;
              case 2:
                  [temp inspectParameter:[list[currentList] objectAtIndex:index]];
                  break;
              case 3:
                  [temp inspectMetaParameter:[list[currentList] objectAtIndex:index]];
                  break;
              case 4:
                  [temp inspectSymbol:[list[currentList] objectAtIndex:index]];
                  break;
            }
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
