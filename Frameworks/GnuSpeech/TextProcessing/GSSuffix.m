//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSSuffix.h"

@implementation GSSuffix

- (id)initWithSuffix:(NSString *)aSuffix replacementString:(NSString *)aReplacementString appendedPronunciation:(NSString *)anAppendedPronunciation;
{
    if ([super init] == nil)
        return nil;

    suffix = [aSuffix retain];
    replacementString = [aReplacementString retain];
    appendedPronunciation = [anAppendedPronunciation retain];

    return self;
}

- (void)dealloc;
{
    [suffix release];
    [replacementString release];
    [appendedPronunciation release];

    [super dealloc];
}

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

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: suffix: %@, replacementString: %@, appendedPronunciation: %@",
                     NSStringFromClass([self class]), self, suffix, replacementString, appendedPronunciation];
}

@end
