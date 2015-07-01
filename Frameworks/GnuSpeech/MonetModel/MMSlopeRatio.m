//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMSlopeRatio.h"

#import "NSArray-Extensions.h"
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMPoint.h"
#import "MMEquation.h"
#import "MMSlope.h"
#import "MMParameter.h"

#import "EventList.h"

#pragma mark -

@implementation MMSlopeRatio
{
    NSMutableArray *_points; // Of MMPoints
    NSMutableArray *_slopes; // Of MMSlopes
}

- (id)init;
{
    if ((self = [super init])) {
        _points = [[NSMutableArray alloc] init];
        _slopes = [[NSMutableArray alloc] init];
    }

    return self;
}

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"slope-ratio" isEqualToString:element.name]);

    if ((self = [super init])) {
        _points = [[NSMutableArray alloc] init];
        _slopes = [[NSMutableArray alloc] init];

        // Has points and slopes
        if (![self _loadPointsFromXMLElement:[[element elementsForName:@"points"] firstObject] model:model error:error]) return nil;
        if (![self _loadSlopesFromXMLElement:[[element elementsForName:@"slopes"] firstObject] model:model error:error]) return nil;
        // TODO (2004-05-14): Should check to make sure we have an appropriate number of points and slopes.
    }

    return self;
}

- (BOOL)_loadPointsFromXMLElement:(NSXMLElement *)element model:(MModel *)model error:(NSError **)error;
{
    NSParameterAssert([@"points" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"point"]) {
        MMPoint *point = [[MMPoint alloc] initWithModel:model XMLElement:childElement error:error];
        if (point != nil)
            [self addPoint:point];
    }

    return YES;
}

- (BOOL)_loadSlopesFromXMLElement:(NSXMLElement *)element model:(MModel *)model error:(NSError **)error;
{
    NSParameterAssert([@"slopes" isEqualToString:element.name]);

    for (NSXMLElement *childElement in [element elementsForName:@"slope"]) {
        MMSlope *slope = [[MMSlope alloc] initWithXMLElement:childElement error:error];
        if (slope != nil)
            [self addSlope:slope];
    }

    return YES;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> points: %@, slopes: %@",
            NSStringFromClass([self class]), self, _points, _slopes];
}

#pragma mark -

- (NSMutableArray *)points;
{
    return _points;
}

- (void)setPoints:(NSMutableArray *)newList;
{
    if (newList == _points)
        return;

    _points = newList;

    [self updateSlopes];
}

- (void)addPoint:(MMPoint *)newPoint;
{
    [_points addObject:newPoint];
}

- (void)addSlope:(MMSlope *)newSlope;
{
    [_slopes addObject:newSlope];
}

- (void)updateSlopes;
{
    while ([_slopes count] > ([_points count] - 1)) {
        [_slopes removeLastObject];
    }

    while ([_slopes count] < ([_points count] - 1)) {
        MMSlope *newSlope;

        newSlope = [[MMSlope alloc] init];
        [newSlope setSlope:1.0];
        [_slopes addObject:newSlope];
    }
}

- (double)startTime;
{
    return [(MMPoint *)[_points objectAtIndex:0] cachedTime];
}

- (double)endTime;
{
    return [(MMPoint *)[_points lastObject] cachedTime];
}

#pragma mark - Used by TransitionView

- (void)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag
              toDisplay:(NSMutableArray *)displayList;
{
}

- (void)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag andAddToDisplay:(NSMutableArray *)displayList;
{
    NSUInteger i, numSlopes;
    double temp = 0.0, temp1 = 0.0, intervalTime = 0.0, sum = 0.0, factor = 0.0;
    double baseTime = 0.0, endTime = 0.0, totalTime = 0.0, delta = 0.0;
    double startValue;
    MMPoint *currentPoint;

    /* Calculate the times for all points */
    //NSLog(@"%s, count: %d", _cmd, [points count]);
    for (i = 0; i < [_points count]; i++) {
        currentPoint = [_points objectAtIndex:i];
        [[currentPoint timeEquation] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:newCacheTag];
        //NSLog(@"\t%d: expr %@ = %g", i, [[[currentPoint expression] expression] expressionString], dummy);
        //NSLog(@"point value: %g, expression value: %g", [currentPoint value], [[currentPoint expression] cacheValue]);

        [displayList addObject:currentPoint];
    }

    baseTime = [[_points objectAtIndex:0] cachedTime];
    endTime = [[_points lastObject] cachedTime];

    startValue = [(MMPoint *)[_points objectAtIndex:0] value];
    delta = [(MMPoint *)[_points lastObject] value] - startValue;

    temp = [self totalSlopeUnits];
    totalTime = endTime - baseTime;

    numSlopes = [_slopes count];
    for (i = 1; i < numSlopes+1; i++) {
        temp1 = [[_slopes objectAtIndex:i-1] slope] / temp;	/* Calculate normal slope */

        /* Calculate time interval */
        intervalTime = [[_points objectAtIndex:i] cachedTime] - [[_points objectAtIndex:i-1] cachedTime];

        /* Apply interval percentage to slope */
        temp1 = temp1 * (intervalTime / totalTime);

        /* Multiply by delta and add to last point */
        temp1 = (temp1 * delta);
        sum += temp1;

        if (i < numSlopes)
            [(MMPoint *)[_points objectAtIndex:i] setValue:temp1];
    }
    factor = delta / sum;

    temp = startValue;
    for (i = 1; i < [_points count]-1; i++) {
        [[_points objectAtIndex:i] multiplyValueByFactor:factor];
        temp = [[_points objectAtIndex:i] addValue:temp];
    }
}

