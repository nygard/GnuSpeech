#import "Inspector.h"

#import <AppKit/AppKit.h>
#import "CategoryInspector.h"
#import "IntonationPointInspector.h"
#import "ParameterInspector.h"
#import "PhoneInspector.h"
#import "PointInspector.h"
#import "ProtoEquationInspector.h"
#import "ProtoTemplateInspector.h"
#import "RuleInspector.h"
#import "SymbolInspector.h"

@implementation Inspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [panel setFloatingPanel:YES];

    [noInspectorView retain];
    [noPopUpListView retain];

    [phoneInspector applicationDidFinishLaunching:notification];
    [categoryInspector applicationDidFinishLaunching:notification];
    [parameterInspector applicationDidFinishLaunching:notification];
    [metaParameterInspector applicationDidFinishLaunching:notification];
    [symbolInspector applicationDidFinishLaunching:notification];
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

- (void)inspectPhone:(MMPosture *)phone;
{
    [panel setTitle:@"Phone Inspector"];
    currentInspectorObject = phone;
    currentInspector = phoneInspector;
    [phoneInspector inspectPhone:phone];
}

- (void)inspectCategory:(MMCategory *)category;
{
    [panel setTitle:@"Category Inspector"];
    currentInspectorObject = category;
    currentInspector = categoryInspector;
    [categoryInspector inspectCategory:category];
}

- (void)inspectSymbol:(MMSymbol *)symbol;
{
    [panel setTitle:@"Symbol Inspector"];
    currentInspectorObject = symbol;
    currentInspector = symbolInspector;
    [symbolInspector inspectSymbol:symbol];
}

- (void)inspectParameter:(MMParameter *)parameter;
{
    [panel setTitle:@"Parameter Inspector"];
    currentInspectorObject = parameter;
    currentInspector = parameterInspector;
    [parameterInspector inspectParameter:parameter];
}

- (void)inspectMetaParameter:(MMParameter *)metaParameter;
{
    [panel setTitle:@"MetaParameter Inspector"];
    currentInspectorObject = metaParameter;
    currentInspector = parameterInspector;
    [parameterInspector inspectParameter:metaParameter];
}

- (void)beginEdittingCurrentInspector;
{
    [mainInspectorWindow makeKeyAndOrderFront:self];
    [currentInspector beginEditting];
}

- (void)inspectMMEquation:(MMEquation *)equation;
{
    [panel setTitle:@"Prototype Equation Inspector"];
    currentInspectorObject = equation;
    currentInspector = protoEquationInspector;
    [protoEquationInspector inspectMMEquation:equation];
}

- (void)inspectProtoTransition:(MMTransition *)transition;
{
    [panel setTitle:@"Prototype Transition Inspector"];
    currentInspectorObject = transition;
    currentInspector = protoTransitionInspector;
    [protoTransitionInspector inspectMMTransition:transition];
}

- (void)inspectRule:(Rule *)rule;
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
