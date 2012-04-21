//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Event.h"

@implementation Event
{
    NSUInteger m_time;
    BOOL m_flag;
    double m_events[MAX_EVENTS];
}

- (id)init;
{
    // TODO (2004-08-15): Reject unused method
    NSLog(@"%s should not be called", __PRETTY_FUNCTION__);
    return nil;
}

- (id)initWithTime:(NSUInteger)aTime;
{
    if ((self = [super init])) {
        m_time = aTime;
        m_flag = NO;

        for (NSUInteger index = 0; index < MAX_EVENTS; index++)
            m_events[index] = NaN;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    //return [NSString stringWithFormat:@"<%@>[%p]: time: %d, flag: %d, events: (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g)",
    return [NSString stringWithFormat:@"<%@: %p> time: %lu, flag: %d, events: (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g)",
            NSStringFromClass([self class]), self,
            self.time, self.flag,
            m_events[0], m_events[1], m_events[2], m_events[3], m_events[4], m_events[5],
            m_events[6], m_events[7], m_events[8], m_events[9], m_events[10], m_events[11],
            m_events[12], m_events[13], m_events[14], m_events[15], m_events[16], m_events[17],
            m_events[18], m_events[19], m_events[20], m_events[21], m_events[22], m_events[23],
            m_events[24], m_events[25], m_events[26], m_events[27], m_events[28], m_events[29],
            m_events[30], m_events[31], m_events[32], m_events[33], m_events[34], m_events[35]];
}

#pragma mark -

@synthesize time = m_time;
@synthesize flag = m_flag;

// TODO (2012-04-21): getValueOfEventAtIndex:
- (double)getValueAtIndex:(NSUInteger)index;
{
    assert(index >= 0 && index < MAX_EVENTS);
    return m_events[index];
}

- (void)setValue:(double)value ofIndex:(NSUInteger)index;
{
    if (index >= MAX_EVENTS)
        return;

    m_events[index] = value;
}

@end
