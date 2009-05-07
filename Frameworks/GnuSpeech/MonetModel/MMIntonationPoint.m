////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MMIntonationPoint.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#import "MMIntonationPoint.h"

#include <math.h>
#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "EventList.h"
#import "MXMLParser.h"

#define MIDDLEC	261.6255653

@implementation MMIntonationPoint

// TODO (2004-08-17): Reject unused init method.
- (id)init;
{
    if ([super init] == nil)
        return nil;

    nonretained_eventList = nil;

    semitone = 0.0;
    offsetTime = 0.0;
    slope = 0.0;
    ruleIndex = 0;

    return self;
}

- (EventList *)eventList;
{
    return nonretained_eventList;
}

- (void)setEventList:(EventList *)newEventList;
{
    nonretained_eventList = newEventList;
}

- (double)semitone;
{
    return semitone;
}

- (void)setSemitone:(double)newSemitone;
{
    if (newSemitone == semitone)
        return;

    semitone = newSemitone;
    [nonretained_eventList intonationPointDidChange:self];
}

- (double)offsetTime;
{
    return offsetTime;
}

- (void)setOffsetTime:(double)newOffsetTime;
{
    if (newOffsetTime == offsetTime)
        return;

    offsetTime = newOffsetTime;
    [nonretained_eventList intonationPointTimeDidChange:self];
}

- (double)slope;
{
    return slope;
}

- (void)setSlope:(double)newSlope;
{
    if (newSlope == slope)
        return;

    slope = newSlope;
    [nonretained_eventList intonationPointDidChange:self];
}

- (int)ruleIndex;
{
    return ruleIndex;
}

- (void)setRuleIndex:(int)newRuleIndex;
{
    if (newRuleIndex == ruleIndex)
        return;

    ruleIndex = newRuleIndex;
    [nonretained_eventList intonationPointTimeDidChange:self];
}

- (double)absoluteTime;
{
    if (nonretained_eventList == nil) {
        NSLog(@"Warning: no event list for intonation point in %s, returning 0.0", _cmd);
        return 0.0;
    }

    return [nonretained_eventList getBeatAtIndex:ruleIndex] + offsetTime;
}

- (double)beatTime;
{
    if (nonretained_eventList == nil) {
        NSLog(@"Warning: no event list for intonation point in %s, returning 0.0", _cmd);
        return 0.0;
    }

    return [nonretained_eventList getBeatAtIndex:ruleIndex];
}

- (double)semitoneInHertz;
{
    double hertz;

    hertz = pow(2, semitone / 12.0) * MIDDLEC;

    return hertz;
}

- (void)setSemitoneInHertz:(double)newHertzValue;
{
    double newValue;

    // i.e. 12.0 * log_2(newHertzValue / MIDDLEC)
    newValue = 12.0 * (log10(newHertzValue / MIDDLEC) / log10(2.0));
    [self setSemitone:newValue];
}

- (void)incrementSemitone;
{
    [self setSemitone:semitone + 1.0];
}

- (void)decrementSemitone;
{
    [self setSemitone:semitone - 1.0];
}

- (void)incrementRuleIndex;
{
    [self setRuleIndex:ruleIndex + 1];
}

- (void)decrementRuleIndex;
{
    [self setRuleIndex:ruleIndex - 1];
}

- (NSComparisonResult)compareByAscendingAbsoluteTime:(MMIntonationPoint *)otherIntonationPoint;
{
    double thisTime, otherTime;

    thisTime = [self absoluteTime];
    otherTime = [otherIntonationPoint absoluteTime];

    if (thisTime < otherTime)
        return NSOrderedAscending;
    else if (thisTime > otherTime)
        return NSOrderedDescending;

    return NSOrderedSame;
}

//
// XML - Archiving
//

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<intonation-point offset-time=\"%g\" semitone=\"%g\" slope=\"%g\" rule-index=\"%d\"/>\n",
                  offsetTime, semitone, slope, ruleIndex];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    NSString *value;

    if ([self init] == nil)
        return nil;

    value = [attributes objectForKey:@"offset-time"];
    if (value != nil)
        [self setOffsetTime:[value doubleValue]];

    value = [attributes objectForKey:@"semitone"];
    if (value != nil)
        [self setSemitone:[value doubleValue]];

    value = [attributes objectForKey:@"slope"];
    if (value != nil)
        [self setSlope:[value doubleValue]];

    value = [attributes objectForKey:@"rule-index"];
    if (value != nil)
        [self setRuleIndex:[value intValue]];

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    [(MXMLParser *)parser skipTree];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

//
// Debugging
//

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<intonation-point offset-time=\"%g\" semitone=\"%g\" slope=\"%g\" rule-index=\"%d\"/>\n",
                     offsetTime, semitone, slope, ruleIndex];
}

@end
