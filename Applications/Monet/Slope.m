#import "Slope.h"

#import <Foundation/Foundation.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@implementation Slope

- (id)init;
{
    if ([super init] == nil)
        return nil;

    slope = 0.0;

    return self;
}

- (double)slope;
{
    return slope;
}

- (void)setSlope:(double)newSlope;
{
    slope = newSlope;
}

- (double)displayTime;
{
    return displayTime;
}

- (void)setDisplayTime:(double)newTime;
{
    displayTime = newTime;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [aDecoder decodeValueOfObjCType:"d" at:&slope];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeValueOfObjCType:"d" at:&slope];
}

@end
