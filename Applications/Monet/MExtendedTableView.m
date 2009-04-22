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
//  MExtendedTableView.m
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.5
//
////////////////////////////////////////////////////////////////////////////////

#import "MExtendedTableView.h"

#import <AppKit/AppKit.h>

@interface NSObject (MExtendedTableViewMethods)
- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;
@end

@implementation MExtendedTableView

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    lastTimestamp = 0.0;
    combinedCharacters = [[NSMutableString alloc] init];

    return self;
}

- (void)dealloc;
{
    [combinedCharacters release];

    [super dealloc];
}

// This doesn't get init'd when loaded from a nib, so we need to initialize the instance variables here.
- (void)awakeFromNib;
{
    lastTimestamp = 0.0;
    if (combinedCharacters == nil)
        combinedCharacters = [[NSMutableString alloc] init];
}

#define COMBINE_INTERVAL 0.2

- (void)keyDown:(NSEvent *)keyEvent;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"characters: %@", [keyEvent characters]);
    //NSLog(@"characters ignoring modifiers: %@", [keyEvent charactersIgnoringModifiers]);
    //NSLog(@"character count: %d", [[keyEvent characters] length]);

    if ([keyEvent timestamp] - lastTimestamp > COMBINE_INTERVAL)
        [combinedCharacters setString:@""];

    lastTimestamp = [keyEvent timestamp];
    [combinedCharacters appendString:[keyEvent characters]];

    if ([[self delegate] respondsToSelector:@selector(control:shouldProcessCharacters:)] == NO ||
        [[self delegate] control:self shouldProcessCharacters:combinedCharacters] == YES) {
        [super keyDown:keyEvent];
        [combinedCharacters setString:@""];
    }

    //NSLog(@"<  %s", _cmd);
}

- (void)doNotCombineNextKey;
{
    lastTimestamp = 0;
}

@end
