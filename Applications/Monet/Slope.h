
#import <Foundation/NSObject.h>
#import <AppKit/NSGraphics.h>
#ifdef NeXT
#import <objc/typedstream.h>
#endif

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface Slope:NSObject
{
	double slope;
	double displayTime;
}

- init;

- (void)setSlope:(double)newSlope;
- (double) slope;

- (void)setDisplayTime:(double)newTime;
- (double) displayTime;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
