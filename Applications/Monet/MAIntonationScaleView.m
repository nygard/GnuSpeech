//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MAIntonationScaleView.h"

#import <AppKit/AppKit.h>

@implementation MAIntonationScaleView

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    labelTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
    [labelTextFieldCell setFont:[NSFont labelFontOfSize:10.0]];
    [labelTextFieldCell setAlignment:NSRightTextAlignment];

    sectionCount = 20;
    sectionHeight = 10;
    zeroSection = 10;
    yOrigin = 0;

    return self;
}

- (void)dealloc;
{
    [labelTextFieldCell release];

    [super dealloc];
}

- (int)sectionCount;
{
    return sectionCount;
}

- (void)setSectionCount:(int)newSectionCount;
{
    if (newSectionCount == sectionCount)
        return;

    sectionCount = newSectionCount;
    [self setNeedsDisplay:YES];
}

- (int)sectionHeight;
{
    return sectionHeight;
}

- (void)setSectionHeight:(int)newSectionHeight;
{
    if (newSectionHeight == sectionHeight)
        return;

    sectionHeight = newSectionHeight;
    [self setNeedsDisplay:YES];
}

- (int)zeroSection;
{
    return zeroSection;
}

- (void)setZeroSection:(int)newZeroSection;
{
    if (newZeroSection == zeroSection)
        return;

    zeroSection = newZeroSection;
    [self setNeedsDisplay:YES];
}

- (int)yOrigin;
{
    return yOrigin;
}

- (void)setYOrigin:(int)newYOrigin;
{
    if (newYOrigin == yOrigin)
        return;

    yOrigin = newYOrigin;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect;
{
    NSBezierPath *bezierPath;
    NSRect bounds, cellFrame;
    NSPoint point;
    unsigned int index;

    [[NSColor whiteColor] set];
    NSRectFill(rect);

    bounds = [self bounds];

    cellFrame.origin.x = 0;
    cellFrame.origin.y = 0;
    cellFrame.size.width = bounds.size.width - 10.0;
    cellFrame.size.height = 12.0;

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2.0];
    [bezierPath setLineCapStyle:NSSquareLineCapStyle];

    point.x = NSMaxX(bounds) - 1.0;
    point.y = yOrigin;
    //NSLog(@"point1: %@", NSStringFromPoint(point));
    [bezierPath moveToPoint:point];

    point.y += sectionCount * sectionHeight;
    //NSLog(@"point2: %@", NSStringFromPoint(point));
    [bezierPath lineToPoint:point];

    [[NSColor blackColor] set];
    [bezierPath stroke];
    [bezierPath release];

    bezierPath = [[NSBezierPath alloc] init];
    for (index = 0; index <= sectionCount; index++) {
        point.x = NSMaxX(bounds);
        point.y = yOrigin + index * sectionHeight + 0.5;
        [bezierPath moveToPoint:point];

        point.x -= 5.0;
        [bezierPath lineToPoint:point];

        cellFrame.origin.y = point.y - 5.0;
        [labelTextFieldCell setIntValue:index - zeroSection];
        [labelTextFieldCell drawWithFrame:cellFrame inView:self];
    }

    [bezierPath stroke];
    [bezierPath release];
}

@end
