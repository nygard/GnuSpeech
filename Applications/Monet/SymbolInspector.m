#import "SymbolInspector.h"

#import <AppKit/AppKit.h>
#import "Inspector.h"
#import "MyController.h"
#import "PhoneList.h"
#import "Symbol.h"

@implementation SymbolInspector

- (void)inspectSymbol:symbol;
{
    currentSymbol = symbol;
    [mainInspector setPopUpListView:symbolPopUpListView];
    [self setUpWindow:symbolPopUpList];
}

- (void)setUpWindow:(id)sender;
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

        [commentText setString:[currentSymbol comment]];
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

- (void)setComment:(id)sender;
{
    [currentSymbol setComment:[commentText string]];
}

- (void)revertComment:(id)sender;
{
    [commentText setString:[currentSymbol comment]];
}

- (void)setValue:(id)sender;
{
    if ([currentSymbol defaultValue] != [[valueFields cellAtIndex:2] doubleValue]) {
        [currentSymbol setDefaultValue:[[valueFields cellAtIndex:2] doubleValue]];
        [NXGetNamedObject(@"mainPhoneList", NSApp) symbolDefaultChange:currentSymbol to:[[valueFields cellAtIndex:2] doubleValue]];
    }

    [currentSymbol setMinimumValue:[[valueFields cellAtIndex:0] doubleValue]];
    [currentSymbol setMaximumValue:[[valueFields cellAtIndex:1] doubleValue]];
}

- (void)revertValue:(id)sender;
{
    [[valueFields cellAtIndex:0] setDoubleValue:[currentSymbol minimumValue]];
    [[valueFields cellAtIndex:1] setDoubleValue:[currentSymbol maximumValue]];
    [[valueFields cellAtIndex:2] setDoubleValue:[currentSymbol defaultValue]];
}

@end
