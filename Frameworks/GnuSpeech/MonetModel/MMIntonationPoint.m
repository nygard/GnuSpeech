//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonationPoint.h"

#include <math.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "EventList.h"
#import "MXMLParser.h"

#define MIDDLEC	261.6255653

@implementation MMIntonationPoint
{
    __weak EventList *nonretained_eventList;
    
    double m_semitone;      // Value of the point in semitones
    double m_offsetTime;    // Points are timed wrt a beat + this offset
    double m_slope;         // Slope of point
    
    NSUInteger m_ruleIndex; // Index of the rule for the phone which is the focus of this point
}

- (id)init;
{
    if ((self = [super init])) {
        nonretained_eventList = nil;

        m_semitone = 0.0;
        m_offsetTime = 0.0;
        m_slope = 0.0;
        m_ruleIndex = 0;
    }

    return self;
}

#pragma mark - Debugging

// TODO (2012-04-23): Separate this archiving description from a debugging description
- (NSString *)description;
{
    return [NSString stringWithFormat:@"<intonation-point offset-time=\"%g\" semitone=\"%g\" slope=\"%g\" rule-index=\"%lu\"/>\n",
            self.offsetTime, self.semitone, self.slope, self.ruleIndex];
}

#pragma mark -

@synthesize eventList = nonretained_eventList;

// TODO (2012-04-21): Have event list use kvo to watch for changes.

- (double)semitone;
{
    return m_semitone;
}

- (void)setSemitone:(double)newSemitone;
{
    if (newSemitone != m_semitone) {
        m_semitone = newSemitone;
        [nonretained_eventList intonationPointDidChange:self];
    }
}

- (double)offsetTime;
{
    return m_offsetTime;
}

- (void)setOffsetTime:(double)newOffsetTime;
{
    if (newOffsetTime != m_offsetTime) {
        m_offsetTime = newOffsetTime;
        [nonretained_eventList intonationPointTimeDidChange:self];
    }
}

- (double)slope;
{
    return m_slope;
}

- (void)setSlope:(double)newSlope;
{
    if (newSlope != m_slope) {
        m_slope = newSlope;
        [nonretained_eventList intonationPointDidChange:self];
    }
}

- (NSInteger)ruleIndex;
{
    return m_ruleIndex;
}

- (void)setRuleIndex:(NSInteger)newRuleIndex;
{
    if (newRuleIndex != m_ruleIndex) {
        m_ruleIndex = newRuleIndex;
        [nonretained_eventList intonationPointTimeDidChange:self];
    }
}

- (double)absoluteTime;
{
    if (self.eventList == nil) {
        NSLog(@"Warning: no event list for intonation point in %s, returning 0.0", __PRETTY_FUNCTION__);
        return 0.0;
    }

    return [self.eventList getBeatAtIndex:self.ruleIndex] + self.offsetTime;
}

- (double)beatTime;
{
    if (self.eventList == nil) {
        NSLog(@"Warning: no event list for intonation point in %s, returning 0.0", __PRETTY_FUNCTION__);
        return 0.0;
    }

    return [self.eventList getBeatAtIndex:self.ruleIndex];
}

- (double)semitoneInHertz;
{
    double hertz = pow(2, self.semitone / 12.0) * MIDDLEC;

    return hertz;
}

// TODO (2012-04-23): Maybe just add a function to convert Hertz -> semitone.
- (void)setSemitoneInHertz:(double)newHertzValue;
{
    // i.e. 12.0 * log_2(newHertzValue / MIDDLEC)
    self.semitone = 12.0 * (log10(newHertzValue / MIDDLEC) / log10(2.0));
}

- (void)incrementSemitone;
{
    self.semitone = self.semitone + 1.0;
}

- (void)decrementSemitone;
{
    self.semitone = self.semitone - 1.0;
}

- (void)incrementRuleIndex;
{
    self.ruleIndex = self.ruleIndex + 1;
}

- (void)decrementRuleIndex;
{
    self.ruleIndex = self.ruleIndex - 1;
}

- (NSComparisonResult)compareByAscendingAbsoluteTime:(MMIntonationPoint *)otherIntonationPoint;
{
    double thisTime = [self absoluteTime];
    double otherTime = [otherIntonationPoint absoluteTime];

    if (thisTime < otherTime)      return NSOrderedAscending;
    else if (thisTime > otherTime) return NSOrderedDescending;

    return NSOrderedSame;
}

#pragma mark - XML - Archiving

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<intonation-point offset-time=\"%g\" semitone=\"%g\" slope=\"%g\" rule-index=\"%lu\"/>\n",
                  self.offsetTime, self.semitone, self.slope, self.ruleIndex];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    if ((self = [self init])) {
        NSString *value;
        
        value = [attributes objectForKey:@"offset-time"];
        if (value != nil) self.offsetTime = [value doubleValue];
        
        value = [attributes objectForKey:@"semitone"];
        if (value != nil) self.semitone = [value doubleValue];
        
        value = [attributes objectForKey:@"slope"];
        if (value != nil) self.slope = [value doubleValue];
        
        value = [attributes objectForKey:@"rule-index"];
        if (value != nil) self.ruleIndex = [value intValue];
    }

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

@end
