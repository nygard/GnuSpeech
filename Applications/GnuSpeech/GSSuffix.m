//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "GSSuffix.h"

#import <Foundation/Foundation.h>

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
