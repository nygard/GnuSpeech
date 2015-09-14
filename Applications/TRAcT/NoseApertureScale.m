//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "NoseApertureScale.h"
#import "tube.h"

//#define ZERO_INDEX 2
//#define SECTION_AMOUNT 10

@implementation NoseApertureScale

- (id)initWithFrame:(NSRect)frameRect;
{

    if ((self = [super initWithFrame:frameRect]) != nil) {
        [self setAxesWithScale:X_SCALE_DIVS xScaleOrigin:X_SCALE_ORIGIN xScaleSteps:X_SCALE_STEPS
            xLabelInterval:X_LABEL_INTERVAL yScaleDivs:Y_SCALE_DIVS yScaleOrigin:Y_SCALE_ORIGIN
                yScaleSteps:Y_SCALE_STEPS yLabelInterval:Y_LABEL_INTERVAL];
        
        NSNotificationCenter *nc;
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(noseCoefChanged:) // Ditto for the apScale coef display
                   name:@"noseCoefChanged"
                 object:nil];
        NSLog(@"Added apScale as observer for noseCoefChanged");
        
    }

	return self;
}

/*
- (void)awakeFromNib;
{
	[self drawGraph];
}
*/

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
    //[bezierPath release];
	
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
    //[bezierPath release];
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
    //[bezierPath release];

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
    //[bezierPath release];
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

/******************************************************************************
 *
 *	function:	lpGain
 *
 *	purpose:	Returns the gain of the lowpass filter (a value from
 *                       0.0 to 1.0) according to the filter coefficients
 *                       a0 and b10, at the frequency omega (which
 *                       varies from 0 to Pi).
 *			
 *       arguments:      omega - value from 0 to Pi (Nyquist)
 *                       a0, b10 - filter coefficients
 *                       
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	cos, sin, sqrt
 *
 ******************************************************************************/

static float lpGain(float omega, float a0, float b1)
//static float lpGain(float omega, float a10, float b11)
{
    float c, d;
    
    c = 1.0 + (b1 * cos(omega));
    d = -b1 * sin(omega);
    
    return( fabs(a0) / sqrt((c * c) + (d * d)) );
}



/******************************************************************************
 *
 *	function:	hpGain
 *
 *	purpose:	Returns the gain of the highpass filter (a value from
 *                       0.0 to 1.0) according to the filter coefficients
 *                       a0, a1, and b1, at the frequency omega (which
 *                       varies from 0 to Pi).
 *			
 *       arguments:      omega - value from 0 to Pi (Nyquist)
 *                       a0, a1, b1 - filter coefficients
 *                       
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	cos, sin, sqrt
 *
 ******************************************************************************/

static float hpGain(float omega, float a0, float a1, float b1)
{
    float a, b, c, d, cosOmega, sinOmega;
    
    cosOmega = cos(omega);
    sinOmega = sin(omega);
    
    a = a0 + (a1 * cosOmega);
    b = -a1 * sinOmega;
    c = 1.0 + (b1 * cosOmega);
    d = -b1 * sinOmega;
    
    return( sqrt((a * a) + (b * b)) / sqrt((c * c) + (d * d)) );
}



