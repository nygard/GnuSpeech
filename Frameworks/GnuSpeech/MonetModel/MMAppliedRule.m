//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMAppliedRule.h"

@implementation MMAppliedRule

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> rule number: %lu, firstPhone: %lu, lastPhone: %lu, duration: %f, beat: %f",
            NSStringFromClass([self class]), self,
            self.number, self.firstPhone, self.lastPhone, self.duration, self.beat];
}

@end
