#import "Point.h"

#import <Foundation/Foundation.h>
#import "AppController.h"
#import "EventList.h"
#import "ProtoEquation.h"
#import "PrototypeManager.h"
#import "ProtoTemplate.h"

@implementation GSMPoint

- (id)init;
{
    if ([super init] == nil)
        return nil;

    value = 0.0;
    freeTime = 0.0;
    expression = nil;
    phantom = 0;
    type = DIPHONE;

    return self;
}

- (void)dealloc;
{
    [expression release];

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

- (ProtoEquation *)expression;
{
    return expression;
}

- (void)setExpression:(ProtoEquation *)newExpression;
{
    if (newExpression == expression)
        return;

    [expression release];
    expression = [newExpression retain];
}

- (double)freeTime;
{
    return freeTime;
}

- (void)setFreeTime:(double)newTime;
{
    freeTime = newTime;
}

- (double)getTime;
{
    if (expression)
        return [expression cacheValue];

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

- (int)phantom;
{
    return phantom;
}

- (void)setPhantom:(int)phantomFlag;
{
    phantom = phantomFlag;
}

- calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag toDisplay:displayList;
{
    float dummy;

    if (expression) {
        dummy = [expression evaluate:ruleSymbols tempos:tempos phones:phones andCacheWith:(int)newCacheTag];
    }
    NSLog(@"Dummy %f", dummy);

    [displayList addObject:self];

    return self;
}


- (double)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
              toEventList:(EventList *)eventList atIndex:(int)index;
{
    double time, returnValue;

    if (expression)
        time = [expression evaluate: ruleSymbols tempos: tempos phones: phones andCacheWith: (int) newCacheTag];
    else
        time = freeTime;

    //NSLog(@"|%@| = %f tempos: %f %f %f %f", [[phones objectAtIndex:0] symbol], time, tempos[0], tempos[1],tempos[2],tempos[3]);

    returnValue = baseline + ((value / 100.0) * delta);

    //NSLog(@"Inserting event %d atTime %f  withValue %f", index, time, returnValue);

    if (returnValue < min)
        returnValue = min;
    else if (returnValue > max)
        returnValue = max;

    if (!phantom)
        [eventList insertEvent:index atTime:time withValue:returnValue];

    return returnValue;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int i, j;
    PrototypeManager *prototypeManager = NXGetNamedObject(@"prototypeManager", NSApp);
    ProtoEquation *anExpression;

    if ([self init] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &phantom];
    //NSLog(@"value: %g, freeTime: %g, type: %d, phantom: %d", value, freeTime, type, phantom);

    [aDecoder decodeValuesOfObjCTypes:"ii", &i, &j];
    //NSLog(@"i: %d, j: %d", i, j);
    anExpression = [prototypeManager findEquation:i andIndex:j];
    //NSLog(@"anExpression: %@", anExpression);
    [self setExpression:anExpression];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    int i, j;
    id prototypeManager = NXGetNamedObject(@"prototypeManager", NSApp);

    [aCoder encodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &phantom];

    [prototypeManager findList:&i andIndex:&j ofEquation:expression];
    [aCoder encodeValuesOfObjCTypes:"ii", &i, &j];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: value: %g, freeTime: %g, expression: %@, type: %d, phantom: %d",
                     NSStringFromClass([self class]), self, value, freeTime, expression, type, phantom];
}

@end
