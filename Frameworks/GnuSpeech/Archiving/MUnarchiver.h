//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import <Foundation/Foundation.h>

@interface MUnarchiver : NSUnarchiver

// TODO (2012-04-20): Make this a dictionary, to be consistent with what userInfos usually are.
@property (strong) id userInfo;

@end
