#import <AppKit/NSView.h>

@class GSMPoint, MonetList, ProtoTemplate;
@class AppController;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface SpecialView : NSView
{
    AppController *controller;

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
    MonetList *displayPoints; // Contains GSMPoints
    int cache;

    GSMPoint *selectedPoint;
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

- (void)setTransition:(ProtoTemplate *)newTransition;

- (void)mouseDown:(NSEvent *)theEvent;
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;
- (void)showWindow:(int)otherWindow;

- (void)delete:(id)sender;

@end
