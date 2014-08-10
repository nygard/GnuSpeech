//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class EventList;
@class AppController;

@interface EventListView : NSView

- (NSArray *)displayParameters;
- (void)setDisplayParameters:(NSArray *)newDisplayParameters;

- (void)setEventList:(EventList *)newEventList;

- (void)clearView;
- (void)drawGrid;
- (void)drawRules;

- (void)updateScale:(CGFloat)column;

- (void)frameDidChange:(NSNotification *)notification;
- (void)resetTrackingRect;

- (CGFloat)scaledX:(CGFloat)x;
- (CGFloat)scaledWidth:(CGFloat)width;

- (CGFloat)parameterValueForYCoord:(CGFloat)y;

// Handle sizing and correct drawing of the main view.
- (void)resize;
- (CGFloat)minimumWidth;
- (CGFloat)minimumHeight;
- (CGFloat)scaleWidth:(CGFloat)width;
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize;

// Allow access to mouse tracking fields.
- (void)setMouseTimeField:(NSTextField *)mtField;
- (void)setMouseValueField:(NSTextField *)mvField;

@end
