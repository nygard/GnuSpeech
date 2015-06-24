//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class EventList, MMIntonationPoint;
@class MAIntonationScaleView;

@protocol MAIntonationViewNotification
- (void)intonationViewSelectionDidChange:(NSNotification *)notification;
@end

extern NSString *MAIntonationViewSelectionDidChangeNotification;

@interface MAIntonationView : NSView

- (id)initWithFrame:(NSRect)frameRect;

- (void)setScaleView:(MAIntonationScaleView *)newScaleView;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:(EventList *)newEventList;

- (BOOL)shouldDrawSelection;
- (void)setShouldDrawSelection:(BOOL)newFlag;

- (BOOL)shouldDrawSmoothPoints;
- (void)setShouldDrawSmoothPoints:(BOOL)newFlag;

@property (weak) id delegate;

- (CGFloat)minimumWidth;
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize;
- (void)resizeWidth;

- (void)drawRect:(NSRect)rect;

- (void)drawGrid;
- (void)drawHorizontalScale;
- (void)drawPostureLabels;
- (void)drawRules;
- (void)drawRuleBackground;
- (void)drawIntonationPoints;
- (void)drawSmoothPoints;

// Event handling
- (void)mouseEntered:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;
- (void)mouseDown:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

// Actions
- (IBAction)selectAll:(id)sender;
- (IBAction)delete:(id)sender;


- (void)updateScale:(float)column;

- (void)deselectAllPoints;

- (MMIntonationPoint *)selectedIntonationPoint;
- (void)selectIntonationPoint:(MMIntonationPoint *)intonationPoint;
- (void)_selectionDidChange;

// View geometry
- (CGFloat)sectionHeight;
- (NSPoint)graphOrigin;

- (void)updateEvents;


- (CGFloat)scaleXPosition:(CGFloat)xPosition;
- (CGFloat)scaleWidth:(CGFloat)width;
- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

- (CGFloat)convertYPositionToSemitone:(CGFloat)yPosition;
- (CGFloat)convertXPositionToTime:(CGFloat)xPosition;

- (void)intonationPointDidChange:(NSNotification *)notification;
- (void)removeOldSelectedPoints;

- (void)setFrame:(NSRect)newFrame;

@end
