
#import "Inspector.h"
#import "PhoneInspector.h"
#import "ProtoTemplateInspector.h"

@implementation Inspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [panel setFloatingPanel:YES];
	[phoneInspector applicationDidFinishLaunching:notification];
	[ruleInspector applicationDidFinishLaunching:notification];
	[pointInspector applicationDidFinishLaunching:notification];
	[protoEquationInspector applicationDidFinishLaunching:notification];
}

- window
{
	return mainInspectorWindow;
}

- (void)cleanInspectorWindow
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

- (void)setGeneralView:aView
{
	if (generalView != aView)
	{
		[generalView removeFromSuperview];
		[[mainInspectorWindow contentView] addSubview:aView];
		generalView = aView;
		[[mainInspectorWindow contentView] display];
		[mainInspectorWindow flushWindow];
	} 
}

- (void)setPopUpListView:aView
{
	if (popUpListView!=aView)
	{
		[popUpListView removeFromSuperview];
		[[mainInspectorWindow contentView] addSubview:aView];
		popUpListView = aView;
		[[mainInspectorWindow contentView] display];
		[mainInspectorWindow flushWindow];
	} 
}

- (void)inspectPhone:phone
{
	[panel setTitle:@"Phone Inspector"];
	currentInspectorObject = phone;
	currentInspector = phoneInspector;
	[phoneInspector inspectPhone:phone]; 
}

- (void)inspectCategory:category
{
	[panel setTitle:@"Category Inspector"];
	currentInspectorObject = category;
	currentInspector = categoryInspector;
	[categoryInspector inspectCategory:category]; 
}

- (void)inspectSymbol:symbol
{
	[panel setTitle:@"Symbol Inspector"];
	currentInspectorObject = symbol;
	currentInspector = symbolInspector;
	[symbolInspector inspectSymbol:symbol]; 
}

- (void)inspectParameter:parameter
{
	[panel setTitle:@"Parameter Inspector"];
	currentInspectorObject = parameter;
	currentInspector = parameterInspector;
	[parameterInspector inspectParameter:parameter]; 
}

- (void)inspectMetaParameter:metaParameter
{
	[panel setTitle:@"MetaParameter Inspector"];
	currentInspectorObject = metaParameter;
	currentInspector = parameterInspector;
	[parameterInspector inspectParameter:metaParameter]; 
}

- (void)beginEdittingCurrentInspector
{
	[mainInspectorWindow makeKeyAndOrderFront:self];
	[currentInspector beginEditting]; 
}

- (void)inspectProtoEquation:equation
{
	[panel setTitle:@"Prototype Equation Inspector"];
	currentInspectorObject = equation;
	currentInspector = protoEquationInspector;
	[protoEquationInspector inspectProtoEquation:equation]; 
}

- (void)inspectProtoTransition:transition
{
	[panel setTitle:@"Prototype Transition Inspector"];
	currentInspectorObject = transition;
	currentInspector = protoTransitionInspector;
	[protoTransitionInspector inspectProtoTemplate:transition]; 
}

- (void)inspectRule:rule
{
	[panel setTitle:@"Rule Inspector"];
	currentInspectorObject = rule;
	currentInspector = ruleInspector;
	[ruleInspector inspectRule:rule]; 
}

- (void)inspectPoint:point
{
	[panel setTitle:@"Point Inspector"];
	currentInspectorObject = point;
	currentInspector = pointInspector;
	[pointInspector inspectPoint:point]; 
}

- (void)inspectIntonationPoint:point
{

	[intonationPointInspector inspectIntonationPoint:point]; 
}


@end
