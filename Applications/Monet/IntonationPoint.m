#import "IntonationPoint.h"

#include <math.h>
#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "EventList.h"

#define MIDDLEC	261.6255653

@implementation IntonationPoint

- (id)init;
{
    if ([super init] == nil)
        return nil;

    semitone = 0.0;
    offsetTime = 0.0;
    slope = 0.0;
    ruleIndex = 0;
    eventList = nil;

    return self;
}

- (id)initWithEventList:(EventList *)aList;
{
    if ([self init] == nil)
        return nil;

    eventList = [aList retain];

    return self;
}

- (void)dealloc;
{
    [eventList release];

    [super dealloc];
}

- (EventList *)eventList;
{
    return eventList;
}

- (void)setEventList:(EventList *)aList;
{
    if (aList == eventList)
        return;

    [eventList release];
    eventList = [aList retain];
}

- (double)semitone;
{
    return semitone;
}

- (void)setSemitone:(double)newValue;
{
    semitone = newValue;
}

- (double)offsetTime;
{
    return offsetTime;
}

- (void)setOffsetTime:(double)newValue;
{
    offsetTime = newValue;
}

- (double)slope;
{
    return slope;
}

- (void)setSlope:(double)newValue;
{
    slope = newValue;
}

- (int)ruleIndex;
{
    return ruleIndex;
}

- (void)setRuleIndex:(int)newIndex;
{
    ruleIndex = newIndex;
}

- (double)absoluteTime;
{
    double time;

    time = [eventList getBeatAtIndex:ruleIndex];
    return time + offsetTime;
}

- (double)beatTime;
{
    return [eventList getBeatAtIndex:ruleIndex];
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

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<intonation-point semitone=\"%g\" offset-time=\"%g\" slope=\"%g\" rule-index=\"%d\"/>\n",
                  semitone, offsetTime, slope, ruleIndex];
}

@end
