
#import <AppKit/NSView.h>
#import <AppKit/NSCursor.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSFont.h>
#import "EventList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface EventListView:NSView
{
	id	controller;

	/* Frame For Display */
	NSRect totalFrame;

	NSFont	*timesFont, *timesFontSmall;

	EventList *eventList;

	NSImage	*dotMarker;
	NSImage	*squareMarker;
	NSImage	*triangleMarker;
	NSImage	*selectionBox;

	id	niftyMatrixScrollView;
	id	niftyMatrix;

	id	mouseTimeField;
	id	mouseValueField;

	int	startingIndex;

	float	timeScale;

	int	mouseBeingDragged;

	int     trackTag;
}

- initWithFrame:(NSRect)frameRect;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)itemsChanged:sender;

- (BOOL) acceptsFirstResponder;

- (void)drawRect:(NSRect)rects;

- (void)setEventList:aList;

- (void)clearView;
- (void)drawGrid;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;
- (void)mouseMoved:(NSEvent *)theEvent;

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

- (void)updateScale:(float)column;



@end
