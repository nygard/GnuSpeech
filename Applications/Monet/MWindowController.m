//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import "MWindowController.h"

#import <AppKit/AppKit.h>

@implementation MWindowController

- (BOOL)isVisibleOnLaunch;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"VisibleOnLaunch %@", [self windowFrameAutosaveName]]];
}

- (void)setIsVisibleOnLaunch:(BOOL)newFlag;
{
    [[NSUserDefaults standardUserDefaults] setBool:newFlag forKey:[NSString stringWithFormat:@"VisibleOnLaunch %@", [self windowFrameAutosaveName]]];
}

- (void)saveWidnowIsVisibleOnLaunch;
{
    // Don't load the window if it hasn't already been loaded.
    if ([self isWindowLoaded] == YES && [[self window] isVisible] == YES)
        [self setIsVisibleOnLaunch:YES];
    else
        [self setIsVisibleOnLaunch:NO];
}

- (void)showWindowIfVisibleOnLaunch;
{
    if ([self isVisibleOnLaunch] == YES)
        [self showWindow:nil];
}

@end
