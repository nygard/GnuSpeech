#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class EventList, IntonationPoint;
@class AppController;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface IntonationView : NSView
{
    IBOutlet AppController *controller;

    NSFont *timesFont;
    NSFont *timesFontSmall;

    EventList *eventList;

    float timeScale;
    int mouseBeingDragged;

    NSMutableArray *selectedPoints;

    BOOL shouldDrawSmoothPoints;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:(EventList *)newEventList;

- (AppController *)controller;
- (void)setNewController:(AppController *)newController;

- (BOOL)shouldDrawSmoothPoints;
- (void)setShouldDrawSmoothPoints:(BOOL)newFlag;

- (void)drawRect:(NSRect)rect;

- (void)drawBackground;
- (void)drawGrid;
- (void)drawPhoneLabels;
- (void)drawRules;
- (void)drawIntonationPoints;
- (void)drawSmoothPoints;

// Event handling
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)keyDown:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;

- (void)updateScale:(float)column;

- (void)deselectAllPoints;
- (void)deletePoints;

// View geometry
- (int)sectionHeight;
- (NSPoint)graphOrigin;

@end
