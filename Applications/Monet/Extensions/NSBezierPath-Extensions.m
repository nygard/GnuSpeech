//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "NSBezierPath-Extensions.h"

@implementation NSBezierPath (Extensions)

+ (void)drawCircleMarkerAtPoint:(NSPoint)point;
{
    CGFloat radius = 3;
    NSBezierPath *bezierPath;

    //NSLog(@"->%s, point: %@", _cmd, NSStringFromPoint(aPoint));
    point.x = rint(point.x);
    point.y = rint(point.y);
    //NSLog(@"-->%s, point: %@", _cmd, NSStringFromPoint(aPoint));

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath appendBezierPathWithArcWithCenter:point radius:radius startAngle:0 endAngle:360];
    [bezierPath closePath];
    [bezierPath fill];
    //[bezierPath stroke];
}

+ (void)drawTriangleMarkerAtPoint:(NSPoint)point;
{
    CGFloat radius = 5;
    NSBezierPath *bezierPath;
    CGFloat angle;

    //NSLog(@"->%s, point: %@", _cmd, NSStringFromPoint(aPoint));
    point.x = rint(point.x);
    point.y = rint(point.y);
    //NSLog(@"-->%s, point: %@", _cmd, NSStringFromPoint(aPoint));

    bezierPath = [[NSBezierPath alloc] init];
    //[bezierPath moveToPoint:NSMakePoint(aPoint.x, aPoint.y + radius)];
    angle = 90.0 * (2 * M_PI) / 360.0;
    //NSLog(@"angle: %f, cos(angle): %f, sin(angle): %f", angle, cos(angle), sin(angle));
    [bezierPath moveToPoint:NSMakePoint(point.x + cos(angle) * radius, point.y + sin(angle) * radius)];
    angle = 210.0 * (2 * M_PI) / 360.0;
    //NSLog(@"angle: %f, cos(angle): %f, sin(angle): %f", angle, cos(angle), sin(angle));
    [bezierPath lineToPoint:NSMakePoint(point.x + cos(angle) * radius, point.y + sin(angle) * radius)];
    angle = 330.0 * (2 * M_PI) / 360.0;
    //NSLog(@"angle: %f, cos(angle): %f, sin(angle): %f", angle, cos(angle), sin(angle));
    [bezierPath lineToPoint:NSMakePoint(point.x + cos(angle) * radius, point.y + sin(angle) * radius)];
    [bezierPath closePath];
    [bezierPath fill];
    //[bezierPath stroke];
}

+ (void)drawSquareMarkerAtPoint:(NSPoint)point;
{
    NSRect rect;

    //NSLog(@"->%s, point: %@", _cmd, NSStringFromPoint(aPoint));
    point.x = rint(point.x);
    point.y = rint(point.y);
    //NSLog(@"-->%s, point: %@", _cmd, NSStringFromPoint(aPoint));

    rect = NSIntegralRect(NSMakeRect(point.x - 3, point.y - 3, 1, 1));
    rect.size = NSMakeSize(6, 6);
    //NSLog(@"%s, rect: %@", _cmd, NSStringFromRect(rect));
    [NSBezierPath fillRect:rect];
    //[NSBezierPath strokeRect:rect];
    //NSRectFill(rect);
    //NSFrameRect(rect);
}

+ (void)highlightMarkerAtPoint:(NSPoint)point;
{
    NSRect rect;

    //NSLog(@"->%s, point: %@", _cmd, NSStringFromPoint(aPoint));
    point.x = rint(point.x);
    point.y = rint(point.y);
    //NSLog(@"-->%s, point: %@", _cmd, NSStringFromPoint(aPoint));


    rect = NSIntegralRect(NSMakeRect(point.x - 5, point.y - 5, 10, 10));
    //NSLog(@"%s, rect: %@", _cmd, NSStringFromRect(rect));
    NSFrameRect(rect);
}

@end
