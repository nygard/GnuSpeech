#import <AppKit/NSView.h>

@class EventList, MonetList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface IntonationView : NSView
{
    id controller;

    /* Frame For Display */
    NSRect totalFrame;

    NSFont *timesFont;
    NSFont *timesFontSmall;

    EventList *eventList;

    NSImage *dotMarker;
    NSImage *squareMarker;
    NSImage *triangleMarker;
    NSImage *selectionBox;

    float timeScale;

    int mouseBeingDragged;

    MonetList *intonationPoints;
    MonetList *selectedPoints;

    id utterance;
    id smoothing;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:aList;
- (void)setNewController:aController;
- controller;

- (void)setUtterance:newUtterance;
- (void)setSmoothing:smoothingSwitch;

- (void)addIntonationPoint:iPoint;

- (void)drawRect:(NSRect)rect;

- (void)clearView;

- (void)mouseEntered:(NSEvent *)theEvent;
- (void)keyDown:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;
- (void)mouseMoved:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

- (void)updateScale:(float)column;
- (void)drawGrid;

- (void)applyIntonation;
- (void)applyIntonationSmooth;
- (void)deletePoints;

- (void)saveIntonationContour:sender;
- (void)loadContour:sender;
- (void)loadContourAndUtterance:sender;

- (void)smoothPoints;
- (void)clearIntonationPoints;
- (void)addPoint:(double)semitone offsetTime:(double)offsetTime slope:(double)slope ruleIndex:(int)ruleIndex eventList:anEventList;

@end
