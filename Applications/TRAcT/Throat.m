//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "ChartView.h"
#import "Throat.h"
#import "tube.h"

#define ZERO_INDEX 2
#define SECTION_AMOUNT 10

static float gain(float omega, float alpha, float beta);

@implementation Throat

- (id)initWithFrame:(NSRect)frameRect;
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setAxesWithScale:X_SCALE_DIVS xScaleOrigin:X_SCALE_ORIGIN xScaleSteps:X_SCALE_STEPS
				xLabelInterval:X_LABEL_INTERVAL yScaleDivs:Y_SCALE_DIVS yScaleOrigin:Y_SCALE_ORIGIN
                   yScaleSteps:Y_SCALE_STEPS yLabelInterval:Y_LABEL_INTERVAL];
	}
    NSNotificationCenter *nc;
    nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(throatCutoffChanged:) // Ditto for the apScale coef display
               name:@"throatCutoffChanged"
             object:nil];
    NSLog(@"Added Throat as observer for throatCutoffChanged");

	return self;
}

/******************************************************************************
 *
 *	function:	gain
 *
 *	purpose:	Returns the gain of the lowpass filter (a value from
 *                       0.0 to 1.0) according to the filter coefficients
 *                       alpha and beta, at the frequency omega (which
 *                       varies from 0 to Pi).
 *
 *       arguments:      omega - value from 0 to Pi (Nyquist)
 *                       alpha, beta - filter coefficients
 *
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	cos, sqrt
 *
 ******************************************************************************/

float gain(float omega, float alpha, float beta)
{
    return(alpha / sqrt(1.0 + beta * beta + 2.0 * beta * cos(omega)));
}

- (void)drawGraph;
{
    float alpha, beta, nyquist;
    int nyquistPoint;
    
    width = _bounds.size.width  - LEFT_MARGIN - RIGHT_MARGIN;
    height = _bounds.size.height - TOP_MARGIN - BOTTOM_MARGIN;
    
    //  CALCULATE FILTER COEFFICIENTS
    float cutoffFrequency = *((double *) getThroatCutoff());
    
    
    NSPoint graphOrigin = NSMakePoint(LEFT_MARGIN, BOTTOM_MARGIN);
	NSLog(@" Graph Throat view m70 view is %@", NSStringFromPoint(graphOrigin));
	
    //CALCULATE FILTER COEFFICIENTS
    beta = ((float)cutoffFrequency / (sampleRate/2.0)) - 1.0;
    alpha = 1.0 - fabs(beta);
    
    frequencyScale = NYQUIST_MAX/width;
    nyquistScale = frequencyScale * PI;
    nyquist = *((int *) getSampleRate())/2;
    nyquistPoint = (int)(nyquist / frequencyScale);
    NSLog(@"Sample rate is %d, nyquist is %f", *((int *) getSampleRate())/2, nyquist);
    
    [[NSColor blackColor] set];
	
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    
    [self lockFocus];
    
    [bezierPath setLineWidth:1];
    [bezierPath moveToPoint:graphOrigin];
	
    for (NSUInteger index = 0; index <= nyquistPoint; index++) {
        NSPoint currentPoint;
		currentPoint.x = graphOrigin.x + index;
		currentPoint.y = graphOrigin.y + height * gain(((float)index * nyquistScale)/nyquist, alpha, beta);
        if (index == 0) [bezierPath moveToPoint:currentPoint];
        [bezierPath lineToPoint:currentPoint];

    }
	[bezierPath stroke];
    //[bezierPath release];
	
    [self unlockFocus];
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



- (void)throatCutoffChanged:(NSNotification *)note;
{
    
	NSLog(@"throatCutoff change notification received and being acted on");
    
    [self lockFocus];
    
    
    
    [self drawRect:_bounds];
    
    
    [self unlockFocus];
}



@end
