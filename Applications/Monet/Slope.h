#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface Slope : NSObject
{
    double slope;
    double displayTime;
}

- (id)init;

- (double)slope;
- (void)setSlope:(double)newSlope;

- (double)displayTime;
- (void)setDisplayTime:(double)newTime;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
