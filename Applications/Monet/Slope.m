
#import "Slope.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@implementation Slope

- init
{
	slope = 0.0;
	return self;
}

- (void)setSlope:(double)newSlope
{
	slope = newSlope; 
}

- (double) slope
{
	return slope;
}

- (void)setDisplayTime:(double)newTime
{
	displayTime = newTime; 
}

- (double) displayTime
{
	return displayTime;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	[aDecoder decodeValueOfObjCType:"d" at:&slope];	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeValueOfObjCType:"d" at:&slope];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
        NXReadType(stream, "d", &slope);
        return self;
}
#endif



@end
