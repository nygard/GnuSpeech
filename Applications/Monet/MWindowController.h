//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <AppKit/NSWindowController.h>

@interface MWindowController : NSWindowController
{
}

- (BOOL)isVisibleOnLaunch;
- (void)setIsVisibleOnLaunch:(BOOL)newFlag;

- (void)saveWindowIsVisibleOnLaunch;
- (void)showWindowIfVisibleOnLaunch;

@end
