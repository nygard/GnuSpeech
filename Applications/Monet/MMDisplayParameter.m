//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMDisplayParameter.h"

#import <Foundation/Foundation.h>

#import "MMParameter.h"

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

- (int)tag;
{
    return tag;
}

- (void)setTag:(int)newTag;
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

- (NSString *)name;
{
    if (isSpecial == YES)
        return [NSString stringWithFormat:@"%@ (special)", [parameter symbol]];

    return [parameter symbol];
}

// Used in the EventList view
- (NSString *)label;
{
    if (isSpecial == YES)
        return [NSString stringWithFormat:@"%@\n(special)", [parameter symbol]];

    return [parameter symbol];
}

@end
