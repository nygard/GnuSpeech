
#import "SlopeRatio.h"
#import "Point.h"
#import "ProtoEquation.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@implementation SlopeRatio

- init
{
	points = [[MonetList alloc] initWithCapacity:4];
	slopes = [[MonetList alloc] initWithCapacity:4];
	return self;
}

- (void)setPoints:newList
{
	if (points)
		[points release];
	points = newList;

	[self updateSlopes]; 
}

- points
{
	return points;
}

- (void)setSlopes:newList
{
	if (slopes)
		[slopes release];
	slopes = newList; 
}

- (void)updateSlopes
{
Slope *tempSlope;

	if ([slopes count]>([points count]-1))
	{
		while([slopes count]>([points count]-1))
		{
			[slopes removeLastObject];
		}
		return;
	}

	if ([slopes count]<([points count]-1))
	{
		while([slopes count]<([points count]-1))
		{
			tempSlope = [[Slope alloc] init];
			[tempSlope setSlope:1.0];
			[slopes addObject:tempSlope];
		}
		return;
	} 
}

- slopes
{
	return slopes;
}

- (void)dealloc
{
	[points release];
}

- (double) startTime
{
	return [[[points objectAtIndex:0] expression] cacheValue];
}

- (double) endTime
{
	return [[[points lastObject] expression] cacheValue];
}

- calculatePoints: (double *) ruleSymbols tempos: (double *) tempos phones: phones andCacheWith: (int) newCacheTag 
        toDisplay: displayList ;
{
int i, numSlopes;
double temp = 0.0, temp1 = 0.0, intervalTime = 0.0, sum = 0.0, factor = 0.0;
double dummy, baseTime = 0.0, endTime = 0.0, totalTime = 0.0, delta = 0.0;
double startValue;
Point *currentPoint;

	/* Calculate the times for all points */
	for (i = 0; i< [points count]; i++)
	{
		currentPoint = [points objectAtIndex:i];
		dummy = [[currentPoint expression] evaluate: ruleSymbols 
						   tempos: tempos phones: phones 
						   andCacheWith: newCacheTag];

		[displayList addObject:currentPoint];
	}

	baseTime = [[points objectAtIndex: 0] getTime];
	endTime = [[points lastObject] getTime];

	startValue = [[points objectAtIndex:0] value];
	delta = [[points lastObject] value] - startValue;

	temp = [self totalSlopeUnits];
	totalTime = endTime-baseTime;

	numSlopes = [slopes count];
	for (i = 1; i< numSlopes+1; i++)
	{
		temp1 = [[slopes objectAtIndex:i-1] slope] / temp;	/* Calculate normal slope */

		/* Calculate time interval */
		intervalTime = [[points objectAtIndex:i] getTime] - [[points objectAtIndex:i-1] getTime];

		/* Apply interval percentage to slope */
		temp1 = temp1*(intervalTime/totalTime);

		/* Multiply by delta and add to last point */
		temp1 = (temp1*delta);
		sum+=temp1;

		if (i<numSlopes)
			[[points objectAtIndex: i] setValue:temp1];
	}
	factor = delta/sum;

	temp = startValue;
	for(i = 1; i< [points count]-1; i++)
	{
		temp1 = [[points objectAtIndex: i] multiplyValueByFactor:factor];
		temp = [[points objectAtIndex: i] addValue:temp];
	}

	return self;
}

- (double) calculatePoints: (double *) ruleSymbols tempos: (double *) tempos phones: phones andCacheWith: (int) newCacheTag
	baseline: (double) baseline delta: (double) parameterDelta min: (double) min max:(double) max
	toEventList: eventList atIndex: (int) index
{
double returnValue = 0.0;
int i, numSlopes;
double temp = 0.0, temp1 = 0.0, intervalTime = 0.0, sum = 0.0, factor = 0.0;
double dummy, baseTime = 0.0, endTime = 0.0, totalTime = 0.0, delta = 0.0;
double startValue;
Point *currentPoint;

	/* Calculate the times for all points */
	for (i = 0; i< [points count]; i++)
	{
		currentPoint = [points objectAtIndex:i];
		dummy = [[currentPoint expression] evaluate: ruleSymbols tempos: tempos phones: phones 
				andCacheWith: newCacheTag];
	}

	baseTime = [[points objectAtIndex: 0] getTime];
	endTime = [[points lastObject] getTime];

	startValue = [[points objectAtIndex:0] value];
	delta = [[points lastObject] value] - startValue;

	temp = [self totalSlopeUnits];
	totalTime = endTime-baseTime;

	numSlopes = [slopes count];
	for (i = 1; i< numSlopes+1; i++)
	{
		temp1 = [[slopes objectAtIndex:i-1] slope] / temp;	/* Calculate normal slope */

		/* Calculate time interval */
		intervalTime = [[points objectAtIndex:i] getTime] - [[points objectAtIndex:i-1] getTime];

		/* Apply interval percentage to slope */
		temp1 = temp1*(intervalTime/totalTime);

		/* Multiply by delta and add to last point */
		temp1 = (temp1*delta);
		sum+=temp1;

		if (i<numSlopes)
			[[points objectAtIndex: i] setValue:temp1];
	}
	factor = delta/sum;
	temp = startValue;

	for(i = 1; i< [points count]-1; i++)
	{
		temp1 = [[points objectAtIndex: i] multiplyValueByFactor:factor];
		temp = [[points objectAtIndex: i] addValue:temp];
	}

	for(i = 0; i<[points count]; i++)
	{
		returnValue = [[points objectAtIndex: i] calculatePoints: ruleSymbols tempos: tempos phones: phones 
					andCacheWith: newCacheTag baseline: baseline delta: parameterDelta
					min: min max:max toEventList: eventList atIndex: index];
	}

	return returnValue;
}

- (double)totalSlopeUnits
{
int i;
double temp = 0.0;

	for (i = 0; i<[slopes count]; i++)
		temp+=[[slopes objectAtIndex:i] slope];

	return temp;
}

- (void)displaySlopesInList:(MonetList *)displaySlopes
{
int i;
double tempTime;

	printf("DisplaySlopesInList: Count = %d\n", [slopes count]);
	for (i = 0; i< [slopes count]; i++)
	{
		tempTime = ([[points objectAtIndex:i] getTime] + [[points objectAtIndex:i+1] getTime]) /2.0;
		[[slopes objectAtIndex:i] setDisplayTime:tempTime];
		printf("TempTime = %f\n", tempTime);
		[displaySlopes addObject: [slopes objectAtIndex:i]];
	} 
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	points = [[aDecoder decodeObject] retain];
	slopes = [[aDecoder decodeObject] retain];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:points];
	[aCoder encodeObject:slopes];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
        points = NXReadObject(stream);
        slopes = NXReadObject(stream);

        return self;
}
#endif

@end
