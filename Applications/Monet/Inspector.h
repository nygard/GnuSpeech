#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MMCategory, IntonationPoint, MMPoint, MonetList, MMParameter, MMPosture, MMEquation, MMTransition, MMRule, MMSymbol;
@class IntonationPointInspector, PointInspector, ProtoEquationInspector, ProtoTemplateInspector, RuleInspector;

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
    IBOutlet NSPanel *panel;
    IBOutlet NSBox *generalView;   /* General Box on Inspector Panel for Coordinates */
    IBOutlet NSBox *popUpListView;   /* View for PopUpList */
    IBOutlet NSBox *noInspectorView;  /* "No Inspector" Sign */
    IBOutlet NSBox *noPopUpListView;  /* "No Inspector" Sign */
    IBOutlet NSWindow *mainInspectorWindow;  /* Pointer to window */

    id currentInspectorObject;  /* Object with is currently the focus of the inspector */
    id currentInspector;

    IBOutlet ProtoEquationInspector *protoEquationInspector;
    IBOutlet ProtoTemplateInspector *protoTransitionInspector;
    IBOutlet RuleInspector *ruleInspector;
    IBOutlet PointInspector *pointInspector;
    IBOutlet IntonationPointInspector *intonationPointInspector;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)dealloc;

- (NSWindow *)window;

- (void)cleanInspectorWindow;
- (void)setGeneralView:(NSBox *)aView;
- (void)setPopUpListView:(NSBox *)aView;

- (void)beginEdittingCurrentInspector;

- (void)inspectEquation:(MMEquation *)equation;
- (void)inspectProtoTransition:(MMTransition *)transition;
- (void)inspectRule:(MMRule *)rule;

- (void)inspectPoint:(MMPoint *)point;
- (void)inspectPoints:(MonetList *)points;

- (void)inspectIntonationPoint:(IntonationPoint *)point;

@end
