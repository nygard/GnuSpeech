#import "MMPoint.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "EventList.h"
#import "GSXMLFunctions.h"
#import "MMEquation.h"
#import "MMTransition.h"

#import "MModel.h"
#import "MUnarchiver.h"

@implementation MMPoint

- (id)init;
{
    if ([super init] == nil)
        return nil;

    value = 0.0;
    freeTime = 0.0;
    timeEquation = nil;
    isPhantom = NO;
    type = MMPhoneTypeDiphone;

    return self;
}

- (void)dealloc;
{
    [timeEquation release];

    [super dealloc];
}

- (double)value;
{
    return value;
}

- (void)setValue:(double)newValue;
{
    value = newValue;
}

- (double)multiplyValueByFactor:(double)factor;
{
    value *= factor;
    return value;
}

- (double)addValue:(double)newValue;
{
    value += newValue;
    return value;
}

- (MMEquation *)timeEquation;
{
    return timeEquation;
}

- (void)setTimeEquation:(MMEquation *)newTimeEquation;
{
    if (newTimeEquation == timeEquation)
        return;

    [timeEquation release];
    timeEquation = [newTimeEquation retain];
}

- (double)freeTime;
{
    return freeTime;
}

- (void)setFreeTime:(double)newTime;
{
    freeTime = newTime;
}

- (double)cachedTime;
{
    if (timeEquation != nil)
        return [timeEquation cacheValue]; // TODO (2004-03-11): I think this is a little odd.

    return freeTime;
}

- (int)type;
{
    return type;
}

- (void)setType:(int)newType;
{
    type = newType;
}

- (BOOL)isPhantom;
{
    return isPhantom;
}

- (void)setIsPhantom:(BOOL)newFlag;
{
    isPhantom = newFlag;
}

- (void)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(int)newCacheTag toDisplay:(NSMutableArray *)displayList;
{
    if (timeEquation != nil)
        [timeEquation evaluate:ruleSymbols tempos:tempos postures:postures andCacheWith:newCacheTag];

    [displayList addObject:self];
}


// TODO (2004-08-12): Pass in parameter instead of min, max, and index.
- (double)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
              toEventList:(EventList *)eventList atIndex:(int)index;
{
    double time, returnValue;

    if (timeEquation != nil)
        time = [timeEquation evaluate:ruleSymbols tempos:tempos postures:postures andCacheWith:(int)newCacheTag];
    else
        time = freeTime;

    //NSLog(@"|%@| = %f tempos: %f %f %f %f", [[postures objectAtIndex:0] symbol], time, tempos[0], tempos[1],tempos[2],tempos[3]);

    returnValue = baseline + ((value / 100.0) * delta);

    //NSLog(@"Inserting event %d atTime %f  withValue %f", index, time, returnValue);

    if (returnValue < min)
        returnValue = min;
    else if (returnValue > max)
        returnValue = max;

    if (!isPhantom)
        [eventList insertEvent:index atTimeOffset:time withValue:returnValue];

    return returnValue;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: value: %g, freeTime: %g, timeEquation: %@, type: %d, isPhantom: %d",
                     NSStringFromClass([self class]), self, value, freeTime, timeEquation, type, isPhantom];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<point type=\"%@\" value=\"%g\"", MMStringFromPhoneType(type), value];
    if (timeEquation == nil) {
        [resultString appendFormat:@" free-time=\"%g\"", freeTime];
    } else {
        [resultString appendFormat:@" time-expression=\"%@\"", GSXMLAttributeString([timeEquation name], NO)];
    }

    if (isPhantom == YES)
        [resultString appendFormat:@" is-phantom=\"%@\"", GSXMLBoolAttributeString(isPhantom)];

    [resultString appendString:@"/>\n"];
}

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
{
    NSString *str;

    str = [[element attributeForName:@"type"] stringValue];
    if (str != nil)
        [self setType:MMPhoneTypeFromString(str)];

    str = [[element attributeForName:@"value"] stringValue];
    if (str != nil)
        [self setValue:[str doubleValue]];

    str = [[element attributeForName:@"free-time"] stringValue];
    if (str != nil)
        [self setFreeTime:[str doubleValue]];

    str = [[element attributeForName:@"time-expression"] stringValue];
    if (str != nil) {
        MMEquation *anEquation;

        anEquation = [context findEquationWithName:str];
        [self setTimeEquation:anEquation];
    }

    str = [[element attributeForName:@"is-phantom"] stringValue];
    if (str != nil)
        [self setIsPhantom:GSXMLBoolFromString(str)];
}

- (NSComparisonResult)compareByAscendingCachedTime:(MMPoint *)otherPoint;
{
    double thisTime, otherTime;

    NSParameterAssert(otherPoint != nil);
    thisTime = [self cachedTime];
    otherTime = [otherPoint cachedTime];

    if (thisTime < otherTime)
        return NSOrderedAscending;
    else if (thisTime > otherTime)
        return NSOrderedDescending;

    return NSOrderedSame;
}

@end
