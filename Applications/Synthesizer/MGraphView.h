//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSView.h>

@interface MGraphView : NSView
{
    float sideMargin;
    float topMargin;

    double minYValue;
    double maxYValue;
}

- (id)initWithFrame:(NSRect)frameRect;

- (float)sideMargin;
- (void)setSideMargin:(float)newSideMargin;

- (float)topMargin;
- (void)setTopMargin:(float)newTopMargin;

- (double)minYValue;
- (void)setMinYValue:(double)newMinYValue;

- (double)maxYValue;
- (void)setMaxYValue:(double)newMaxYValue;

- (NSRect)activeRect;

- (void)drawRect:(NSRect)rect;

- (void)drawValues:(double *)values count:(unsigned int)count;

@end
