#import "Inspector.h"

#import <AppKit/AppKit.h>
#import "IntonationPointInspector.h"
#import "PointInspector.h"
#import "ProtoEquationInspector.h"
#import "ProtoTemplateInspector.h"
#import "RuleInspector.h"

@implementation Inspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [panel setFloatingPanel:YES];

    [noInspectorView retain];
    [noPopUpListView retain];

    [protoEquationInspector applicationDidFinishLaunching:notification];
    [protoTransitionInspector applicationDidFinishLaunching:notification];
    [ruleInspector applicationDidFinishLaunching:notification];
    [pointInspector applicationDidFinishLaunching:notification];
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

- (void)beginEdittingCurrentInspector;
{
    [mainInspectorWindow makeKeyAndOrderFront:self];
    [currentInspector beginEditting];
}

- (void)inspectEquation:(MMEquation *)equation;
{
    [panel setTitle:@"Prototype Equation Inspector"];
    currentInspectorObject = equation;
    currentInspector = protoEquationInspector;
    [protoEquationInspector inspectEquation:equation];
}

- (void)inspectProtoTransition:(MMTransition *)transition;
{
    [panel setTitle:@"Prototype Transition Inspector"];
    currentInspectorObject = transition;
    currentInspector = protoTransitionInspector;
    [protoTransitionInspector inspectTransition:transition];
}

- (void)inspectRule:(MMRule *)rule;
{
    [panel setTitle:@"Rule Inspector"];
    currentInspectorObject = rule;
    currentInspector = ruleInspector;
    [ruleInspector inspectRule:rule];
}

- (void)inspectPoint:(MMPoint *)point;
{
    [panel setTitle:@"Point Inspector"];
    currentInspectorObject = point;
    currentInspector = pointInspector;
    [pointInspector inspectPoint:point];
}

- (void)inspectPoints:(MonetList *)points;
{
    [panel setTitle:@"Point Inspector"];
    currentInspectorObject = points;
    currentInspector = pointInspector;
    [pointInspector inspectPoints:points];
}

- (void)inspectIntonationPoint:(IntonationPoint *)point;
{
    [intonationPointInspector inspectIntonationPoint:point];
}

@end
