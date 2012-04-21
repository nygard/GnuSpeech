//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMPoint.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "EventList.h"
#import "GSXMLFunctions.h"
#import "MMEquation.h"
#import "MMTransition.h"

#import "MModel.h"
#import "MXMLParser.h"

@implementation MMPoint
{
    double value;  /* Value of the point */
    double freeTime; /* Free Floating time */
    MMEquation *timeEquation; /* Time of the point */
    MMPhoneType type;  /* Which phone it is targeting */
    BOOL isPhantom; /* Phantom point for place marking purposes only */
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    value = 0.0;
    freeTime = 0.0;
    timeEquation = nil;
    isPhantom = NO;
    type = MMPhoneType_Diphone;

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

- (NSUInteger)type;
{
    return type;
}

- (void)setType:(NSUInteger)newType;
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

- (void)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag toDisplay:(NSMutableArray *)displayList;
{
    if (timeEquation != nil)
        [timeEquation evaluate:ruleSymbols tempos:tempos postures:postures andCacheWith:newCacheTag];

    [displayList addObject:self];
}


// TODO (2004-08-12): Pass in parameter instead of min, max, and index.
- (double)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag
                 baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
              toEventList:(EventList *)eventList atIndex:(NSUInteger)index;
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
    return [NSString stringWithFormat:@"<%@>[%p]: value: %g, freeTime: %g, timeEquation: %@, type: %lu, isPhantom: %d",
                     NSStringFromClass([self class]), self, value, freeTime, timeEquation, type, isPhantom];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
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

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    NSString *str;

    if ([self init] == nil)
        return nil;

    str = [attributes objectForKey:@"type"];
    if (str != nil)
        [self setType:MMPhoneTypeFromString(str)];

    str = [attributes objectForKey:@"value"];
    if (str != nil)
        [self setValue:[str doubleValue]];

    str = [attributes objectForKey:@"free-time"];
    if (str != nil)
        [self setFreeTime:[str doubleValue]];

    str = [attributes objectForKey:@"time-expression"];
    if (str != nil) {
        MMEquation *anEquation;

        anEquation = [context findEquationWithName:str];
        [self setTimeEquation:anEquation];
    }

    str = [attributes objectForKey:@"is-phantom"];
    if (str != nil)
        [self setIsPhantom:GSXMLBoolFromString(str)];

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
    [(MXMLParser *)parser skipTree];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
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
