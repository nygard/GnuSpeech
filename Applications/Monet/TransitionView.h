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
    IBOutlet NSTextField *transitionNameTextField;

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
- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

- (void)drawGrid;
- (void)drawEquations;
- (void)drawPhones;
- (void)drawTransition;
- (void)drawSlopes;

- (void)mouseDown:(NSEvent *)mouseEvent;
- (void)mouseUp:(NSEvent *)mouseEvent;

- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

- getSlopeInput:aSlopeRatio:(float)startTime:(float)endTime;
- clickSlopeMarker:(float)row:(float)column:(float *)startTime:(float *)endTime;

//- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

- (IBAction)delete:(id)sender;
- (IBAction)groupInSlopeRatio:(id)sender;
- (IBAction)updateControlParameter:(id)sender;

// Publicly used API
- (void)setTransition:(ProtoTemplate *)newTransition;
- (void)showWindow:(int)otherWindow;

@end
