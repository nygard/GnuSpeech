//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "AppDelegate.h"

#import <Foundation/Foundation.h>

#import "MGlottalSourceController.h"

@implementation AppDelegate

- (void)dealloc;
{
    [glottalSourceController release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSLog(@" > %s", _cmd);

    [[self glottalSourceController] showWindowIfVisibleOnLaunch];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldActivateOnLaunch"])
        [NSApp activateIgnoringOtherApps:YES];

    NSLog(@"<  %s", _cmd);
}

- (void)applicationWillTerminate:(NSNotification *)notification;
{
    [[self glottalSourceController] saveWindowIsVisibleOnLaunch];
}

- (MGlottalSourceController *)glottalSourceController;
{
    if (glottalSourceController == nil)
        glottalSourceController = [[MGlottalSourceController alloc] init];

    return glottalSourceController;
}

- (IBAction)showGlottalSourceController:(id)sender;
{
    [self glottalSourceController]; // Make sure it's been created
    [glottalSourceController showWindow:self];
}

@end
