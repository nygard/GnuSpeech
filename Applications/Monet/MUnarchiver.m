//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

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