#pragma mark - Used by ???

- (double)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag
                                  baseline:(double)baseline delta:(double)parameterDelta parameter:(MMParameter *)parameter
                         andAddToEventList:(EventList *)eventList atIndex:(NSUInteger)index;
{
    double returnValue = 0.0;
    NSUInteger i, numSlopes;
    double temp = 0.0, temp1 = 0.0, intervalTime = 0.0, sum = 0.0, factor = 0.0;
    double baseTime = 0.0, endTime = 0.0, totalTime = 0.0, delta = 0.0;
    double startValue;
    MMPoint *currentPoint;

    /* Calculate the times for all points */
    for (i = 0; i < [_points count]; i++) {
        currentPoint = [_points objectAtIndex:i];
        [[currentPoint timeEquation] evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:newCacheTag];
    }

    baseTime = [[_points objectAtIndex:0] cachedTime];
    endTime = [[_points lastObject] cachedTime];

    startValue = [(MMPoint *)[_points objectAtIndex:0] value];
    delta = [(MMPoint *)[_points lastObject] value] - startValue;

    temp = [self totalSlopeUnits];
    totalTime = endTime - baseTime;

    numSlopes = [_slopes count];
    for (i = 1; i < numSlopes+1; i++) {
        temp1 = [[_slopes objectAtIndex:i-1] slope] / temp;	/* Calculate normal slope */

        /* Calculate time interval */
        intervalTime = [[_points objectAtIndex:i] cachedTime] - [[_points objectAtIndex:i-1] cachedTime];

        /* Apply interval percentage to slope */
        temp1 = temp1 * (intervalTime / totalTime);

        /* Multiply by delta and add to last point */
        temp1 = (temp1 * delta);
        sum += temp1;

        if (i < numSlopes)
            [(MMPoint *)[_points objectAtIndex:i] setValue:temp1];
    }
    factor = delta / sum;
    temp = startValue;

    for (i = 1; i < [_points count]-1; i++) {
        [[_points objectAtIndex:i] multiplyValueByFactor:factor];
        temp = [[_points objectAtIndex:i] addValue:temp];
    }

    for (i = 0; i < [_points count]; i++) {
        MMPoint *point = _points[i];
        returnValue = [point calculatePointsWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:newCacheTag
                                                     baseline:baseline delta:parameterDelta parameter:parameter
                                            andAddToEventList:eventList atIndex:index];
     }

    return returnValue;
}

- (double)totalSlopeUnits;
{
    double temp = 0.0;

    for (NSUInteger i = 0; i < [_slopes count]; i++)
        temp += [[_slopes objectAtIndex:i] slope];

    return temp;
}

- (void)displaySlopesInList:(NSMutableArray *)displaySlopes;
{
    //NSLog(@"DisplaySlopesInList: Count = %d", count);
    for (NSUInteger index = 0; index < [_slopes count]; index++) {
        double tempTime = ([[_points objectAtIndex:index] cachedTime] + [[_points objectAtIndex:index+1] cachedTime]) / 2.0;
        MMSlope *currentSlope = [_slopes objectAtIndex:index];
        [currentSlope setDisplayTime:tempTime];
        //NSLog(@"TempTime = %f", tempTime);
        [displaySlopes addObject:currentSlope];
    }
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendString:@"<slope-ratio>\n"];

    [_points appendXMLToString:resultString elementName:@"points" level:level + 1];
    [_slopes appendXMLToString:resultString elementName:@"slopes" level:level + 1];

    [resultString indentToLevel:level];
    [resultString appendString:@"</slope-ratio>\n"];
}

@end
