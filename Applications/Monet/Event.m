#import "Event.h"

#import <Foundation/Foundation.h>

@implementation Event

- (id)init;
{
    int index;

    if ([super init] == nil)
        return nil;

    time = 0;
    flag = NO;

    for (index = 0; index < MAX_EVENTS; index++)
        events[index] = NaN;

    return self;
}

- (int)time;
{
    return time;
}

- (void)setTime:(int)newTime;
{
    time = newTime;
}

- (BOOL)flag;
{
    return flag;
}

- (void)setFlag:(BOOL)newFlag;
{
    flag = newFlag;
}

- (double)getValueAtIndex:(int)index;
{
    assert(index >= 0 && index < MAX_EVENTS);
    return events[index];
}

- (void)setValue:(double)newValue ofIndex:(int)index;
{
    if (index < 0 || index >= MAX_EVENTS)
        return;

    events[index] = newValue;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: time: %d, flag: %d, events: (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g)",
                     NSStringFromClass([self class]), self, time, flag,
                     events[0], events[1], events[2], events[3], events[4], events[5],
                     events[6], events[7], events[8], events[9], events[10], events[11],
                     events[12], events[13], events[14], events[15], events[16], events[17],
                     events[18], events[19], events[20], events[21], events[22], events[23],
                     events[24], events[25], events[26], events[27], events[28], events[29],
                     events[30], events[31], events[32], events[33], events[34], events[35]];
}

@end
