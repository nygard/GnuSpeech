#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MModel, MMPoint, MonetList, MMTransition;
@class AppController, MMSlope;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface SpecialView : NSView
{
    IBOutlet AppController *controller;
    double _parameters[5];

    NSFont *timesFont;

    MMTransition *currentTemplate;

    MonetList *samplePhoneList;
    MonetList *displayPoints;
    int cache;

    MMPoint *selectedPoint;

    BOOL shouldDrawSelection;
    NSPoint selectionPoint1;
    NSPoint selectionPoint2;

    MModel *model;
}

+ (void)initialize;

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (void)_updateFromModel;

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
- (void)mouseDragged:(NSEvent *)mouseEvent;
- (void)mouseUp:(NSEvent *)mouseEvent;

// View geometry
- (int)sectionHeight;
- (NSPoint)graphOrigin;
- (float)timeScale;
- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

// Selection
- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

// Actions
- (IBAction)delete:(id)sender;

// Publicly used API
- (void)setTransition:(MMTransition *)newTransition;
- (void)showWindow:(int)otherWindow;

@end
