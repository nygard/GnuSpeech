//
// $Id: NSBezierPath-Extensions.h,v 1.1 2004/03/26 02:23:09 nygard Exp $
//

//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <AppKit/NSBezierPath.h>

@interface NSBezierPath (Extensions)

+ (void)drawCircleMarkerAtPoint:(NSPoint)aPoint;
+ (void)drawTriangleMarkerAtPoint:(NSPoint)aPoint;
+ (void)drawSquareMarkerAtPoint:(NSPoint)aPoint;
+ (void)highlightMarkerAtPoint:(NSPoint)aPoint;

@end
