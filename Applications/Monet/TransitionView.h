#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MonetList, ProtoTemplate;
@class AppController, Slope;

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

    Slope *editingSlope;
    NSTextFieldCell *textFieldCell;
    NSText *nonretained_fieldEditor;
}

+ (void)initialize;

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (BOOL)shouldDrawSelection;
- (void)setShouldDrawSelection:(BOOL)newFlag;

// Drawing
- (void)drawRect:(NSRect)rect;

- (void)clearView;
- (void)drawGrid;
- (void)drawEquations;
- (void)drawPhones;
- (void)drawTransition;

- (void)drawCircleMarkerAtPoint:(NSPoint)aPoint;
- (void)drawTriangleMarkerAtPoint:(NSPoint)aPoint;
- (void)drawSquareMarkerAtPoint:(NSPoint)aPoint;
- (void)highlightMarkerAtPoint:(NSPoint)aPoint;

// Event handling
- (BOOL)acceptsFirstResponder;
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)mouseEvent;
- (void)mouseUp:(NSEvent *)mouseEvent;

// View geometry
- (int)sectionHeight;
- (NSPoint)graphOrigin;
- (float)timeScale;
- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
- (float)slopeMarkerYPosition;
- (NSRect)slopeMarkerRect;

// Slopes
- (void)drawSlopes;
- (void)_setEditingSlope:(Slope *)newSlope;
- (void)editSlope:(Slope *)aSlope startTime:(float)startTime endTime:(float)endTime;
- (Slope *)getSlopeMarkerAtPoint:(NSPoint)aPoint startTime:(float *)startTime endTime:(float *)endTime;

// NSTextView delegate method, used for editing slopes
- (void)textDidEndEditing:(NSNotification *)notification;

// Selection
- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

// Actions
- (IBAction)delete:(id)sender;
- (IBAction)groupInSlopeRatio:(id)sender;
- (IBAction)updateControlParameter:(id)sender;

// Publicly used API
- (void)setTransition:(ProtoTemplate *)newTransition;
- (void)showWindow:(int)otherWindow;

@end
