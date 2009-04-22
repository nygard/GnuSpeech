////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MWindowController.m
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.5
//
////////////////////////////////////////////////////////////////////////////////

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
