#import "ParameterInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "Inspector.h"
#import "Parameter.h"
#import "PhoneList.h"

@implementation ParameterInspector

- (void)inspectParameter:parameter;
{
    currentParameter = parameter;
    [mainInspector setPopUpListView:parameterPopUpListView];
    [self setUpWindow:parameterPopUpList];
}

- (void)setUpWindow:(id)sender;
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

        [commentText setString:[currentParameter comment]];
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

- (void)setComment:(id)sender;
{
    [currentParameter setComment:[commentText string]];
}

- (void)revertComment:(id)sender;
{
    [commentText setString:[currentParameter comment]];
}

- (void)setValue:(id)sender;
{
    if ([currentParameter defaultValue] != [[valueFields cellAtIndex:2] doubleValue]) {
        [currentParameter setDefaultValue:[[valueFields cellAtIndex:2] doubleValue]];
        [NXGetNamedObject(@"mainPhoneList", NSApp) parameterDefaultChange:currentParameter to:[[valueFields cellAtIndex:2] doubleValue]];
    }

    [currentParameter setMinimumValue:[[valueFields cellAtIndex:0] doubleValue]];
    [currentParameter setMaximumValue:[[valueFields cellAtIndex:1] doubleValue]];
}

- (void)revertValue:(id)sender;
{
    [[valueFields cellAtIndex:0] setDoubleValue:[currentParameter minimumValue]];
    [[valueFields cellAtIndex:1] setDoubleValue:[currentParameter maximumValue]];
    [[valueFields cellAtIndex:2] setDoubleValue:[currentParameter defaultValue]];
}

@end
