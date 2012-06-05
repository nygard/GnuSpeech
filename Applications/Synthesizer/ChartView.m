//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "ChartView.h"

#define ZERO_INDEX 2
#define SECTION_AMOUNT 10

@implementation ChartView

- (id)initWithFrame:(NSRect)frameRect;
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setAxesWithScale:X_SCALE_DIVS xScaleOrigin:X_SCALE_ORIGIN xScaleSteps:X_SCALE_STEPS
				xLabelInterval:X_LABEL_INTERVAL yScaleDivs:Y_SCALE_DIVS yScaleOrigin:Y_SCALE_ORIGIN
                   yScaleSteps:Y_SCALE_STEPS yLabelInterval:Y_LABEL_INTERVAL];
	}

	return self;
}

- (void)drawRect:(NSRect)rect;
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
	// Draw in best fit grid markers
	
	NSRect bounds = [self bounds];
    NSPoint graphOrigin = [self graphOrigin];
	float sectionHeight = (bounds.size.height - graphOrigin.y - TOP_MARGIN)/_yScaleDivs;
	float sectionWidth = (bounds.size.width - graphOrigin.x - RIGHT_MARGIN)/_xScaleDivs;
	
    [[NSColor lightGrayColor] set];
	
	//	First Y-axis grid lines
	
    [[NSColor lightGrayColor] set];
	
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    for (NSUInteger index = 0; index <= _yScaleDivs; index++) {
        NSPoint aPoint;
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
	for (NSUInteger index = 0; index <= X_SCALE_DIVS; index++) {
        NSPoint aPoint;
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
	NSRect bounds = [self bounds];
    NSPoint graphOrigin = [self graphOrigin];
	float sectionHeight = (bounds.size.height - graphOrigin.y - TOP_MARGIN)/_yScaleDivs;
	float sectionWidth = (bounds.size.width - graphOrigin.x - RIGHT_MARGIN)/_xScaleDivs;
	

	// Add the axis labelling
	
	// First Y-axis
	
	[[NSColor greenColor] set];
    [timesFont set];
	
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	
	float currentYPos = graphOrigin.y;
	
    for (NSUInteger index = 0; index <= _yScaleDivs; index+=_yLabelInterval) {
        [bezierPath moveToPoint:NSMakePoint(graphOrigin.x, currentYPos)];
		currentYPos = graphOrigin.y + index * sectionHeight;
        NSString *label = [NSString stringWithFormat:@"%3.2f", index * _yScaleSteps + _yScaleOrigin];
        NSSize labelSize = [label sizeWithAttributes:nil];
        [label drawAtPoint:NSMakePoint(LEFT_MARGIN - LABEL_MARGIN - labelSize.width, currentYPos - labelSize.height/2) withAttributes:nil];

    }
	
    [bezierPath stroke];
    [bezierPath release];

	// Then the X-axis
	
	[[NSColor greenColor] set];
    [timesFont set];
	
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	
	float currentXPos = graphOrigin.x;
	for (NSUInteger index = 0; index <= _xScaleDivs; index+=_xLabelInterval) {
		[bezierPath moveToPoint:graphOrigin];
        currentXPos = graphOrigin.x + index * sectionWidth;
        NSString *label = [NSString stringWithFormat:@"%5.0f", index * _xScaleSteps + _xScaleOrigin];
        NSSize labelSize = [label sizeWithAttributes:nil];
        [label drawAtPoint:NSMakePoint(currentXPos - labelSize.width/2, BOTTOM_MARGIN - LABEL_MARGIN - labelSize.height) withAttributes:nil];

    }
	
    [bezierPath stroke];
    [bezierPath release];
}

- (NSPoint)graphOrigin;
{
	NSPoint graphOrigin = [self bounds].origin;
	graphOrigin.x += LEFT_MARGIN;
	graphOrigin.y += BOTTOM_MARGIN;
    return graphOrigin;
}

#if 0
- (NSMutableArray *)makeData;
{
	NSMutableArray *data = [[NSMutableArray alloc] init];
	if (data == nil) return nil;
	[self drawGraph:data];
	return data;
}
#endif

- (void)drawGraph;
{
    NSPoint graphOrigin = NSMakePoint(LEFT_MARGIN, BOTTOM_MARGIN);
	NSLog(@" Graph origin chart view is %@", NSStringFromPoint(graphOrigin));
	
    [[NSColor blackColor] set];
	
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    [bezierPath moveToPoint:graphOrigin];
	
    for (NSUInteger index = 1; index <= 3; index++) {
        NSPoint currentPoint;
		currentPoint.x = graphOrigin.x + (float)index * 20;
		currentPoint.y = graphOrigin.y + (float)index * 20;
        [bezierPath lineToPoint:currentPoint];

    }
	[bezierPath stroke];
    [bezierPath release];
	
}

- (void)setAxesWithScale:(float)xScaleDivs xScaleOrigin:(float)xScaleOrigin xScaleSteps:(float)xScaleSteps
          xLabelInterval:(int)xLabelInterval yScaleDivs:(float)yScaleDivs yScaleOrigin:(float)yScaleOrigin
             yScaleSteps:(float)yScaleSteps yLabelInterval:(int)yLabelInterval;
{

	_xScaleDivs     = xScaleDivs;
	_xScaleOrigin   = xScaleOrigin;
	_xScaleSteps    = xScaleSteps;
	_xLabelInterval = xLabelInterval;
    
	_yScaleDivs     = yScaleDivs;
	_yScaleOrigin   = yScaleOrigin;
	_yScaleSteps    = yScaleSteps;
	_yLabelInterval = yLabelInterval;
	
}

@end
