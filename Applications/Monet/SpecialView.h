//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TransitionView.h"

@interface SpecialView : TransitionView

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

// Drawing
- (void)drawGrid;
- (void)updateDisplayPoints;
- (void)highlightSelectedPoints;

// Event handling
//- (void)mouseDown:(NSEvent *)mouseEvent;

// Selection
- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

@end