- (void)drawGraph;
{
    //HERE IS WHERE WE PLOT THE LPGAIN AND HPGAIN DATA 
    
    // DECLARE LPGAIN & HPGAIN FILTER COEFFICIENTS
    
    float a10, b11, a20, a21, b21;
    
    //  CALCULATE FREQUENCY AND NYQUIST SCALES
    
    frequencyScale = NYQUIST_MAX/(_bounds.size.width - BOTTOM_MARGIN - TOP_MARGIN);
    nyquistScale = frequencyScale * PI;
    NSLog(@"sectionWidth is %f, sectionHeight is %f, nyquistScale is %f, frequencyScale is %f", _bounds.size.width, _bounds.size.height, nyquistScale, frequencyScale);
    
    //  CALCULATE NYQUIST AND NYQUIST GRAPHING POINT

    nyquistPoint = (int)(nyquist / frequencyScale);
    NSLog(@"nyquistPoint is %d, frequencyScale is %f", nyquistPoint, frequencyScale);
    NSPoint graphOrigin = NSMakePoint(LEFT_MARGIN, BOTTOM_MARGIN);
	NSLog(@" Graph origin ApFrequency m233 view is %@", NSStringFromPoint(graphOrigin));    
    
    float plotHeight = ((float)_bounds.size.height - (float)BOTTOM_MARGIN - (float)TOP_MARGIN); //271.0 - 45;
    float plotWidth = ((float)_bounds.size.width - (float)LEFT_MARGIN - (float)RIGHT_MARGIN); //440.0 - 60
    float sampleRate = (float) (*((int *) getSampleRate())); //20000.0; //Will be (*((int *) getSampleRate()))
    if (sampleRate == 0.0) sampleRate = 20000;
    nyquist = sampleRate/2;

    float temp = *((double *) getNoseCoef());
    NSLog(@"ApScale m:256 NoseCoeff is %f", temp);
    float omegaMax = nyquistScale/nyquist;
    frequencyScale = NYQUIST_MAX/plotWidth;
    nyquistScale = frequencyScale * PI;
    
    // CALCULATE FILTER COEFFICIENTS
    a20 = (nyquist - *((double *) getNoseCoef()))/nyquist; //Will be (nyquist - *((double *) getNoseCoef())), not nyquist - 4000
    NSLog(@"new coefficient is %f, a20 is %f", *((double *) getNoseCoef()), a20);
    a21 = b21 = b11 = -a20;
    a10 = 1.0 - fabs(b11);

    nyquistPoint = nyquist/frequencyScale;
    
// DRAW LPGAIN GRAPH
   	
    [[NSColor blackColor] set];
	
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	float amplitudeScale = (plotHeight)/ lpGain(omegaMax, a10, b11);
    NSLog(@"amplitudeScale is %f", amplitudeScale);

    for (NSUInteger index = 0; index <= nyquistPoint; index++) {
        NSPoint currentPoint;
        //NSLog(@"In for loop, nyquistPoint is %d index is %lu", nyquistPoint, index);
        float omega = index * nyquistScale/nyquist;
		currentPoint.x = graphOrigin.x + index; // ARBITRARY MULTIPLIER 7.5 SO I CAN SEE THE GRAPH
        
        // Y-VALUE TO BE PLOTTED
		currentPoint.y = graphOrigin.y + (lpGain(omega, a10, b11)) * amplitudeScale;
        
        if (index >= nyquistPoint) NSLog(@"Final currentPoint.y is %f", currentPoint.y);
        if (index == 0) [bezierPath moveToPoint:currentPoint];
        else [bezierPath lineToPoint:currentPoint];
        //NSLog(@"Omega = index * nyquistScale / nyquist = %f", ((float)index * nyquistScale)/nyquist);
    }
	[bezierPath stroke];
	
// NOW PLOT THE HPGAIN
    omegaMax = nyquistPoint * nyquistScale/nyquist;
    // amplitudeScale = (plotHeight) / hpGain(omegaMax, a20, a21, b21);

    for (NSUInteger index = 0; index <= nyquistPoint; index++) {
        NSPoint currentPoint;
        float omega = index * nyquistScale/nyquist;

		currentPoint.x = graphOrigin.x + index; // ARBITRARY MULTIPLIER 7.5 SO I CAN SEE THE GRAPH
        
        // Y-VALUE TO BE PLOTTED
		currentPoint.y = graphOrigin.y + hpGain(omega, a20, a21, b21) * amplitudeScale;
        // static float hpGain(float omega, float a0, float a1, float b1)
        if (index == 0) [bezierPath moveToPoint:currentPoint];
        else [bezierPath lineToPoint:currentPoint];        
    }
	[bezierPath stroke];
    
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

- (void)noseCoefChanged:(NSNotification *)note;
{
    
	NSLog(@"Nose coefficient change notification received and being acted on");
    
    [self lockFocus];
    mouthCoefChanged = 0;
    noseCoefChanged = 1;

    
    NSRect bounds = [self bounds];

    [self drawRect:bounds];
    [self unlockFocus];
    
}


@end
