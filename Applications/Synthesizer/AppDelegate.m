//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "AppDelegate.h"

#import <Foundation/Foundation.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSLog(@" > %s", _cmd);

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldActivateOnLaunch"])
        [NSApp activateIgnoringOtherApps:YES];

    NSLog(@"<  %s", _cmd);
}

@end
