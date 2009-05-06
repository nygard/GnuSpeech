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
//  MAIntonationScrollView.m
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.6
//
////////////////////////////////////////////////////////////////////////////////

#import "MAIntonationScrollView.h"

#import <AppKit/AppKit.h>
#import "MAIntonationView.h"
#import "MAIntonationScaleView.h"

@implementation MAIntonationScrollView

#define SCALE_WIDTH 50

- (id)initWithFrame:(NSRect)frameRect;
{
    NSRect contentFrame;
    MAIntonationView *intonationView;

    if ([super initWithFrame:frameRect] == nil)
        return nil;

    contentFrame.origin = NSZeroPoint;
    contentFrame.size = [self contentSize];
    intonationView = [[MAIntonationView alloc] initWithFrame:contentFrame];
    [self setDocumentView:intonationView];
    [intonationView release];

    [self addScaleView];

    return self;
}

- (void)dealloc;
{
    [scaleView release];

    [super dealloc];
}

// -initWithFrame: isn't used when loaded from a nib.
- (void)awakeFromNib;
{
    [self addScaleView];
}

- (void)addScaleView;
{
    NSSize contentSize;
    NSRect frameRect, scaleFrame;
    NSRect documentVisibleRect;

    contentSize = [self contentSize];
    frameRect = [self frame];

    scaleFrame = NSMakeRect(0, 0, SCALE_WIDTH, contentSize.height);
    scaleView = [[MAIntonationScaleView alloc] initWithFrame:scaleFrame];
    [self addSubview:scaleView];

    [[self documentView] setScaleView:scaleView];

    [self tile];

    documentVisibleRect = [self documentVisibleRect];

    [[self documentView] setFrame:documentVisibleRect];
    [[self documentView] setNeedsDisplay:YES];
}

- (void)tile;
{
    NSRect scaleFrame, contentFrame;

    [super tile];

    contentFrame.origin = NSZeroPoint;
    contentFrame.size = [self contentSize];
    NSDivideRect(contentFrame, &scaleFrame, &contentFrame, SCALE_WIDTH, NSMinXEdge);
    [scaleView setFrame:scaleFrame];
    [scaleView setNeedsDisplay:YES];
    [[self contentView] setFrame:contentFrame];
    [[self contentView] setNeedsDisplay:YES];
}

- (NSView *)scaleView;
{
    return scaleView;
}

- (NSSize)printableSize;
{
    NSSize scaleViewSize, printableSize;

    scaleViewSize = [scaleView frame].size;
    printableSize = [[self documentView] frame].size;
    printableSize.width += scaleViewSize.width;

    return printableSize;
}

@end
