//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Event.h"

#define MAX_VALUES 36

@implementation Event
{
    NSUInteger _time;
    BOOL _isAtPosture;
    double _value[MAX_VALUES];
}

- (id)initWithTime:(NSUInteger)time;
{
    if ((self = [super init])) {
        _time = time;
        _isAtPosture = NO;

        for (NSUInteger index = 0; index < MAX_VALUES; index++)
            _value[index] = NaN;
    }
    
    //NSLog(@"%@", self);

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> time: %lu, isAtPosture? %d, values: (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g) (%5.2g %5.2g %5.2g %5.2g %5.2g %5.2g)",
            NSStringFromClass([self class]), self,
            self.time, self.isAtPosture,
            _value[0], _value[1], _value[2], _value[3], _value[4], _value[5],
            _value[6], _value[7], _value[8], _value[9], _value[10], _value[11],
            _value[12], _value[13], _value[14], _value[15], _value[16], _value[17],
            _value[18], _value[19], _value[20], _value[21], _value[22], _value[23],
            _value[24], _value[25], _value[26], _value[27], _value[28], _value[29],
            _value[30], _value[31], _value[32], _value[33], _value[34], _value[35]];
}

#pragma mark -

- (double)getValueAtIndex:(NSUInteger)index;
{
    NSParameterAssert(index < MAX_VALUES);
    return _value[index];
}

- (void)setValue:(double)value atIndex:(NSUInteger)index;
{
    NSParameterAssert(index < MAX_VALUES);
    _value[index] = value;
}

@end
