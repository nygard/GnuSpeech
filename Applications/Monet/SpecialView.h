#import "TransitionView.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MModel, MMPoint, MonetList, MMTransition;
@class AppController, MMSlope;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface SpecialView : TransitionView
{
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

// Drawing
- (void)drawGrid;
- (void)drawTransition;
- (void)highlightSelectedPoints;

// Event handling
//- (void)mouseDown:(NSEvent *)mouseEvent;

// View geometry
- (int)sectionHeight;
- (NSPoint)graphOrigin;
- (float)timeScale;

// Selection
- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

@end
