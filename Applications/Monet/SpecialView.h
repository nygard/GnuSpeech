
#import <AppKit/NSView.h>
#import <AppKit/NSCursor.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSFont.h>
#import <Foundation/NSArray.h>
#import "ProtoTemplate.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface SpecialView:NSView
{
	id	controller;

	/* Frame For Display */
	NSRect totalFrame;

	id	displayParameters;

	NSFont	*timesFont;

	NSImage	*dotMarker;
	NSImage	*squareMarker;
	NSImage	*triangleMarker;
	NSImage	*selectionBox;

	ProtoTemplate *currentTemplate;

	MonetList	*dummyPhoneList;
	MonetList	*displayPoints;
	int	cache;

	id	selectedPoint;

}

- initWithFrame:(NSRect)frameRect;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (BOOL) acceptsFirstResponder;
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;

- (void)drawRect:(NSRect)rects;

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
