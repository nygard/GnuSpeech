#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MonetList, ProtoTemplate;
@class AppController;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface TransitionView : NSView
{
    IBOutlet AppController *controller;
    IBOutlet NSForm *displayParameters;

    NSRect totalFrame; // Frame for display
    NSFont *timesFont;

    ProtoTemplate *currentTemplate;

    MonetList *dummyPhoneList;
    MonetList *displayPoints;
    MonetList *displaySlopes;
    MonetList *selectedPoints;
    int cache;

    BOOL shouldDrawSelection;
    NSPoint selectionPoint1;
    NSPoint selectionPoint2;
}

+ (void)initialize;

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (BOOL)acceptsFirstResponder;
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;

- (BOOL)shouldDrawSelection;
- (void)setShouldDrawSelection:(BOOL)newFlag;

- (void)drawRect:(NSRect)rect;

- (void)clearView;

// View geometry
- (int)sectionHeight;
- (NSPoint)graphOrigin;
- (float)timeScale;

- (void)drawGrid;
- (void)drawEquations;
- (void)drawPhones;
- (void)drawTransition;
- (void)drawSlopes;

- (void)mouseDown:(NSEvent *)mouseEvent;
- (void)mouseUp:(NSEvent *)mouseEvent;

- getSlopeInput:aSlopeRatio:(float)startTime:(float)endTime;
- clickSlopeMarker:(float)row:(float)column:(float *)startTime:(float *)endTime;

//- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

- (void)delete:(id)sender;
- (void)groupInSlopeRatio:sender;

// Publicly used API
- (void)setTransition:newTransition;
- (void)showWindow:(int)otherWindow;

@end
