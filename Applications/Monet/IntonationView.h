#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class EventList, IntonationPoint;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@protocol IntonationViewNotification
- (void)intonationViewSelectionDidChange:(NSNotification *)aNotification;
@end

extern NSString *IntonationViewSelectionDidChangeNotification;

@interface IntonationView : NSView
{
    NSFont *timesFont;
    NSFont *timesFontSmall;

    EventList *eventList;

    float timeScale;
    int mouseBeingDragged;

    NSMutableArray *selectedPoints;

    BOOL shouldDrawSmoothPoints;

    id nonretained_delegate;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:(EventList *)newEventList;

- (BOOL)shouldDrawSmoothPoints;
- (void)setShouldDrawSmoothPoints:(BOOL)newFlag;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

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

- (IntonationPoint *)selectedIntonationPoint;
- (void)selectIntonationPoint:(IntonationPoint *)anIntonationPoint;
- (void)_selectionDidChange;

// View geometry
- (int)sectionHeight;
- (NSPoint)graphOrigin;

@end
