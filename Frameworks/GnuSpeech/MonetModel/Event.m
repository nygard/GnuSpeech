//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Event.h"

#define MAX_VALUES 36

@implementation Event
{
    NSUInteger m_time;
    BOOL m_flag;
    double m_value[MAX_VALUES];
}

- (id)init;
{
    if ((self = [super init])) {
        m_time = 0;
        m_flag = NO;

        for (NSUInteger index = 0; index < MAX_VALUES; index++)
            m_value[index] = NaN;
    }
    
    NSLog(@"%@", self);

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> time: %lu, flag: %d, values: (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g)",
            NSStringFromClass([self class]), self,
            self.time, self.flag,
            m_value[0], m_value[1], m_value[2], m_value[3], m_value[4], m_value[5],
            m_value[6], m_value[7], m_value[8], m_value[9], m_value[10], m_value[11],
            m_value[12], m_value[13], m_value[14], m_value[15], m_value[16], m_value[17],
            m_value[18], m_value[19], m_value[20], m_value[21], m_value[22], m_value[23],
            m_value[24], m_value[25], m_value[26], m_value[27], m_value[28], m_value[29],
            m_value[30], m_value[31], m_value[32], m_value[33], m_value[34], m_value[35]];
}

#pragma mark -

@synthesize time = m_time;
@synthesize flag = m_flag;

- (double)getValueAtIndex:(NSUInteger)index;
{
    NSParameterAssert(index < MAX_VALUES);
    return m_value[index];
}

- (void)setValue:(double)value atIndex:(NSUInteger)index;
{
    NSParameterAssert(index < MAX_VALUES);
    m_value[index] = value;
}

@end
