//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

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

- (void)saveWindowIsVisibleOnLaunch;
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
