#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class CategoryNode, GSMPoint, IntonationPoint, MonetList, Parameter, Phone, ProtoEquation, ProtoTemplate, Rule, Symbol;
@class CategoryInspector, IntonationPointInspector, ParameterInspector, PhoneInspector, PointInspector, ProtoEquationInspector, ProtoTemplateInspector, RuleInspector, SymbolInspector;

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

    IBOutlet PhoneInspector *phoneInspector;
    IBOutlet CategoryInspector *categoryInspector;
    IBOutlet ParameterInspector *parameterInspector;
    IBOutlet ParameterInspector *metaParameterInspector;
    IBOutlet SymbolInspector *symbolInspector;
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

- (void)inspectPhone:(Phone *)phone;
- (void)inspectCategory:(CategoryNode *)category;
- (void)inspectSymbol:(Symbol *)symbol;
- (void)inspectParameter:(Parameter *)parameter;
- (void)inspectMetaParameter:(Parameter *)metaParameter;

- (void)beginEdittingCurrentInspector;

- (void)inspectProtoEquation:(ProtoEquation *)equation;
- (void)inspectProtoTransition:(ProtoTemplate *)transition;
- (void)inspectRule:(Rule *)rule;

- (void)inspectPoint:(GSMPoint *)point;
- (void)inspectPoints:(MonetList *)points;

- (void)inspectIntonationPoint:(IntonationPoint *)point;

@end
