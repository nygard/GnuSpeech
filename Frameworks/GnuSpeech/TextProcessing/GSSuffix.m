//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSSuffix.h"

@implementation GSSuffix
{
    NSString *suffix;
    NSString *replacementString;
    NSString *appendedPronunciation;
}

- (id)initWithSuffix:(NSString *)aSuffix replacementString:(NSString *)aReplacementString appendedPronunciation:(NSString *)anAppendedPronunciation;
{
    if ((self = [super init])) {
        suffix = aSuffix;
        replacementString = aReplacementString;
        appendedPronunciation = anAppendedPronunciation;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> suffix: %@, replacementString: %@, appendedPronunciation: %@",
            NSStringFromClass([self class]), self, suffix, replacementString, appendedPronunciation];
}

#pragma mark -

- (NSString *)suffix;
{
    return suffix;
}

- (NSString *)replacementString;
{
    return replacementString;
}

- (NSString *)appendedPronunciation;
{
    return appendedPronunciation;
}

@end
