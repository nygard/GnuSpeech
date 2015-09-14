//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Harmonics.h"

#import "tube.h"

#define VOLUME_MAX  60
#define LINEAR	0
#define LOG		1

@implementation Harmonics
{
}

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setAxesWithScale:HX_SCALE_DIVS xScaleOrigin:HX_SCALE_ORIGIN xScaleSteps:HX_SCALE_STEPS
				xLabelInterval:HX_LABEL_INTERVAL yScaleDivs:HY_SCALE_DIVS yScaleOrigin:HY_SCALE_ORIGIN
				   yScaleSteps:HY_SCALE_STEPS yLabelInterval:HY_LABEL_INTERVAL];
	}

	return self;
}

// This method over-rides the ChartView method
- (void)drawRect:(NSRect)rect;
{
	NSRect viewRect = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:viewRect];
	[self drawGrid];
	[self addLabels];
	//[self drawGraph];
	
    int index;
    NSPoint currentPoint;
    NSPoint graphOrigin, start;
	
	int i, numberHarmonics;
    NSRect bounds = [self bounds];
    graphOrigin.x = (float) HLEFT_MARGIN;
	graphOrigin.y = (float) HBOTTOM_MARGIN;
	NSLog(@" Graph origin harmonics is %f %f", graphOrigin.x, graphOrigin.y);
	NSLog(@"Entering H: drawHarmonics");
	
	
	// Copy the current wavetable values
	tempFloatWavetable = (float *)calloc(TABLE_LENGTH, sizeof(float));
	for (i = 0; i < 512; i++)  {  // move data to transform buffer
		tempFloatWavetable[i] = 100 * (float) (*((double *) getWavetable(i)));
		
	}
	
	
	realfft(tempFloatWavetable, TABLE_LENGTH);
	NSLog(@"FFT for drawHarmonics done");
	
	
	[[NSColor blackColor] set];
	
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:3];
    start = graphOrigin;
    [bezierPath moveToPoint:start];
	
	numberHarmonics = (int) (bounds.size.width - HLEFT_MARGIN - HRIGHT_MARGIN) / (BAR_WIDTH + BAR_MARGIN);
	
	currentPoint.x = graphOrigin.x;
	
	float max = 0.0;
	int foo;
	for (i = 0; i < 255; i++) {
		if (tempFloatWavetable[i] > max) {
			max = tempFloatWavetable[i];	
			foo = i;
		}
	}
	
	NSLog(@"Max is %f, index was %d", max, foo);
	
	for (index = 0; index <= numberHarmonics - 1; index++) {
		
		start.x += (BAR_WIDTH + BAR_MARGIN);
		[bezierPath moveToPoint:start]; //sets bottom of next bar graph element
		
		
		currentPoint.x = start.x;
		currentPoint.y = graphOrigin.y + bounds.size.height - HBOTTOM_MARGIN - HTOP_MARGIN + 20 * log10((tempFloatWavetable[index])/max);
		if (currentPoint.y > graphOrigin.y)
			[bezierPath lineToPoint:currentPoint]; // Draw bar graph element (pow(10.0,(decibelLevel/20.0)))
		
    }
	
	[bezierPath stroke];
    [bezierPath release];
	free(tempFloatWavetable);
	
}


- (NSPoint)graphOrigin;
{
	NSPoint graphOrigin = [self bounds].origin;
	graphOrigin.x += HLEFT_MARGIN;
	graphOrigin.y += HBOTTOM_MARGIN;
    return graphOrigin;
}


- (void)drawGrid;
{
    NSBezierPath *bezierPath;
    NSRect bounds;
    NSPoint graphOrigin;
    float sectionHeight, sectionWidth;
	
	bounds = [self bounds];
    graphOrigin = [self graphOrigin];
	sectionHeight = (bounds.size.height - graphOrigin.y - HTOP_MARGIN)/_yScaleDivs;
	sectionWidth = (bounds.size.width - graphOrigin.x - HRIGHT_MARGIN)/_xScaleDivs;
	
    [[NSColor lightGrayColor] set];
	NSPoint aPoint;
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	[bezierPath moveToPoint:graphOrigin];
	aPoint.x = graphOrigin.x;
	aPoint.y += (bounds.size.height - HTOP_MARGIN);
	[bezierPath lineToPoint:aPoint];
	aPoint.x += bounds.size.width - HRIGHT_MARGIN - HLEFT_MARGIN;
	[bezierPath lineToPoint:aPoint];
	aPoint.y = graphOrigin.y;
	[bezierPath lineToPoint:aPoint];
	aPoint.x = graphOrigin.x;
	[bezierPath lineToPoint:aPoint];
	[bezierPath closePath];
	[bezierPath stroke];
    [bezierPath release];
	
    // Draw in best fit grid markers
    // First Y-axis grid lines
	
    [[NSColor lightGrayColor] set];
	
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	for (NSUInteger index = 0; index < _yScaleDivs; index++) {
		aPoint.x = graphOrigin.x;
		aPoint.y = graphOrigin.y + index * sectionHeight;
        [bezierPath moveToPoint:aPoint];
		
        aPoint.x = bounds.size.width - HRIGHT_MARGIN;
        [bezierPath lineToPoint:aPoint];
    }

    [bezierPath stroke];
    [bezierPath release];
}
	
