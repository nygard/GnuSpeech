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
//  MAIntonationView.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.5
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h> 

@class EventList, MMIntonationPoint;
@class MAIntonationScaleView;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@protocol MAIntonationViewNotification
- (void)intonationViewSelectionDidChange:(NSNotification *)aNotification;
@end

extern NSString *MAIntonationViewSelectionDidChangeNotification;

@interface MAIntonationView : NSView
{
    NSTextFieldCell *postureTextFieldCell;
    NSTextFieldCell *ruleIndexTextFieldCell;
    NSTextFieldCell *ruleDurationTextFieldCell;

    NSTextFieldCell *labelTextFieldCell;
    NSTextFieldCell *horizontalAxisLabelTextFieldCell;

    MAIntonationScaleView *scaleView;

    NSFont *timesFont;
    NSFont *timesFontSmall;

    EventList *eventList;

    float timeScale;

    NSMutableArray *selectedPoints;
    NSPoint selectionPoint1;
    NSPoint selectionPoint2;

    struct {
        unsigned int shouldDrawSelection:1;
        unsigned int shouldDrawSmoothPoints:1;
        unsigned int mouseBeingDragged:1;
    } flags;

    id nonretained_delegate;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)setScaleView:(MAIntonationScaleView *)newScaleView;

- (BOOL)acceptsFirstResponder;

- (void)setEventList:(EventList *)newEventList;

- (BOOL)shouldDrawSelection;
- (void)setShouldDrawSelection:(BOOL)newFlag;

- (BOOL)shouldDrawSmoothPoints;
- (void)setShouldDrawSmoothPoints:(BOOL)newFlag;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (float)minimumWidth;
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize;
- (void)resizeWidth;

- (void)drawRect:(NSRect)rect;

- (void)drawGrid;
- (void)drawHorizontalScale;
- (void)drawPostureLabels;
- (void)drawRules;
- (void)drawRuleBackground;
- (void)drawIntonationPoints;
- (void)drawSmoothPoints;

// Event handling
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)keyDown:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)mouseEvent;
- (void)mouseUp:(NSEvent *)mouseEvent;
- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

// Actions
- (IBAction)selectAll:(id)sender;
- (IBAction)delete:(id)sender;


- (void)updateScale:(float)column;

- (void)deselectAllPoints;

- (MMIntonationPoint *)selectedIntonationPoint;
- (void)selectIntonationPoint:(MMIntonationPoint *)anIntonationPoint;
- (void)_selectionDidChange;

// View geometry
- (int)sectionHeight;
- (NSPoint)graphOrigin;

- (void)updateEvents;


- (float)scaleXPosition:(float)xPosition;
- (float)scaleWidth:(float)width;
- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;

- (float)convertYPositionToSemitone:(float)yPosition;
- (float)convertXPositionToTime:(float)xPosition;

- (void)intonationPointDidChange:(NSNotification *)aNotification;
- (void)removeOldSelectedPoints;

- (void)setFrame:(NSRect)newFrame;

@end
