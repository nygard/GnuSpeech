#import "SlopeRatio.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"

#import "MonetList.h"
#import "Point.h"
#import "ProtoEquation.h"
#import "Slope.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@implementation SlopeRatio

- (id)init;
{
    if ([super init] == nil)
        return nil;

    points = [[MonetList alloc] initWithCapacity:4];
    slopes = [[MonetList alloc] initWithCapacity:4];

    return self;
}

- (void)dealloc;
{
    [points release];
    [slopes release];

    [super dealloc];
}

- (MonetList *)points;
{
    return points;
}

- (void)setPoints:(MonetList *)newList;
{
    if (newList == points)
        return;

    [points release];
    points = [newList retain];

    [self updateSlopes];
}

- (MonetList *)slopes;
{
    return slopes;
}

- (void)setSlopes:(MonetList *)newList;
{
    if (newList == slopes)
        return;

    [slopes release];
    slopes = [newList retain];
}

- (void)updateSlopes;
{
    if ([slopes count] > ([points count] - 1)) {
        while ([slopes count] > ([points count] - 1)) {
            [slopes removeLastObject];
        }
        return;
    }

    if ([slopes count] < ([points count] - 1)) {
        while ([slopes count] < ([points count] - 1)) {
            Slope *aSlope;

            aSlope = [[Slope alloc] init];
            [aSlope setSlope:1.0];
            [slopes addObject:aSlope];
            [aSlope release];
        }
    }
}

- (double)startTime;
{
    return [[(GSMPoint *)[points objectAtIndex:0] expression] cacheValue];
}

- (double)endTime;
{
    return [[(GSMPoint *)[points lastObject] expression] cacheValue];
}

- calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
        toDisplay:displayList ;
{
    int i, numSlopes;
    double temp = 0.0, temp1 = 0.0, intervalTime = 0.0, sum = 0.0, factor = 0.0;
    double dummy, baseTime = 0.0, endTime = 0.0, totalTime = 0.0, delta = 0.0;
    double startValue;
    GSMPoint *currentPoint;

    /* Calculate the times for all points */
    for (i = 0; i < [points count]; i++) {
        currentPoint = [points objectAtIndex:i];
        dummy = [[currentPoint expression] evaluate:ruleSymbols
                                           tempos:tempos phones:phones
                                           andCacheWith:newCacheTag];

        [displayList addObject:currentPoint];
    }

    baseTime = [[points objectAtIndex:0] getTime];
    endTime = [[points lastObject] getTime];

    startValue = [(GSMPoint *)[points objectAtIndex:0] value];
    delta = [(GSMPoint *)[points lastObject] value] - startValue;

    temp = [self totalSlopeUnits];
    totalTime = endTime - baseTime;

    numSlopes = [slopes count];
    for (i = 1; i < numSlopes+1; i++) {
        temp1 = [[slopes objectAtIndex:i-1] slope] / temp;	/* Calculate normal slope */

        /* Calculate time interval */
        intervalTime = [[points objectAtIndex:i] getTime] - [[points objectAtIndex:i-1] getTime];

        /* Apply interval percentage to slope */
        temp1 = temp1 * (intervalTime / totalTime);

        /* Multiply by delta and add to last point */
        temp1 = (temp1 * delta);
        sum += temp1;

        if (i < numSlopes)
            [[points objectAtIndex:i] setValue:temp1];
    }
    factor = delta / sum;

    temp = startValue;
    for (i = 1; i < [points count]-1; i++) {
        temp1 = [[points objectAtIndex:i] multiplyValueByFactor:factor];
        temp = [[points objectAtIndex:i] addValue:temp];
    }

    return self;
}

- (double)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)parameterDelta min:(double)min max:(double)max
              toEventList:eventList atIndex:(int)index;
{
    double returnValue = 0.0;
    int i, numSlopes;
    double temp = 0.0, temp1 = 0.0, intervalTime = 0.0, sum = 0.0, factor = 0.0;
    double dummy, baseTime = 0.0, endTime = 0.0, totalTime = 0.0, delta = 0.0;
    double startValue;
    GSMPoint *currentPoint;

    /* Calculate the times for all points */
    for (i = 0; i < [points count]; i++) {
        currentPoint = [points objectAtIndex:i];
        dummy = [[currentPoint expression] evaluate:ruleSymbols tempos:tempos phones:phones
                                           andCacheWith:newCacheTag];
    }

    baseTime = [[points objectAtIndex:0] getTime];
    endTime = [[points lastObject] getTime];

    startValue = [(GSMPoint *)[points objectAtIndex:0] value];
    delta = [(GSMPoint *)[points lastObject] value] - startValue;

    temp = [self totalSlopeUnits];
    totalTime = endTime - baseTime;

    numSlopes = [slopes count];
    for (i = 1; i < numSlopes+1; i++) {
        temp1 = [[slopes objectAtIndex:i-1] slope] / temp;	/* Calculate normal slope */

        /* Calculate time interval */
        intervalTime = [[points objectAtIndex:i] getTime] - [[points objectAtIndex:i-1] getTime];

        /* Apply interval percentage to slope */
        temp1 = temp1 * (intervalTime / totalTime);

        /* Multiply by delta and add to last point */
        temp1 = (temp1 * delta);
        sum += temp1;

        if (i < numSlopes)
            [[points objectAtIndex:i] setValue:temp1];
    }
    factor = delta / sum;
    temp = startValue;

    for (i = 1; i < [points count]-1; i++) {
        temp1 = [[points objectAtIndex:i] multiplyValueByFactor:factor];
        temp = [[points objectAtIndex:i] addValue:temp];
    }

    for (i = 0; i < [points count]; i++) {
        returnValue = [[points objectAtIndex:i] calculatePoints:ruleSymbols tempos:tempos phones:phones
                                                 andCacheWith:newCacheTag baseline:baseline delta:parameterDelta
                                                 min:min max:max toEventList:eventList atIndex:index];
    }

    return returnValue;
}

- (double)totalSlopeUnits;
{
    int i;
    double temp = 0.0;

    for (i = 0; i < [slopes count]; i++)
        temp += [[slopes objectAtIndex:i] slope];

    return temp;
}

- (void)displaySlopesInList:(MonetList *)displaySlopes;
{
    int i;
    double tempTime;

    NSLog(@"DisplaySlopesInList: Count = %d", [slopes count]);
    for (i = 0; i < [slopes count]; i++) {
        tempTime = ([[points objectAtIndex:i] getTime] + [[points objectAtIndex:i+1] getTime]) / 2.0;
        [[slopes objectAtIndex:i] setDisplayTime:tempTime];
        NSLog(@"TempTime = %f", tempTime);
        [displaySlopes addObject:[slopes objectAtIndex:i]];
    }
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    points = [[aDecoder decodeObject] retain];
    slopes = [[aDecoder decodeObject] retain];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
#ifdef PORTING
    [aCoder encodeObject:points];
    [aCoder encodeObject:slopes];
#endif
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: points: %@, slopes: %@",
                     NSStringFromClass([self class]), self, points, slopes];
}

@end
