//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFRuleSymbols.h"

@implementation MMFRuleSymbols
{
    double _ruleDuration; // 0
    double _beat;         // 1
    double _mark1;        // 2
    double _mark2;        // 3
    double _mark3;        // 4
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> duration: %f, beat: %f, mark1: %f, mark2: %f, mark3: %f",
            NSStringFromClass([self class]), self,
            self.ruleDuration, self.beat, self.mark1, self.mark2, self.mark3];
}

@end

