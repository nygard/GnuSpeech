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
    double _value;             // Value of the point
    double _freeTime;          // Free Floating time
    MMEquation *_timeEquation; // Time of the point
    MMPhoneType _type;         // Which phone it is targeting
    BOOL _isPhantom;           // Phantom point for place marking purposes only
}

- (id)init;
{
    if ((self = [super init])) {
        _value = 0.0;
        _freeTime = 0.0;
        _timeEquation = nil;
        _isPhantom = NO;
        _type = MMPhoneType_Diphone;
    }

    return self;
}

#pragma mark -

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> value: %g, freeTime: %g, timeEquation: %@, type: %lu, isPhantom: %d",
            NSStringFromClass([self class]), self, _value, _freeTime, _timeEquation, _type, _isPhantom];
}

#pragma mark -

- (double)multiplyValueByFactor:(double)factor;
{
    _value *= factor;
    return _value;
}

- (double)addValue:(double)newValue;
{
    _value += newValue;
    return _value;
}

- (double)cachedTime;
{
    if (_timeEquation != nil)
        return [_timeEquation cacheValue]; // TODO (2004-03-11): I think this is a little odd.

    return _freeTime;
}

- (void)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag andAddToDisplay:(NSMutableArray *)displayList;
{
    if (_timeEquation != nil)
        [_timeEquation evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:newCacheTag];

    [displayList addObject:self];
}


// TODO (2004-08-12): Pass in parameter instead of min, max, and index.
- (double)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag
                                  baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
                         andAddToEventList:(EventList *)eventList atIndex:(NSUInteger)index;
{
    double time, returnValue;

    if (_timeEquation != nil)
        time = [_timeEquation evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols andCacheWithTag:newCacheTag];
    else
        time = _freeTime;

    //NSLog(@"|%@| = %f tempos: %f %f %f %f", [[postures objectAtIndex:0] symbol], time, tempos[0], tempos[1],tempos[2],tempos[3]);

    returnValue = baseline + ((_value / 100.0) * delta);

    //NSLog(@"Inserting event %d atTime %f  withValue %f", index, time, returnValue);

    if (returnValue < min)
        returnValue = min;
    else if (returnValue > max)
        returnValue = max;

    if (!_isPhantom)
        [eventList insertEvent:index atTimeOffset:time withValue:returnValue];

    return returnValue;
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<point type=\"%@\" value=\"%g\"", MMStringFromPhoneType(_type), _value];
    if (_timeEquation == nil) {
        [resultString appendFormat:@" free-time=\"%g\"", _freeTime];
    } else {
        [resultString appendFormat:@" time-expression=\"%@\"", GSXMLAttributeString([_timeEquation name], NO)];
    }

    if (_isPhantom == YES)
        [resultString appendFormat:@" is-phantom=\"%@\"", GSXMLBoolAttributeString(_isPhantom)];

    [resultString appendString:@"/>\n"];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    if ((self = [self init])) {
        NSString *str;
        
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
    }

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"point"])
        [(MXMLParser *)parser popDelegate];
    else
        [NSException raise:@"Unknown close tag" format:@"Unknown closing tag (%@) in %@", elementName, NSStringFromClass([self class])];
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
