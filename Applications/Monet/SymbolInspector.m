#import "SymbolInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "Inspector.h"
#import "PhoneList.h"
#import "Symbol.h"

@implementation SymbolInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    [commentView retain];
    [valueBox retain];
    [symbolPopUpListView retain];
}

- (void)dealloc;
{
    [commentView release];
    [valueBox release];
    [symbolPopUpListView release];

    [currentSymbol release];

    [super dealloc];
}

- (void)setCurrentSymbol:(Symbol *)aSymbol;
{
    if (aSymbol == currentSymbol)
        return;

    [currentSymbol release];
    currentSymbol = [aSymbol retain];
}

- (void)inspectSymbol:(Symbol *)aSymbol;
{
    [self setCurrentSymbol:aSymbol];
    [mainInspector setPopUpListView:symbolPopUpListView];
    [self setUpWindow:symbolPopUpList];
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    NSString *str;

    str = [[sender selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        [mainInspector setGeneralView:commentView];

        [setButton setTarget:self];
        [setButton setAction:@selector(setComment:)];

        [revertButton setTarget:self];
        [revertButton setAction:@selector(revertComment:)];

        if ([currentSymbol comment] != nil)
            [commentText setString:[currentSymbol comment]];
        else
            [commentText setString:@""];
    } else if ([str hasPrefix:@"D"]) {
        [mainInspector setGeneralView:valueBox];

        [setValueButton setTarget:self];
        [setValueButton setAction:@selector(setValue:)];

        [revertValueButton setTarget:self];
        [revertValueButton setAction:@selector(revertValue:)];

        [[valueFields cellAtIndex:0] setDoubleValue:[currentSymbol minimumValue]];
        [[valueFields cellAtIndex:1] setDoubleValue:[currentSymbol maximumValue]];
        [[valueFields cellAtIndex:2] setDoubleValue:[currentSymbol defaultValue]];
    }
}

- (void)beginEditting;
{
    NSString *str;

    str = [[symbolPopUpList selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        [commentText selectAll:self];
    }
}

- (IBAction)setComment:(id)sender;
{
    [currentSymbol setComment:[commentText string]];
}

- (IBAction)revertComment:(id)sender;
{
    if ([currentSymbol comment] != nil)
        [commentText setString:[currentSymbol comment]];
    else
        [commentText setString:@""];
}

- (IBAction)setValue:(id)sender;
{
    if ([currentSymbol defaultValue] != [[valueFields cellAtIndex:2] doubleValue]) {
        [currentSymbol setDefaultValue:[[valueFields cellAtIndex:2] doubleValue]];
        [NXGetNamedObject(@"mainPhoneList", NSApp) symbolDefaultChange:currentSymbol to:[[valueFields cellAtIndex:2] doubleValue]];
    }

    [currentSymbol setMinimumValue:[[valueFields cellAtIndex:0] doubleValue]];
    [currentSymbol setMaximumValue:[[valueFields cellAtIndex:1] doubleValue]];
}

- (IBAction)revertValue:(id)sender;
{
    [[valueFields cellAtIndex:0] setDoubleValue:[currentSymbol minimumValue]];
    [[valueFields cellAtIndex:1] setDoubleValue:[currentSymbol maximumValue]];
    [[valueFields cellAtIndex:2] setDoubleValue:[currentSymbol defaultValue]];
}

@end
