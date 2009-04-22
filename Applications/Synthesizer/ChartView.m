////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: David Hill
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
//  ChartView.m
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.3
//
////////////////////////////////////////////////////////////////////////////////

#import "ChartView.h"


#define ZERO_INDEX 2
#define SECTION_AMOUNT 10


@implementation ChartView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		[self setAxesWithScale:X_SCALE_DIVS xScaleOrigin:X_SCALE_ORIGIN xScaleSteps:X_SCALE_STEPS
				xLabelInterval:X_LABEL_INTERVAL yScaleDivs:Y_SCALE_DIVS yScaleOrigin:Y_SCALE_ORIGIN
							  yScaleSteps:Y_SCALE_STEPS yLabelInterval:Y_LABEL_INTERVAL];
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSRect viewRect = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:viewRect];
	[self drawGrid];
	[self addLabels];
	[self drawGraph];
}

- (void)drawGrid;
{
    NSBezierPath *bezierPath;
    NSRect bounds;
    NSPoint graphOrigin;
    float sectionHeight, sectionWidth;
    int index;
	
	// Draw in best fit grid markers
	
	bounds = [self bounds];
    graphOrigin = [self graphOrigin];
	sectionHeight = (bounds.size.height - graphOrigin.y - TOP_MARGIN)/_yScaleDivs;
	sectionWidth = (bounds.size.width - graphOrigin.x - RIGHT_MARGIN)/_xScaleDivs;
	
    [[NSColor lightGrayColor] set];
	NSPoint aPoint;
	
	//	First Y-axis grid lines
	
    [[NSColor lightGrayColor] set];
	
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
		for (index = 0; index <= _yScaleDivs; index++) {
		
		aPoint.x = graphOrigin.x;
		aPoint.y = graphOrigin.y + index * sectionHeight;
        [bezierPath moveToPoint:aPoint];
		
        aPoint.x = bounds.size.width - RIGHT_MARGIN;
        [bezierPath lineToPoint:aPoint];

    }
    [bezierPath stroke];
    [bezierPath release];
	
	/* then X-axis grid lines */
	
	bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	for (index = 0; index <= X_SCALE_DIVS; index++) {
		
		aPoint.y = graphOrigin.y;
        aPoint.x = graphOrigin.x + index * sectionWidth;
        [bezierPath moveToPoint:aPoint];
		
        aPoint.y = bounds.size.height - TOP_MARGIN;
        [bezierPath lineToPoint:aPoint];
		
    }
    [bezierPath stroke];
    [bezierPath release];
	
}

- (void)addLabels;
{
    NSBezierPath *bezierPath;
    NSRect bounds;
    NSPoint graphOrigin;
    float sectionHeight, sectionWidth, currentYPos, currentXPos;
	int i;
	
	bounds = [self bounds];
    graphOrigin = [self graphOrigin];
	sectionHeight = (bounds.size.height - graphOrigin.y - TOP_MARGIN)/_yScaleDivs;
	sectionWidth = (bounds.size.width - graphOrigin.x - RIGHT_MARGIN)/_xScaleDivs;
	

	// Add the axis labelling
	
	// First Y-axis
	
	[[NSColor greenColor] set];
    [timesFont set];
	
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	
	currentYPos = graphOrigin.y;
	
    for (i = 0; i <= _yScaleDivs; i+=_yLabelInterval) {
        NSString *label;
        NSSize labelSize;
		
        [bezierPath moveToPoint:NSMakePoint(graphOrigin.x, currentYPos)];
		currentYPos = graphOrigin.y + i * sectionHeight;
        label = [NSString stringWithFormat:@"%3.2f", i * _yScaleSteps + _yScaleOrigin];
        labelSize = [label sizeWithAttributes:nil];
        [label drawAtPoint:NSMakePoint(LEFT_MARGIN - LABEL_MARGIN - labelSize.width, currentYPos - labelSize.height/2) withAttributes:nil];

    }
	
    [bezierPath stroke];
    [bezierPath release];

	// Then the X-axis
	
	[[NSColor greenColor] set];
    [timesFont set];
	
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	
	currentXPos = graphOrigin.x;    
	for (i = 0; i <= _xScaleDivs; i+=_xLabelInterval) {
		
        NSString *label;
        NSSize labelSize;
		
		[bezierPath moveToPoint:graphOrigin];
        currentXPos = graphOrigin.x + i * sectionWidth;
        label = [NSString stringWithFormat:@"%5.0f", i * _xScaleSteps + _xScaleOrigin];
        labelSize = [label sizeWithAttributes:nil];
        [label drawAtPoint:NSMakePoint(currentXPos - labelSize.width/2, BOTTOM_MARGIN - LABEL_MARGIN - labelSize.height) withAttributes:nil];

    }
	
    [bezierPath stroke];
    [bezierPath release];
	
	
}

- (NSPoint)graphOrigin;
{
    NSPoint graphOrigin;
	
	graphOrigin = [self bounds].origin;
	graphOrigin.x += LEFT_MARGIN;
	graphOrigin.y += BOTTOM_MARGIN;
    return graphOrigin;
}

/*- (NSMutableArray *)makeData;
{
	// int i;
	NSMutableArray *data = [[NSMutableArray alloc] init];
	if (data == nil) return nil;
	[self drawGraph:data];
	return data;
}
*/

- (void)drawGraph;
{
	NSLog(@"ChartView");
    NSBezierPath *bezierPath;
    int index;
    NSPoint currentPoint;
    NSRect bounds;
    NSPoint graphOrigin;
	
    bounds = [self bounds];
    graphOrigin.x = (float) LEFT_MARGIN;
	graphOrigin.y = (float) BOTTOM_MARGIN;
	NSLog(@" Graph origin chart view is %f %f", graphOrigin.x, graphOrigin.y);
	
    [[NSColor blackColor] set];
	
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    [bezierPath moveToPoint:graphOrigin];
	
    for (index = 1; index <=3; index++) {

		currentPoint.x = graphOrigin.x + (float) index * 20;
		currentPoint.y = graphOrigin.y + (float) index * 20;
        [bezierPath lineToPoint:currentPoint];

    }
	[bezierPath stroke];
    [bezierPath release];
	
}

- (void)setAxesWithScale:(float)xScaleDivs xScaleOrigin:(float)xScaleOrigin xScaleSteps:(float)xScaleSteps
xLabelInterval:(int)xLabelInterval yScaleDivs:(float)yScaleDivs yScaleOrigin:(float)yScaleOrigin
yScaleSteps:(float)yScaleSteps yLabelInterval:(int)yLabelInterval;
{

	_xScaleDivs = xScaleDivs;
	_xScaleOrigin = xScaleOrigin;
	_xScaleSteps = xScaleSteps;
	_xLabelInterval = xLabelInterval;
	_yScaleDivs = yScaleDivs;
	_yScaleOrigin = yScaleOrigin;
	_yScaleSteps = yScaleSteps;
	_yLabelInterval = yLabelInterval;
	
}


@end
