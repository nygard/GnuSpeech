//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MWaveShapeView.h"

@implementation MWaveShapeView

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    riseTime = 40.0;
    minimumFallTime = 12.0;
    maximumFallTime = 32.0;

    // TODO (2004-08-30): This seems backwards to me -- with amplitude of 1.0 the fall time is minimum...  But perhaps this is correct, since less amplitude flattens out the pulse.
    minimumWavetable = TRMWavetableCreate(TRMWaveformTypePulse, riseTime, minimumFallTime, maximumFallTime, 11025.0);
    TRMWavetableUpdate(minimumWavetable, 1.0);
    maximumWavetable = TRMWavetableCreate(TRMWaveformTypePulse, riseTime, minimumFallTime, maximumFallTime, 11025.0);
    TRMWavetableUpdate(maximumWavetable, 0.0);

    NSLog(@"minimumWavetable: %p, maximumWavetable: %p", minimumWavetable, maximumWavetable);

    return self;
}

- (void)dealloc;
{
    if (minimumWavetable != NULL)
        TRMWavetableFree(minimumWavetable);

    if (maximumWavetable != NULL)
        TRMWavetableFree(maximumWavetable);

    [super dealloc];
}

- (double)riseTime;
{
    return riseTime;
}

- (void)setRiseTime:(double)newRiseTime;
{
    riseTime = newRiseTime;

    TRMWavetableSetRiseTime(minimumWavetable, riseTime);
    TRMWavetableSetRiseTime(maximumWavetable, riseTime);

    [self setNeedsDisplay:YES];
}

- (double)minimumFallTime;
{
    return minimumFallTime;
}

- (void)setMinimumFallTime:(double)newMinimumFallTime;
{
    minimumFallTime = newMinimumFallTime;

    TRMWavetableSetMinimumFallTime(minimumWavetable, minimumFallTime);

    [self setNeedsDisplay:YES];
}

- (double)maximumFallTime;
{
    return maximumFallTime;
}

- (void)setMaximumFallTime:(double)newMaximumFallTime;
{
    maximumFallTime = newMaximumFallTime;

    TRMWavetableSetMaximumFallTime(maximumWavetable, maximumFallTime);

    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect;
{
    NSRect activeRect;
    NSBezierPath *path;
    NSPoint point;
    float x;
    unsigned int count, index;
    double *values;

    [super drawRect:rect];

    activeRect = [self activeRect];

    path = [[NSBezierPath alloc] init];

    // Draw end of rise time
    point.x = activeRect.origin.x + (riseTime / 100.0) * activeRect.size.width;
    point.y = NSMinY(activeRect);
    [path moveToPoint:point];

    point.y = NSMaxY(activeRect);
    [path lineToPoint:point];

    // Draw end of minimum fall time
    point.x = activeRect.origin.x + (((riseTime + minimumFallTime) / 100.0)) * activeRect.size.width;
    point.y = NSMinY(activeRect);
    [path moveToPoint:point];

    point.y = NSMaxY(activeRect);
    [path lineToPoint:point];

    // draw end of maximum fall time
    point.x = activeRect.origin.x + (((riseTime + maximumFallTime) / 100.0)) * activeRect.size.width;
    point.y = NSMinY(activeRect);
    [path moveToPoint:point];

    point.y = NSMaxY(activeRect);
    [path lineToPoint:point];

    [[NSColor lightGrayColor] set];
    [path stroke];
    [path release];

    // Draw minimum fall time wave shape
    path = [[NSBezierPath alloc] init];

    values = minimumWavetable->wavetable;
    count = TRMWavetableLength(minimumWavetable);
    point.x = activeRect.origin.x;
    point.y = activeRect.origin.y + values[0] * activeRect.size.height;
    [path moveToPoint:point];
    for (index = 1; index < count; index++) {
        point.x = activeRect.origin.x + index * activeRect.size.width / count;
        point.y = activeRect.origin.y + values[index] * activeRect.size.height;
        [path lineToPoint:point];
    }

    [[NSColor blackColor] set];
    [path stroke];
    [path release];

    // Draw maximum fall time wave shape
    path = [[NSBezierPath alloc] init];

    values = maximumWavetable->wavetable;
    count = TRMWavetableLength(maximumWavetable);
    point.x = activeRect.origin.x;
    point.y = activeRect.origin.y + values[0] * activeRect.size.height;
    [path moveToPoint:point];
    for (index = 1; index < count; index++) {
        point.x = activeRect.origin.x + index * activeRect.size.width / count;
        point.y = activeRect.origin.y + values[index] * activeRect.size.height;
        [path lineToPoint:point];
    }

    [[NSColor blackColor] set];
    //[[NSColor blueColor] set];
    [path stroke];
    [path release];
}

@end
