
#import "IntonationPoint.h"
#import "EventList.h"
#import "Phone.h"
#import "MyController.h"
#import <AppKit/NSApplication.h>
#import <Foundation/NSCoder.h>

@implementation IntonationPoint

- init
{

	semitone = 0.0;
	offsetTime = 0.0;
	slope = 0.0;
	ruleIndex = 0;
	eventList = nil;
	return self;

}

- initWithEventList: aList
{
	[self init];
	eventList = aList;
	return self;
}

- (void)setEventList:aList
{
	eventList = aList; 
}

- eventList
{
	return eventList;
}

- (void)setSemitone:(double)newValue
{
	semitone = newValue; 
}

- (double) semitone
{
	return semitone;
}

- (void)setOffsetTime:(double)newValue;
{
	offsetTime = newValue;
}

- (double) offsetTime
{
	return offsetTime;
}

- (void)setSlope:(double)newValue;
{
	slope = newValue;
}

- (double) slope
{
	return slope;
}

- (void)setRuleIndex:(int)newIndex;
{
	ruleIndex = newIndex;
}

- (int) ruleIndex
{
	return ruleIndex;
}

- (double) absoluteTime
{
double time;

	time = [eventList getBeatAtIndex: ruleIndex];
	return time+offsetTime;
}

- (double) beatTime
{

	return [eventList getBeatAtIndex: ruleIndex];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	[aDecoder decodeValuesOfObjCTypes:"dddi", &semitone, &offsetTime, &slope, &ruleIndex];
	eventList = NXGetNamedObject(@"mainEventList", NSApp);
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeValuesOfObjCTypes:"dddi", &semitone, &offsetTime, &slope, &ruleIndex];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
        NXReadTypes(stream, "dddi", &semitone, &offsetTime, &slope, &ruleIndex);
        eventList = NXGetNamedObject(@"mainEventList", NSApp);

        return self;
}
#endif
@end
