#import "ParameterInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "Inspector.h"
#import "Parameter.h"
#import "PhoneList.h"

@implementation ParameterInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    [commentView retain];
    [valueBox retain];
    [parameterPopUpListView retain];
}

- (void)dealloc;
{
    [commentView release];
    [valueBox release];
    [parameterPopUpListView release];

    [currentParameter release];

    [super dealloc];
}

- (void)setCurrentParameter:(Parameter *)aParameter;
{
    if (aParameter == currentParameter)
        return;

    [currentParameter release];
    currentParameter = [aParameter retain];
}

- (void)inspectParameter:(Parameter *)aParameter;
{
    [self setCurrentParameter:aParameter];
    [mainInspector setPopUpListView:parameterPopUpListView];
    [self setUpWindow:parameterPopUpList];
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    NSString *str;

    str = [[sender selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        [mainInspector setGeneralView:commentView];

        [setCommentButton setTarget:self];
        [setCommentButton setAction:@selector(setComment:)];

        [revertCommentButton setTarget:self];
        [revertCommentButton setAction:@selector(revertComment:)];

        if ([currentParameter comment] != nil)
            [commentText setString:[currentParameter comment]];
        else
            [commentText setString:@""];
    } else if ([str hasPrefix:@"D"]) {
        [mainInspector setGeneralView:valueBox];

        [setValueButton setTarget:self];
        [setValueButton setAction:@selector(setValue:)];

        [revertValueButton setTarget:self];
        [revertValueButton setAction:@selector(revertValue:)];

        [[valueFields cellAtIndex:0] setDoubleValue:[currentParameter minimumValue]];
        [[valueFields cellAtIndex:1] setDoubleValue:[currentParameter maximumValue]];
        [[valueFields cellAtIndex:2] setDoubleValue:[currentParameter defaultValue]];
    }
}

- (void)beginEditting;
{
    NSString *str;

    str = [[parameterPopUpList selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        [commentText selectAll:self];
    } else if ([str hasPrefix:@"D"]) {
        [valueFields selectTextAtIndex:0];
    }
}

- (IBAction)setComment:(id)sender;
{
    NSString *newComment;

    newComment = [[commentText string] copy]; // Need to copy, becuase it's mutable and owned by the NSTextView
    [currentParameter setComment:newComment];
    [newComment release];
}

- (IBAction)revertComment:(id)sender;
{
    if ([currentParameter comment] != nil)
        [commentText setString:[currentParameter comment]];
    else
        [commentText setString:@""];
}

- (IBAction)setValue:(id)sender;
{
    if ([currentParameter defaultValue] != [[valueFields cellAtIndex:2] doubleValue]) {
        [currentParameter setDefaultValue:[[valueFields cellAtIndex:2] doubleValue]];
        [NXGetNamedObject(@"mainPhoneList", NSApp) parameterDefaultChange:currentParameter to:[[valueFields cellAtIndex:2] doubleValue]];
    }

    [currentParameter setMinimumValue:[[valueFields cellAtIndex:0] doubleValue]];
    [currentParameter setMaximumValue:[[valueFields cellAtIndex:1] doubleValue]];
}

- (IBAction)revertValue:(id)sender;
{
    [[valueFields cellAtIndex:0] setDoubleValue:[currentParameter minimumValue]];
    [[valueFields cellAtIndex:1] setDoubleValue:[currentParameter maximumValue]];
    [[valueFields cellAtIndex:2] setDoubleValue:[currentParameter defaultValue]];
}

@end
