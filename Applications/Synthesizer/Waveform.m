//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Waveform.h"
#import "syn_structs.h"
#import "tube.h"

@implementation Waveform
{
}

- (id)initWithFrame:(NSRect)frameRect;
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setAxesWithScale:WX_SCALE_DIVS xScaleOrigin:WX_SCALE_ORIGIN xScaleSteps:WX_SCALE_STEPS
				xLabelInterval:WX_LABEL_INTERVAL yScaleDivs:WY_SCALE_DIVS yScaleOrigin:WY_SCALE_ORIGIN
				   yScaleSteps:WY_SCALE_STEPS yLabelInterval:WY_LABEL_INTERVAL];
	}
	return self;
}

- (NSPoint)graphOrigin;
{
	NSPoint graphOrigin = [self bounds].origin;
	graphOrigin.x += WLEFT_MARGIN;
	graphOrigin.y += WBOTTOM_MARGIN;
    return graphOrigin;
}


- (void)drawGrid;
{
	NSLog(@"Drawing Waveform WF:28");
	// Draw in best fit grid markers
	
	NSRect bounds = [self bounds];
    NSPoint graphOrigin = [self graphOrigin];
	float sectionHeight = (bounds.size.height - graphOrigin.y - WTOP_MARGIN)/_yScaleDivs;
	float sectionWidth = (bounds.size.width - graphOrigin.x - WRIGHT_MARGIN)/_xScaleDivs;
	
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
		
        aPoint.x = bounds.size.width - WRIGHT_MARGIN;
        [bezierPath lineToPoint:aPoint];
    }
    [bezierPath stroke];
    [bezierPath release];
	
	/* then X-axis grid lines */
	
	bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	for (NSUInteger index = 0; index <= WX_SCALE_DIVS; index++) {
        NSPoint aPoint;
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

- (void)drawRect:(NSRect)rect;
{
	NSRect viewRect = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:viewRect];
	[self drawGrid];
	
	NSBezierPath *bezierPath;
    NSPoint currentPoint;
    NSPoint graphOrigin, start;
	
	int i;
    NSRect bounds = [self bounds];
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
	start.x = graphOrigin.x;
	start.y = (graphOrigin.y + (bounds.size.height - WBOTTOM_MARGIN - WTOP_MARGIN)/2);
    [bezierPath moveToPoint:start];
	NSLog(@"Waveform: the wave table value at index 100 is %f", tempFloatWavetable[100]);
	for (NSUInteger index = 0; index < 512; index++) {
		
		currentPoint.x = graphOrigin.x + ((float) index) * (bounds.size.width - graphOrigin.x - WLEFT_MARGIN - WRIGHT_MARGIN )/512;
		currentPoint.y = (graphOrigin.y + (bounds.size.height - WBOTTOM_MARGIN - WTOP_MARGIN)/2) + 40 * tempFloatWavetable[index];
        [bezierPath lineToPoint:currentPoint];
		
    }
	
	[bezierPath stroke];
    [bezierPath release];
	free(tempFloatWavetable);
}

- (void)drawSineAmplitude:(float)amplitude;
{
}

- (void)drawGlottalPulseAmplitude;
{
	[self setNeedsDisplay:YES];
	NSLog(@"Leaving WF: drawGlottalPulseAmplitude");
}

@end
