//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSSuffixReplacement.h"

@implementation GSSuffixReplacement
{
    NSString *_suffix;
    NSString *_replacementString;
    NSString *_appendedPronunciation;
}

- (id)initWithSuffix:(NSString *)suffix replacementString:(NSString *)replacementString appendedPronunciation:(NSString *)appendedPronunciation;
{
    if ((self = [super init])) {
        _suffix = suffix;
        _replacementString = replacementString;
        _appendedPronunciation = appendedPronunciation;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> suffix: %@, replacementString: %@, appendedPronunciation: %@",
            NSStringFromClass([self class]), self,
            self.suffix, self.replacementString, self.appendedPronunciation];
}

@end