#pragma mark - Axis Labels

- (void)addLabels;
{
	NSRect bounds = [self bounds];
    NSPoint graphOrigin = [self graphOrigin];
	float sectionHeight = (bounds.size.height - graphOrigin.y - HTOP_MARGIN) / _yScaleDivs;
	//float sectionWidth = (bounds.size.width - graphOrigin.x - HRIGHT_MARGIN) / _xScaleDivs;
	
	// First Y-axis labels
	
	[[NSColor greenColor] set];
	NSLog(@"H: Set green colour");
    [timesFont set];
	
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	
	float currentYPos = graphOrigin.y;
	
    for (NSUInteger index = 0; index <= _yScaleDivs; index += _yLabelInterval) {
        [bezierPath moveToPoint:NSMakePoint(graphOrigin.x, currentYPos)];
		currentYPos = graphOrigin.y + index  * sectionHeight;
        NSString *label = [NSString stringWithFormat:@"%3.0f", (int)index  * _yScaleSteps + (int)_yScaleOrigin];
        NSSize labelSize = [label sizeWithAttributes:nil];
        [label drawAtPoint:NSMakePoint(HLEFT_MARGIN - LABEL_MARGIN - labelSize.width,
									   currentYPos - labelSize.height/2) withAttributes:nil];
    }
	
    [bezierPath stroke];
    [bezierPath release];
}


- (void)drawSineScale:(float)amplitude;
{
}

- (void)drawHarmonics;
{
	[self setNeedsDisplay:YES];
	NSLog(@"Leaving H: drawHarmonics");
}

//- (void)drawGraph

// Note that this is a method of the super class -- ChartView

//{
//	[self drawHarmonics];
//}


#if 0
- (void)drawLogGrid;
{
    float verticalIncrement;
    int i, verticalLines;
    NSFont *fontObject1;
    
    //  SET UP FONT  
    fontObject1 = [NSFont fontWithName: FONT size: LOG_FONT_SIZE];
    
    //  LOCK FOCUS ON BACKGROUND NXIMAGE  
    [logGrid lockFocus];
    
    //  DRAW WHITE BACKGROUND WITH BORDER  
    NSDrawWhiteBezel([self bounds] , [self bounds]);
    
    //  DRAW LIGHT GRAY ENCLOSURE  
    PSrectangle(NSMinX(activeArea), NSMinY(activeArea),
                NSWidth(activeArea), NSHeight(activeArea),
                1.0, NSLightGray);
    
    //  DRAW HORIZONTAL LINES  
    verticalLines = (int)(LOG_SCALE_RANGE / 10.0);
    verticalIncrement = NSHeight(activeArea) / (float)verticalLines;
    for (i = 1; i < verticalLines; i++) {
        PSmoveto(NSMinX(activeArea),
                 NSMinY(activeArea) + ((float)i * verticalIncrement));
        PSrlineto(NSWidth(activeArea), 0.0);
    }
    PSstroke();
    
    //  NUMBER HORIZONTAL LINES  
    [fontObject1 set];
    PSsetgray(NSBlack);
    for (i = 0; i <= verticalLines; i++) {
        char number[12];
        float px, py;
        int numberValue = -(i * 10);
        
        //  FORMAT THE NUMBER  
        sprintf(number, "%-d", numberValue);
        
        //  DETERMINE STRING WIDTH  
        PSstringwidth(number, &px, &py);
        
        PSmoveto(NSMinX(activeArea) - px - NUMBER_MARGIN,
                 NSMaxY(activeArea) - ((float)i * verticalIncrement)
                 - LOG_FONT_SIZE / 2.0 + 1.0);
        
        //  DRAW THE NUMBER ON THE GRID  
        PSshow(number);
    }
    
    //  UNLOCK FOCUS ON BACKGROUND NXIMAGE  
    [logGrid unlockFocus]; 
}



