#import "MMSlopeRatio.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MonetList.h"
#import "MMPoint.h"
#import "MMEquation.h"
#import "MMSlope.h"

#import "MXMLParser.h"
#import "MXMLArrayDelegate.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@implementation MMSlopeRatio

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

- (void)addPoint:(MMPoint *)newPoint;
{
    [points addObject:newPoint];
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

- (void)addSlope:(MMSlope *)newSlope;
{
    [slopes addObject:newSlope];
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
            MMSlope *aSlope;

            aSlope = [[MMSlope alloc] init];
            [aSlope setSlope:1.0];
            [slopes addObject:aSlope];
            [aSlope release];
        }
    }
}

- (double)startTime;
{
    return [[(MMPoint *)[points objectAtIndex:0] expression] cacheValue];
}

- (double)endTime;
{
    return [[(MMPoint *)[points lastObject] expression] cacheValue];
}

- (void)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
              toDisplay:(MonetList *)displayList;
{
    int i, numSlopes;
    double temp = 0.0, temp1 = 0.0, intervalTime = 0.0, sum = 0.0, factor = 0.0;
    double dummy, baseTime = 0.0, endTime = 0.0, totalTime = 0.0, delta = 0.0;
    double startValue;
    MMPoint *currentPoint;

    /* Calculate the times for all points */
    //NSLog(@"%s, count: %d", _cmd, [points count]);
    for (i = 0; i < [points count]; i++) {
        currentPoint = [points objectAtIndex:i];
        dummy = [[currentPoint expression] evaluate:ruleSymbols
                                           tempos:tempos phones:phones
                                           andCacheWith:newCacheTag];
        //NSLog(@"\t%d: expr %@ = %g", i, [[[currentPoint expression] expression] expressionString], dummy);
        //NSLog(@"point value: %g, expression value: %g", [currentPoint value], [[currentPoint expression] cacheValue]);

        [displayList addObject:currentPoint];
    }

    baseTime = [[points objectAtIndex:0] getTime];
    endTime = [[points lastObject] getTime];

    startValue = [(MMPoint *)[points objectAtIndex:0] value];
    delta = [(MMPoint *)[points lastObject] value] - startValue;

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
}

- (double)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)parameterDelta min:(double)min max:(double)max
              toEventList:eventList atIndex:(int)index;
{
    double returnValue = 0.0;
    int i, numSlopes;
    double temp = 0.0, temp1 = 0.0, intervalTime = 0.0, sum = 0.0, factor = 0.0;
    double dummy, baseTime = 0.0, endTime = 0.0, totalTime = 0.0, delta = 0.0;
    double startValue;
    MMPoint *currentPoint;

    /* Calculate the times for all points */
    for (i = 0; i < [points count]; i++) {
        currentPoint = [points objectAtIndex:i];
        dummy = [[currentPoint expression] evaluate:ruleSymbols tempos:tempos phones:phones andCacheWith:newCacheTag];
    }

    baseTime = [[points objectAtIndex:0] getTime];
    endTime = [[points lastObject] getTime];

    startValue = [(MMPoint *)[points objectAtIndex:0] value];
    delta = [(MMPoint *)[points lastObject] value] - startValue;

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

- (void)displaySlopesInList:(NSMutableArray *)displaySlopes;
{
    int count, index;
    double tempTime;

    count = [slopes count];
    //NSLog(@"DisplaySlopesInList: Count = %d", count);
    for (index = 0; index < [slopes count]; index++) {
        MMSlope *currentSlope;

        tempTime = ([[points objectAtIndex:index] getTime] + [[points objectAtIndex:index+1] getTime]) / 2.0;
        currentSlope = [slopes objectAtIndex:index];
        [currentSlope setDisplayTime:tempTime];
        //NSLog(@"TempTime = %f", tempTime);
        [displaySlopes addObject:currentSlope];
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

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: points: %@, slopes: %@",
                     NSStringFromClass([self class]), self, points, slopes];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendString:@"<slope-ratio>\n"];

    [points appendXMLToString:resultString elementName:@"points" level:level + 1];
    [slopes appendXMLToString:resultString elementName:@"slopes" level:level + 1];

    [resultString indentToLevel:level];
    [resultString appendString:@"</slope-ratio>\n"];
}

// TODO (2004-05-14): Maybe with a common superclass we wouldn't need to implement this method here.
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    if ([self init] == nil)
        return nil;

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"points"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"point" class:[MMPoint class] delegate:self addObjectSelector:@selector(addPoint:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else if ([elementName isEqualToString:@"slopes"]) {
        MXMLArrayDelegate *arrayDelegate;

        arrayDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"slope" class:[MMSlope class] delegate:self addObjectSelector:@selector(addSlope:)];
        [(MXMLParser *)parser pushDelegate:arrayDelegate];
        [arrayDelegate release];
    } else {
        NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    // TODO (2004-05-14): Should check to make sure we have an appropriate number of points and slopes.
    [(MXMLParser *)parser popDelegate];
}

@end
