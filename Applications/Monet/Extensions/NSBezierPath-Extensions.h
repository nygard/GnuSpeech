//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (Extensions)

+ (void)drawCircleMarkerAtPoint:(NSPoint)aPoint;
+ (void)drawTriangleMarkerAtPoint:(NSPoint)aPoint;
+ (void)drawSquareMarkerAtPoint:(NSPoint)aPoint;
+ (void)highlightMarkerAtPoint:(NSPoint)aPoint;

@end
