
#import "Point.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import "PrototypeManager.h"
#import "ProtoTemplate.h"
#import "ProtoEquation.h"
#import "EventList.h"
#import "MyController.h"
#import <AppKit/NSApplication.h>
#import <Foundation/NSCoder.h>

@implementation Point

- init
{
	value = 0.0;
	freeTime = 0.0;
	expression = nil;
	phantom = 0;
	type = DIPHONE;
	return self;
}

- (void)setValue:(double)newValue
{
	value = newValue; 
}

- (double) value
{
	return value;
}	

- (double) multiplyValueByFactor:(double) factor
{
	value *=factor;
	return value;
}

- (double) addValue:(double) newValue;
{
	value +=newValue;
	return value;
}

- (void)setExpression:newExpression
{
	expression = newExpression; 
}

- expression
{
	return expression;
}

- (void)setFreeTime:(double)newTime
{
	freeTime = newTime; 
}

- (double) freeTime
{
	return freeTime;
}

- (void)setType:(int)newType
{
	type = newType;
}

- (int) type
{
	return type;
}

- (void)setPhantom:(int)phantomFlag
{
	phantom = phantomFlag; 
}

- (int) phantom
{
	return phantom;
}

- calculatePoints: (double *) ruleSymbols tempos: (double *) tempos phones: phones andCacheWith: (int) newCacheTag
	toDisplay: displayList
{
float dummy;

	if (expression)
	{
		dummy = [expression evaluate: ruleSymbols tempos: tempos phones: phones andCacheWith: (int) newCacheTag];
	}
	printf("Dummy %f\n", dummy);

	[displayList addObject:self];

	return self;
}


- (double) calculatePoints: (double *) ruleSymbols tempos: (double *) tempos phones: phones andCacheWith: (int) newCacheTag
	baseline: (double) baseline delta: (double) delta min:(double) min max:(double) max
	toEventList: eventList atIndex: (int) index;
{
double time, returnValue;

	if (expression)
		time = [expression evaluate: ruleSymbols tempos: tempos phones: phones andCacheWith: (int) newCacheTag];
	else
		time = freeTime;

//	printf("|%s| = %f tempos: %f %f %f %f \n", [[phones objectAtIndex:0] symbol], time, tempos[0], tempos[1],tempos[2],tempos[3]);

	returnValue = baseline + ((value/100.0) * delta);

//	printf("Inserting event %d atTime %f  withValue %f\n", index, time, returnValue);

	if (returnValue<min)
		returnValue = min;
	else
	if (returnValue>max)
		returnValue = max;

	if (!phantom) [eventList insertEvent:index atTime: time withValue: returnValue];

	return returnValue;
}

- (double) getTime
{
	if (expression)
		return [expression cacheValue];
	else
		return freeTime;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
int i, j;
id tempProto = NXGetNamedObject("prototypeManager", NSApp);

	[aDecoder decodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &phantom];

	[aDecoder decodeValuesOfObjCTypes:"ii", &i,&j];
	expression = [tempProto findEquation: i andIndex: j];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
int i, j;
id tempProto = NXGetNamedObject("prototypeManager", NSApp);

	[aCoder encodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &phantom];

	[tempProto findList: &i andIndex: &j ofEquation: expression];
	[aCoder encodeValuesOfObjCTypes:"ii", &i, &j];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
int i, j;
id tempProto = NXGetNamedObject("prototypeManager", NSApp);

        NXReadTypes(stream, "ddii", &value, &freeTime, &type, &phantom);

        NXReadTypes(stream, "ii", &i,&j);
        expression = [tempProto findEquation: i andIndex: j];

        return self;
}
#endif

@end
