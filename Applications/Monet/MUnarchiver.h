//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <Foundation/NSArchiver.h>

@interface MUnarchiver : NSUnarchiver
{
    id userInfo;
}

- (void)dealloc;

- (id)userInfo;
- (void)setUserInfo:(id)newUserInfo;

@end
