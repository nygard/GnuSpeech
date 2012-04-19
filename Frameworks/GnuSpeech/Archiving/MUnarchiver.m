//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "MUnarchiver.h"

#import <Foundation/Foundation.h>

@implementation MUnarchiver

- (void)dealloc;
{
    [userInfo release];

    [super dealloc];
}

- (id)userInfo;
{
    return userInfo;
}

- (void)setUserInfo:(id)newUserInfo;
{
    if (newUserInfo == userInfo)
        return;

    [userInfo release];
    userInfo = [newUserInfo retain];
}

@end
