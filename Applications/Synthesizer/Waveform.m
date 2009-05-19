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
//  Waveform.m
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////

#import "Waveform.h"
#import "structs.h"

@implementation Waveform

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		[self setAxesWithScale:WX_SCALE_DIVS xScaleOrigin:WX_SCALE_ORIGIN xScaleSteps:WX_SCALE_STEPS
				xLabelInterval:WX_LABEL_INTERVAL yScaleDivs:WY_SCALE_DIVS yScaleOrigin:WY_SCALE_ORIGIN
				   yScaleSteps:WY_SCALE_STEPS yLabelInterval:WY_LABEL_INTERVAL];
	}
	return self;
}

- (NSPoint)graphOrigin;
{
    NSPoint graphOrigin;
	
	graphOrigin = [self bounds].origin;
	graphOrigin.x += WLEFT_MARGIN;
	graphOrigin.y += WBOTTOM_MARGIN;
    return graphOrigin;
}


- (void)drawGrid;
{
	NSLog(@"Drawing Waveform WF:28");
    NSBezierPath *bezierPath;
    NSRect bounds;
    NSPoint graphOrigin;
    float sectionHeight, sectionWidth;
    int index;
	
	// Draw in best fit grid markers
	
	bounds = [self bounds];
    graphOrigin = [self graphOrigin];
	sectionHeight = (bounds.size.height - graphOrigin.y - WTOP_MARGIN)/_yScaleDivs;
	sectionWidth = (bounds.size.width - graphOrigin.x - WRIGHT_MARGIN)/_xScaleDivs;
	
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
		
        aPoint.x = bounds.size.width - WRIGHT_MARGIN;
        [bezierPath lineToPoint:aPoint];
		
    }
    [bezierPath stroke];
    [bezierPath release];
	
	/* then X-axis grid lines */
	
	bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	for (index = 0; index <= WX_SCALE_DIVS; index++) {
		
		aPoint.y = graphOrigin.y;
        aPoint.x = graphOrigin.x + index * sectionWidth;
        [bezierPath moveToPoint:aPoint];
		
        aPoint.y = bounds.size.height - WTOP_MARGIN;
        [bezierPath lineToPoint:aPoint];
		
    }
    [bezierPath stroke];
    [bezierPath release];
	
}


// This method overrides the ChartView method

- (void)drawRect:(NSRect)rect

{
	NSRect viewRect = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:viewRect];
	[self drawGrid];
	
	NSBezierPath *bezierPath;
    int index;
    NSPoint currentPoint;
    NSRect bounds;
    NSPoint graphOrigin, start;
	
	int i;
    bounds = [self bounds];
    graphOrigin.x = (float) WLEFT_MARGIN;
	graphOrigin.y = (float) WBOTTOM_MARGIN;
	NSLog(@" Graph origin waveform is %f %f", graphOrigin.x, graphOrigin.y);
	NSLog(@"Entering WF: drawGlottalPulseAmplitude");
	
	//updateWavetable(* (double *) getGlotVol());
	
	// Copy the current wavetable values
	tempFloatWavetable = (float *)calloc(TABLE_LENGTH, sizeof(float));
	for (i = 0; i < 512; i++)  {  // move data to transform buffer
		tempFloatWavetable[i] = (float) (*((double *) getWavetable(i)));
		//NSLog(@"wavetable %d, %f",i, tempFloatWavetable[i]);
	}
	
	
	[[NSColor blackColor] set];
	
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	[bezierPath setCachesBezierPath:NO];
	start.x = graphOrigin.x;
	start.y = (graphOrigin.y + (bounds.size.height - WBOTTOM_MARGIN - WTOP_MARGIN)/2);
    [bezierPath moveToPoint:start];
	NSLog(@"Waveform: the wave table value at index 100 is %f", tempFloatWavetable[100]);
	for (index = 0; index < 512; index++) {
		
		currentPoint.x = graphOrigin.x + ((float) index) * (bounds.size.width - graphOrigin.x - WLEFT_MARGIN - WRIGHT_MARGIN )/512;
		currentPoint.y = (graphOrigin.y + (bounds.size.height - WBOTTOM_MARGIN - WTOP_MARGIN)/2) + 40 * tempFloatWavetable[index];
        [bezierPath lineToPoint:currentPoint];
		
    }
	
	[bezierPath stroke];
    [bezierPath release];
	free(tempFloatWavetable);
	
	
}

- (void)drawSineAmplitude:(float)amplitude
{
	
}

- (void)drawGlottalPulseAmplitude


{
	[self setNeedsDisplay:YES];
	NSLog(@"Leaving WF: drawGlottalPulseAmplitude");
	
}



@end
