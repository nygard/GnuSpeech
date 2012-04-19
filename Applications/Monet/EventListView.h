//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet
#import <AppKit/NSTextField.h>
#import <Foundation/NSNotification.h>

@class NSTextFieldCell;
@class EventList;
@class AppController;

@interface EventListView : NSView
{
    NSFont *timesFont;
    NSFont *timesFontSmall;

    EventList *eventList;

	NSTextField *mouseTimeField;
	NSTextField *mouseValueField;

    int startingIndex;
    float timeScale;
    BOOL mouseBeingDragged;
    NSTrackingRectTag trackTag;

    NSTextFieldCell *ruleCell;
    NSTextFieldCell *minMaxCell;
    NSTextFieldCell *parameterNameCell;

    NSArray *displayParameters;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)awakeFromNib;

- (NSArray *)displayParameters;
- (void)setDisplayParameters:(NSArray *)newDisplayParameters;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:(EventList *)newEventList;

- (BOOL)isOpaque;
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

- (float)scaledX:(float)x;
- (float)scaledWidth:(float)width;

- (float)parameterValueForYCoord:(float)y;

// Handle sizing and correct drawing of the main view.
- (void)resize;
- (float)minimumWidth;
- (float)minimumHeight;
- (float)scaleWidth:(float)width;
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize;

// Allow access to mouse tracking fields.
- (void)setMouseTimeField:(NSTextField *)mtField;
- (void)setMouseValueField:(NSTextField *)mvField;

@end
