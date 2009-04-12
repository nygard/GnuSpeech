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
//  MCommentCell.m
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.4
//
////////////////////////////////////////////////////////////////////////////////

#import "MCommentCell.h"

#import <AppKit/AppKit.h>

static NSImage *_commentIcon = nil;

@implementation MCommentCell

+ (void)initialize;
{
    NSBundle *mainBundle;
    NSString *path;

    mainBundle = [NSBundle mainBundle];
    path = [mainBundle pathForResource:@"CommentIcon" ofType:@"tiff"];
    _commentIcon = [[NSImage alloc] initWithContentsOfFile:path];
}

// TODO (2004-08-24): Double clicking on the icon in the rule manager copies the cell, which calls -setObjectValue: with a non-NSNumber value, raising a "selector not recognized" exception.
- (void)setObjectValue:(id)newObjectValue;
{
    if ([newObjectValue boolValue] == YES)
        [super setObjectValue:_commentIcon];
    else
        [super setObjectValue:nil];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
