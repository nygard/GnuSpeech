#import <AppKit/NSView.h>

@class MonetList, ProtoTemplate;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface SpecialView : NSView
{
    id controller;

    /* Frame For Display */
    NSRect totalFrame;

    id displayParameters;

    NSFont *timesFont;

    NSImage *dotMarker;
    NSImage *squareMarker;
    NSImage *triangleMarker;
    NSImage *selectionBox;

    ProtoTemplate *currentTemplate;

    MonetList *dummyPhoneList;
    MonetList *displayPoints;
    int cache;

    id selectedPoint;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (BOOL)acceptsFirstResponder;
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;

- (void)drawRect:(NSRect)rect;

- (void)clearView;
- (void)drawGrid;
- (void)drawEquations;
- (void)drawPhones;
- (void)drawTransition;

- (void)setTransition:newTransition;

- (void)mouseDown:(NSEvent *)theEvent;
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;
- (void)showWindow:(int)otherWindow;

- (void)delete:(id)sender;

@end
