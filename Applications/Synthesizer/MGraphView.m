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

    minYValue = 0.0;
    maxYValue = 1.0;

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

- (double)minYValue;
{
    return minYValue;
}

- (void)setMinYValue:(double)newMinYValue;
{
    minYValue = newMinYValue;
    [self setNeedsDisplay:YES];
}

- (double)maxYValue;
{
    return maxYValue;
}

- (void)setMaxYValue:(double)newMaxYValue;
{
    maxYValue = newMaxYValue;
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

    [[NSColor lightGrayColor] set];
    NSFrameRect(bounds);

    activeRect = [self activeRect];
    [[NSColor lightGrayColor] set];
    NSFrameRect(activeRect);
}

- (void)drawValues:(double *)values count:(unsigned int)count;
{
    NSBezierPath *path;
    unsigned int index;
    NSRect activeRect;
    NSPoint point;
    float yRange;

    NSLog(@" > %s", _cmd);
    NSLog(@"values: %p, count: %d", values, count);

    if (count == 0)
        return;

    yRange = maxYValue - minYValue;
    NSLog(@"minYValue: %f, maxYValue: %f, yRange: %f", minYValue, maxYValue, yRange);
    activeRect = [self activeRect];
    path = [[NSBezierPath alloc] init];

    point.x = activeRect.origin.x;
    point.y = activeRect.origin.y + (values[0] / yRange) * activeRect.size.height;
    [path moveToPoint:point];

    for (index = 1; index < count; index++) {
        point.x = activeRect.origin.x + index * activeRect.size.width / count;
        point.y = activeRect.origin.y + (values[index] / yRange) * activeRect.size.height;
        [path lineToPoint:point];
    }

    [path stroke];
    [path release];

    NSLog(@"<  %s", _cmd);
}

@end
