//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MGraphView.h"

#import <AppKit/AppKit.h>

@implementation MGraphView

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    sideMargin = 10.0;
    topMargin = 10.0;

    return self;
}

- (float)sideMargin;
{
    return sideMargin;
}

- (void)setSideMargin:(float)newSideMargin;
{
    if (newSideMargin == sideMargin)
        return;

    sideMargin = newSideMargin;
    [self setNeedsDisplay:YES];
}

- (float)topMargin;
{
    return topMargin;
}

- (void)setTopMargin:(float)newTopMargin;
{
    if (newTopMargin == topMargin)
        return;

    topMargin = newTopMargin;
    [self setNeedsDisplay:YES];
}

- (NSRect)activeRect;
{
    return NSInsetRect([self bounds], sideMargin, topMargin);
}

- (void)drawRect:(NSRect)rect;
{
    NSRect bounds, activeRect;

    bounds = [self bounds];

    [[NSColor whiteColor] set];
    NSRectFill(rect);

    [[NSColor blackColor] set];
    NSFrameRect(bounds);

    activeRect = [self activeRect];
    [[NSColor lightGrayColor] set];
    NSFrameRect(activeRect);
}

@end
