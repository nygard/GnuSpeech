
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

@interface IntonationView:NSView
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

	float	timeScale;

	int	mouseBeingDragged;

	MonetList	*intonationPoints;
	MonetList	*selectedPoints;

	id	utterance;
	id	smoothing;

}

- initWithFrame:(NSRect)frameRect;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (BOOL) acceptsFirstResponder;

- (void)drawRect:(NSRect)rects;

- (void)setEventList:aList;
- (void)setNewController:aController;
- controller;

- (void)setUtterance:newUtterance;
- (void)setSmoothing:smoothingSwitch;

- (void)addIntonationPoint:iPoint;

- (void)clearView;
- (void)drawGrid;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;
- (void)mouseMoved:(NSEvent *)theEvent;

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

- (void)updateScale:(float)column;

- (void)applyIntonation;
- (void)applyIntonationSmooth;
- (void)deletePoints;

- (void)saveIntonationContour:sender;
- (void)loadContour:sender;
- (void)loadContourAndUtterance:sender;

- (void)smoothPoints;
- (void)clearIntonationPoints;
- addPoint:(double) semitone offsetTime:(double) offsetTime slope:(double) slope ruleIndex:(int)ruleIndex eventList: anEventList;

@end
