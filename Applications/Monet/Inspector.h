#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class CategoryInspector, IntonationPointInspector, ParameterInspector, PhoneInspector, PointInspector, ProtoEquationInspector, RuleInspector, SymbolInspector;

/*===========================================================================

Author: Craig-Richard Taube-Schock
Copyright (c) 1994, Trillium Sound Research Incorporated.
All Rights Reserved.

=============================================================================

	Object: Inspector
	Purpose: Oversees the functioning of the Inspector Panel

	Date: March 23, 1994

History:
	March 23, 1994
		Integrated into MONET.

===========================================================================*/

@interface Inspector : NSObject
{
    id	panel;
    id	generalView;			/* General Box on Inspector Panel for Coordinates */
    id	popUpListView;			/* View for PopUpList */
    id	noInspectorView;		/* "No Inspector" Sign */
    id	noPopUpListView;		/* "No Inspector" Sign */
    id	mainInspectorWindow;		/* Pointer to window */

    id	currentInspectorObject;		/* Object with is currently the focus of the inspector */
    id	currentInspector;

    PhoneInspector *phoneInspector;
    CategoryInspector *categoryInspector;
    ParameterInspector *parameterInspector;
    ParameterInspector *metaParameterInspector;
    SymbolInspector *symbolInspector;
    ProtoEquationInspector *protoEquationInspector;
    id protoTransitionInspector;
    RuleInspector *ruleInspector;
    PointInspector *pointInspector;
    IntonationPointInspector *intonationPointInspector;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (NSWindow *)window;

- (void)cleanInspectorWindow;
- (void)setGeneralView:aView;
- (void)setPopUpListView:aView;

- (void)inspectPhone:phone;
- (void)inspectCategory:category;
- (void)inspectSymbol:symbol;
- (void)inspectParameter:parameter;
- (void)inspectMetaParameter:metaParameter;

- (void)beginEdittingCurrentInspector;

- (void)inspectProtoEquation:equation;
- (void)inspectProtoTransition:transition;
- (void)inspectRule:rule;

- (void)inspectPoint:point;
- (void)inspectIntonationPoint:point;


@end
