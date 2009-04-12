////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard, Dalmazio Brisinda
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
//  EventListView.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.3
//
////////////////////////////////////////////////////////////////////////////////

#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet
#import <AppKit/NSTextField.h>
#import <Foundation/NSNotification.h>

@class NSTextFieldCell;
@class EventList;
@class AppController;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface EventListView : NSView
{
    NSFont *timesFont;
    NSFont *timesFontSmall;

    EventList *eventList;

	NSTextField *mouseTimeField;
	NSTextField *mouseValueField;

    int startingIndex;
    float timeScale;
    BOOL mouseBeingDragged;
    NSTrackingRectTag trackTag;

    NSTextFieldCell *ruleCell;
    NSTextFieldCell *minMaxCell;
    NSTextFieldCell *parameterNameCell;

    NSArray *displayParameters;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)awakeFromNib;

- (NSArray *)displayParameters;
- (void)setDisplayParameters:(NSArray *)newDisplayParameters;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:(EventList *)newEventList;

- (BOOL)isOpaque;
- (void)drawRect:(NSRect)rects;

- (void)clearView;
- (void)drawGrid;
- (void)drawRules;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;
- (void)mouseMoved:(NSEvent *)theEvent;

- (void)updateScale:(float)column;

- (void)frameDidChange:(NSNotification *)aNotification;
- (void)resetTrackingRect;

- (float)scaledX:(float)x;
- (float)scaledWidth:(float)width;

- (float)parameterValueForYCoord:(float)y;

// Handle sizing and correct drawing of the main view.
- (void)resize;
- (float)minimumWidth;
- (float)minimumHeight;
- (float)scaleWidth:(float)width;
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize;

// Allow access to mouse tracking fields.
- (void)setMouseTimeField:(NSTextField *)mtField;
- (void)setMouseValueField:(NSTextField *)mvField;

@end
