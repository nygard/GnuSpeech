//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class MGlottalSourceController;

@interface AppDelegate : NSObject
{
    MGlottalSourceController *glottalSourceController;
}

- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)notification;

- (MGlottalSourceController *)glottalSourceController;

- (IBAction)showGlottalSourceController:(id)sender;

@end
