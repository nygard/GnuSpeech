//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "MUnarchiver.h"

@implementation MUnarchiver

- (void)dealloc;
{
    [m_userInfo release];

    [super dealloc];
}

@synthesize userInfo = m_userInfo;

@end
