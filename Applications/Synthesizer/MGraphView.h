//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSView.h>

@interface MGraphView : NSView
{
    float sideMargin;
    float topMargin;
}

- (id)initWithFrame:(NSRect)frameRect;

- (float)sideMargin;
- (void)setSideMargin:(float)newSideMargin;

- (float)topMargin;
- (void)setTopMargin:(float)newTopMargin;

- (NSRect)activeRect;

- (void)drawRect:(NSRect)rect;

@end
