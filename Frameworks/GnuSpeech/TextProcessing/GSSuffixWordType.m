//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSSuffixWordType.h"

@implementation GSSuffixWordType

- (id)initWithSuffix:(NSString *)suffix wordType:(NSString *)wordType;
{
    if ((self = [super init])) {
        _suffix   = suffix;
        _wordType = wordType;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> suffix: '%@', wordType: '%@'",
            NSStringFromClass([self class]), self,
            self.suffix, self.wordType];
}

@end