- (void)drawSineHarmonics;
{
    //  LOCK FOCUS ON NXIMAGE  
    [sineHarmonics lockFocus];

    //  CLEAR THE NXIMAGE  
    [sineHarmonics compositeToPoint:[self bounds].origin operation:NSCompositeClear];

    //  DRAW THE 1ST HARMONIC  
    PSsetgray(NSBlack);
    PSrectfill(NSMinX(activeArea) + BAR_MARGIN + 1.0, NSMinY(activeArea),
	       BAR_WIDTH, NSHeight(activeArea));

    //  UNLOCK FOCUS ON NXIMAGE  
    [sineHarmonics unlockFocus]; 
}



- (void)drawSineScale:(BOOL)scale;
{
    //  RECORD THE SCALE  
    logScale = scale;

    //  USE SINE HARMONICS NXIMAGE  
    harmonics = HARMONICS_SINE;

    //  DISPLAY THE COMBINED IMAGES  
    [self display]; 
}



- (void)drawGlottalPulseAmplitude:(float)amplitude RiseTime:(float)riseTime FallTimeMin
								 :(float)fallTimeMin FallTimeMax:(float)fallTimeMax Scale:(BOOL)scale
{
    NSLog(@"drawGlottalPulseAmplitude::: called Harmonics m:310");
    int i, firstDivision, secondDivision;
    double fall, delta;
    
    //  RECORD THE SCALE  
    logScale = scale;
    
    //  USE GLOTTAL PULSE HARMONICS NXIMAGE  
    harmonics = HARMONICS_GP;
    
    //  FILL THE WAVETABLE  
    //  CALCULATE TABLE DIVISIONS  
    firstDivision = (int)rint((double)(riseTime/100.0 * (double)tableSize));
    delta = (fallTimeMax - fallTimeMin) * amplitude;
    fall = (riseTime + fallTimeMax - delta)/100.0 * (double)tableSize;
    secondDivision = (int)rint((double)fall);
    
    //  CALCULATE RISE PORTION  
    for (i = 0; i < firstDivision; i++) {
        float x = (float)i / (float)firstDivision;
        float x2 = x * x;
        float x3 = x * x2;
        wavetable[i] = (3.0 * x2) - (2.0 * x3);
    }
    
    //  CALCULATE FALL PORTION  
    for (i = firstDivision; i < secondDivision; i++) {
        float x = (float)(i - firstDivision) /
	    (float)(secondDivision - firstDivision);
        wavetable[i] = 1.0 - (x * x);
    }
    
    //  FILL BALANCE WITH ZEROS  
    for (i = secondDivision; i < tableSize; i++)
        wavetable[i] = 0.0;
    
    //  DO FFT ON WAVETABLE  
    realfft(wavetable, tableSize);
    
    //  IF LOG DISPLAY, SCALE THE HARMONICS  
    if (logScale) {
        for (i = 0; i < numberHarmonics; i++)
            wavetable[i] = ((log10(wavetable[i]) * 20.0) + LOG_SCALE_RANGE) /
            LOG_SCALE_RANGE;
    }
    
    //  LOCK FOCUS ON THE GLOTTAL PULSE NXIMAGE  
    [glottalPulseHarmonics lockFocus];
    
    //  CLEAR THE NXIMAGE  
    [glottalPulseHarmonics compositeToPoint:[self bounds].origin operation:NSCompositeClear];
    
    //  DRAW BAR GRAPH FOR EACH HARMONIC DISPLAYED  
    {
        float xStart = NSMinX(activeArea) + BAR_MARGIN + 1.0;
        float xIncrement = BAR_MARGIN + BAR_WIDTH;
        for (i = 0; i < numberHarmonics; i++) {
            PSrectfill(xStart + i * xIncrement,
                       NSMinY(activeArea),
                       BAR_WIDTH,
                       NSHeight(activeArea) * wavetable[i]);
        }
    }
    
    //  UNLOCK FOCUS ON THE GLOTTAL PULSE  NXIMAGE  
    [glottalPulseHarmonics unlockFocus];
    
    //  DISPLAY THE COMBINED IMAGES  
    [self display]; 
}



- (void)drawRect:(NSRect)rects;
{
    //  COMPOSITE APPROPRIATE BACKGROUND IMAGE  
    if (logScale)
        [logGrid compositeToPoint:(rects.origin) operation:NSCompositeSourceOver];
    else
        [linearGrid compositeToPoint:(rects.origin) operation:NSCompositeSourceOver];
    
    
    //  COMPOSITE THE FOREGROUND IMAGE OVER THE BACKGROUND  
    if (harmonics == HARMONICS_GP)
        [glottalPulseHarmonics compositeToPoint:(rects.origin) operation:NSCompositeSourceOver];
    else if (harmonics == HARMONICS_SINE)
        [sineHarmonics compositeToPoint:(rects.origin) operation:NSCompositeSourceOver];
}

#endif

@end
