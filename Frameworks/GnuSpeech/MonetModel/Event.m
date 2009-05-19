////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  Event.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import "Event.h"

#import <Foundation/Foundation.h>

@implementation Event

- (id)init;
{
    // TODO (2004-08-15): Reject unused method
    NSLog(@"-[%@ %s] should not be called", NSStringFromClass([self class]), _cmd);
    return nil;
}

- (id)initWithTime:(int)aTime;
{
    int index;

    if ([super init] == nil)
        return nil;

    time = aTime;
    flag = NO;

    for (index = 0; index < MAX_EVENTS; index++)
        events[index] = NaN;

    return self;
}

- (int)time;
{
    return time;
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
    //return [NSString stringWithFormat:@"<%@>[%p]: time: %d, flag: %d, events: (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g) (%g %g %g %g %g %g)",
    return [NSString stringWithFormat:@"<%@>[%p]: time: %d, flag: %d, events: (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g)",
                     NSStringFromClass([self class]), self, time, flag,
                     events[0], events[1], events[2], events[3], events[4], events[5],
                     events[6], events[7], events[8], events[9], events[10], events[11],
                     events[12], events[13], events[14], events[15], events[16], events[17],
                     events[18], events[19], events[20], events[21], events[22], events[23],
                     events[24], events[25], events[26], events[27], events[28], events[29],
                     events[30], events[31], events[32], events[33], events[34], events[35]];
}

@end
