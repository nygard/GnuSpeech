#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSTextFieldCell;
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
    IBOutlet AppController *controller;

    NSFont *timesFont;
    NSFont *timesFontSmall;

    EventList *eventList;

    IBOutlet NSTextField *mouseTimeField;
    IBOutlet NSTextField *mouseValueField;

    int startingIndex;
    float timeScale;
    int mouseBeingDragged;
    NSTrackingRectTag trackTag;

    NSTextFieldCell *ruleCell;

    NSArray *displayParameters;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)awakeFromNib;

- (NSArray *)displayParameters;
- (void)setDisplayParameters:(NSArray *)newDisplayParameters;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:(EventList *)newEventList;

- (void)drawRect:(NSRect)rects;

- (void)clearView;
- (void)drawGrid;
- (void)drawRules;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;
- (void)mouseMoved:(NSEvent *)theEvent;

- (void)updateScale:(float)column;

- (void)frameDidChange:(NSNotification *)aNotification;
- (void)resetTrackingRect;

@end
