//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMDisplayParameter.h"

#import <GnuSpeech/GnuSpeech.h>

@implementation MMDisplayParameter

- (id)initWithParameter:(MMParameter *)aParameter;
{
    if ([super init] == nil)
        return nil;

    parameter = [aParameter retain];
    isSpecial = NO;
    tag = 0;

    return self;
}

- (void)dealloc;
{
    [parameter release];

    [super dealloc];
}

- (MMParameter *)parameter;
{
    return parameter;
}

- (BOOL)isSpecial;
{
    return isSpecial;
}

- (void)setIsSpecial:(BOOL)newFlag;
{
    isSpecial = newFlag;
}

- (NSUInteger)tag;
{
    return tag;
}

- (void)setTag:(NSUInteger)newTag;
{
    tag = newTag;
}

- (BOOL)shouldDisplay;
{
    return shouldDisplay;
}

- (void)setShouldDisplay:(BOOL)newFlag;
{
    shouldDisplay = newFlag;
}

- (void)toggleShouldDisplay;
{
    shouldDisplay = !shouldDisplay;
}

- (NSString *)name;
{
    if (isSpecial == YES)
        return [NSString stringWithFormat:@"%@ (special)", [parameter name]];

    return [parameter name];
}

// Used in the EventList view
- (NSString *)label;
{
    if (isSpecial == YES)
        return [NSString stringWithFormat:@"%@\n(special)", [parameter name]];

    return [parameter name];
}

@end
