#import "Inspector.h"

#import <AppKit/AppKit.h>
#import "IntonationPointInspector.h"
#import "RuleInspector.h"

@implementation Inspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [panel setFloatingPanel:YES];

    [noInspectorView retain];
    [noPopUpListView retain];

    [ruleInspector applicationDidFinishLaunching:notification];
    [intonationPointInspector applicationDidFinishLaunching:notification];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (void)dealloc;
{
    [noInspectorView release];
    [noPopUpListView release];

    [super dealloc];
}

- (NSWindow *)window;
{
    return mainInspectorWindow;
}

- (void)cleanInspectorWindow;
{
    [generalView removeFromSuperview];
    [[mainInspectorWindow contentView] addSubview:noInspectorView];
    generalView = noInspectorView;

    [popUpListView removeFromSuperview];
    [[mainInspectorWindow contentView] addSubview:noPopUpListView];
    popUpListView = noPopUpListView;

    [mainInspectorWindow setTitle:@"Inspector"];

    [[mainInspectorWindow contentView] display];
    [mainInspectorWindow flushWindow];
}

- (void)setGeneralView:(NSBox *)aView;
{
    if (generalView != aView) {
        [generalView removeFromSuperview];
        [[mainInspectorWindow contentView] addSubview:aView];
        generalView = aView;
        [[mainInspectorWindow contentView] display];
        [mainInspectorWindow flushWindow];
    }
}

- (void)setPopUpListView:(NSBox *)aView;
{
    if (popUpListView != aView) {
        [popUpListView removeFromSuperview];
        [[mainInspectorWindow contentView] addSubview:aView];
        popUpListView = aView;
        [[mainInspectorWindow contentView] display];
        [mainInspectorWindow flushWindow];
    }
}

- (void)beginEditingCurrentInspector;
{
    [mainInspectorWindow makeKeyAndOrderFront:self];
    [currentInspector beginEditing];
}

- (void)inspectRule:(MMRule *)rule;
{
    [panel setTitle:@"Rule Inspector"];
    currentInspectorObject = rule;
    currentInspector = ruleInspector;
    [ruleInspector inspectRule:rule];
}

- (void)inspectIntonationPoint:(IntonationPoint *)point;
{
    [intonationPointInspector inspectIntonationPoint:point];
}

@end
