#import <AppKit/NSView.h>

@class EventList;
@class AppController;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface EventListView : NSView
{
    AppController *controller;

    /* Frame For Display */
    NSRect totalFrame;

    NSFont *timesFont;
    NSFont *timesFontSmall;

    EventList *eventList;

    NSImage *dotMarker;
    NSImage *squareMarker;
    NSImage *triangleMarker;
    NSImage *selectionBox;

    id niftyMatrixScrollView;
    id niftyMatrix;

    id mouseTimeField;
    id mouseValueField;

    int startingIndex;
    float timeScale;
    int mouseBeingDragged;
    int trackTag;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)itemsChanged:sender;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:aList;

- (void)drawRect:(NSRect)rects;

- (void)clearView;
- (void)drawGrid;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;
- (void)mouseMoved:(NSEvent *)theEvent;

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

- (void)updateScale:(float)column;

@end
