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

@end
