#import "IntonationPoint.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "AppController.h"
#import "EventList.h"

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

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<intonation-point semitone=\"%g\" offset-time=\"%g\" slope=\"%g\" rule-index=\"%d\"",
                  semitone, offsetTime, slope, ruleIndex];
    if (eventList == nil || [eventList count] == 0) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<events ptr=\"%p\" count=\"%d\">etc.</events>\n", eventList, [eventList count]];

        [resultString indentToLevel:level];
        [resultString appendString:@"</intonation-point>\n"];
    }
}

@end
