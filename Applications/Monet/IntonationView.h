#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class EventList, IntonationPoint, MonetList;
@class AppController;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface IntonationView : NSView
{
    IBOutlet AppController *controller;

    NSFont *timesFont;
    NSFont *timesFontSmall;

    EventList *eventList;

    float timeScale;
    int mouseBeingDragged;

    MonetList *intonationPoints;
    MonetList *selectedPoints;

    NSTextField *utterance;
    NSButton *smoothing;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:(EventList *)newEventList;

- (AppController *)controller;
- (void)setNewController:(AppController *)newController;

- (void)setUtterance:(NSTextField *)newUtterance;
- (void)setSmoothing:(NSButton *)smoothingSwitch;

- (void)addIntonationPoint:(IntonationPoint *)iPoint;

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
- (void)mouseExited:(NSEvent *)theEvent;
- (void)mouseMoved:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;

- (void)updateScale:(float)column;

- (void)applyIntonation;
- (void)applyIntonationSmooth;
- (void)deletePoints;

- (IBAction)saveIntonationContour:(id)sender;
- (IBAction)loadContour:(id)sender;
- (IBAction)loadContourAndUtterance:(id)sender;

- (void)clearIntonationPoints;
- (void)addPoint:(double)semitone offsetTime:(double)offsetTime slope:(double)slope ruleIndex:(int)ruleIndex eventList:anEventList;

// Ugh, these should be in shared superclass, or somewhere else.
- (void)drawCircleMarkerAtPoint:(NSPoint)aPoint;
- (void)drawTriangleMarkerAtPoint:(NSPoint)aPoint;
- (void)drawSquareMarkerAtPoint:(NSPoint)aPoint;
- (void)highlightMarkerAtPoint:(NSPoint)aPoint;

// View geometry
- (int)sectionHeight;
- (NSPoint)graphOrigin;

- (NSString *)contourString;
- (void)appendXMLForContourToString:(NSMutableString *)resultString level:(int)level;

@end
