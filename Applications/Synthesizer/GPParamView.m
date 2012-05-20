//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GPParamView.h"
#import "structs.h"

@implementation GPParamView : ChartView
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
	graphOrigin.x += GPLEFT_MARGIN;
	graphOrigin.y += GPBOTTOM_MARGIN;
    return graphOrigin;
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
	sectionHeight = (bounds.size.height - graphOrigin.y - GPTOP_MARGIN)/_yScaleDivs;
	sectionWidth = (bounds.size.width - graphOrigin.x - GPRIGHT_MARGIN)/_xScaleDivs;
	
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
		
        aPoint.x = bounds.size.width - GPRIGHT_MARGIN;
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
		
        aPoint.y =bounds.size.height - GPTOP_MARGIN;
        [bezierPath lineToPoint:aPoint];
		
    }
    [bezierPath stroke];
    [bezierPath release];
	
}

- (void)drawRect:(NSRect)rect  // This method overrides the ChartView method
{
	NSRect viewRect = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:viewRect];
	[self drawGrid];
	[self drawGlottalPulseAmplitude];
	
	
	// PROTOTYPE GLOTTAL PULSE NOT DRAWN FOR SINE WAVE
	if (*((int *) getWaveform()) == 1)
		return;	
	else {
		
		//NSLog(@"In GPPV: drawGlottalPulseAmplitude");
		
		NSLog(@"waveform in drawGlottalPulse is %d", waveform);
		
		NSBezierPath *bezierPath;
		//float myHeight;
		int index;
		NSPoint currentPoint;
		NSRect bounds;
		NSPoint graphOrigin, start;
		int i, j;
		bounds = [self bounds];
		//NSLog(@"myHeight is %f", myHeight);
		graphOrigin.x = (float) GPLEFT_MARGIN;
		graphOrigin.y = (float) GPBOTTOM_MARGIN;
		//NSLog(@" Graph origin is %f %f, height %f", graphOrigin.x, graphOrigin.y, bounds.size.height); // Took out myHeight
		//initializeWavetable(* (double *) getGlotVol());

		
		// CREATE NEW GLOTTAL PULSE ACCORDING TO Tp, TnMin, and TnMax AND UPDATE SYNTHESIZER WAVETABLE
		// Copy the current wavetable values
		tempFloatWavetable = (float *)calloc(TABLE_LENGTH, sizeof(float));
			
			/*  ALLOCATE MEMORY FOR WAVETABLE  */
			//wavetable = (double *)calloc(TABLE_LENGTH, sizeof(double));
		NSLog(@"Tp is %f, TnMin is %f, and TnMax is %f",*((double *) getTp()), *((double *) getTnMin()), *((double *) getTnMax()));
			/*  CALCULATE WAVE TABLE PARAMETERS  */
			tableDiv1 = rint(TABLE_LENGTH * (*((double *) getTp()) / 100.0));
			tableDiv2 = rint(TABLE_LENGTH * ((*((double *) getTp()) + *((double *) getTnMax())) / 100.0));
			tnLength = tableDiv2 - tableDiv1;
			tnDelta = rint(TABLE_LENGTH * ((*((double *) getTnMax()) - *((double *) getTnMin())) / 100.0));
			basicIncrement = (double)TABLE_LENGTH / (double)sampleRate;
			currentPosition = 0;
			
			//  INITIALIZE THE TEMP WAVETABLE 
			//if (waveform == PULSE) {
				//  CALCULATE RISE PORTION OF WAVE TABLE
				for (i = 0; i < tableDiv1; i++) {
					double x = (double)i / (double)tableDiv1;
					double x2 = x * x;
					double x3 = x2 * x;
					tempFloatWavetable[i] = (3.0 * x2) - (2.0 * x3);
				}
				
				/*  CALCULATE FALL PORTION OF WAVE TABLE  */
				for (i = tableDiv1, j = 0; i < tableDiv2; i++, j++) {
					double x = (double)j / tnLength;
					tempFloatWavetable[i] = 1.0 - (x * x);
				}
				
				/*  SET CLOSED PORTION OF WAVE TABLE  */
				for (i = tableDiv2; i < TABLE_LENGTH; i++)
					tempFloatWavetable[i] = 0.0;
			


		[[NSColor lightGrayColor] set];
		bezierPath = [[NSBezierPath alloc] init];
		[bezierPath setLineWidth:1];
		//NSLog(@"Waveform value is %d %d %f", waveform, *(double *) getWaveform(), myHeight);
		start.x = graphOrigin.x;
		start.y = graphOrigin.y + ((bounds.size.height - (float) GPTOP_MARGIN - (float) GPBOTTOM_MARGIN) * waveform/2)
		+ (float) (GPX_SCALE_FACTOR/(waveform + 1) * tempFloatWavetable[0]);
		//NSLog(@"Waveform value after set start is %d %d, start (x,y) %f %f, height %f", waveform, *(double *) getWaveform(), start.x, start.y, myHeight);
		[bezierPath moveToPoint:start];
		//NSLog(@"The wave table value at index 100 is %f", tempFloatWavetable[100]);
		for (index = 1; index < 512; index++) {
		
			currentPoint.x = graphOrigin.x + ((float) index) * (bounds.size.width - graphOrigin.x - (float) GPLEFT_MARGIN - (float) GPRIGHT_MARGIN )/512;
			currentPoint.y = graphOrigin.y + ((bounds.size.height - (float) GPTOP_MARGIN - (float) GPBOTTOM_MARGIN) * waveform/2)
				+ (float) (GPX_SCALE_FACTOR/(waveform + 1) * tempFloatWavetable[index]);
		[bezierPath lineToPoint:currentPoint];
		
		}

		[bezierPath stroke];
		[bezierPath release];

		for (i = 0; i < 512; i++)  {  // move current data to transform buffer
		tempFloatWavetable[i] = (float) (*((double *) getWavetable(i)));
		}

		
		//NSLog(@" Graph origin is %f %f, height %f %f", graphOrigin.x, graphOrigin.y, bounds.size.height, myHeight);
		[[NSColor blackColor] set];
		bezierPath = [[NSBezierPath alloc] init];
		[bezierPath setLineWidth:1];
		//NSLog(@"Waveform value is %d %d %f", waveform, *(double *) getWaveform(), myHeight);
		start.x = graphOrigin.x;
		start.y = graphOrigin.y + ((bounds.size.height - (float) GPTOP_MARGIN - (float) GPBOTTOM_MARGIN) * waveform/2)
			+ (float) (GPX_SCALE_FACTOR/(waveform + 1) * tempFloatWavetable[0]);
		//NSLog(@"Waveform value after set start is %d %d, start (x,y) %f %f, height %f", waveform, *(double *) getWaveform(), start.x, start.y, myHeight);
		[bezierPath moveToPoint:start];
		//NSLog(@"The wave table value at index 100 is %f", tempFloatWavetable[100]);
		for (index = 1; index < 512; index++) {
			
			currentPoint.x = graphOrigin.x + ((float) index) * (bounds.size.width - graphOrigin.x - (float) GPLEFT_MARGIN - (float) GPRIGHT_MARGIN )/512;
			currentPoint.y = graphOrigin.y + ((bounds.size.height - (float) GPTOP_MARGIN - (float) GPBOTTOM_MARGIN) * waveform/2)
				+ (float) (GPX_SCALE_FACTOR/(waveform + 1) * tempFloatWavetable[index]);
			[bezierPath lineToPoint:currentPoint];
			
		}
		
		[bezierPath stroke];
		[bezierPath release];
		free(tempFloatWavetable);
		
		bezierPath = [[NSBezierPath alloc] init];
		
		[[NSColor lightGrayColor] set];
		
		[bezierPath setLineWidth:1];
		
		// Set up Tp grid line
		
		currentPoint.x = graphOrigin.x + (float) (*((double *) getTp()))*(bounds.size.width - graphOrigin.x - GPLEFT_MARGIN - GPRIGHT_MARGIN)/100;
		currentPoint.y = graphOrigin.y + bounds.size.height - (float) GPTOP_MARGIN - (float) GPBOTTOM_MARGIN;
        [bezierPath moveToPoint:currentPoint];
		
        currentPoint.y = graphOrigin.y;
        [bezierPath lineToPoint:currentPoint];
		NSLog(@"Done Tp grid line");
		
		// Set up TnMin line
		
		currentPoint.x = graphOrigin.x + ((float) (*((double *) getTp())) + (float) (*((double *) getTnMin())))*(bounds.size.width
																												 - graphOrigin.x - GPLEFT_MARGIN - GPRIGHT_MARGIN)/100;
		currentPoint.y = graphOrigin.y + bounds.size.height - (float) GPTOP_MARGIN - (float) GPBOTTOM_MARGIN;
        [bezierPath moveToPoint:currentPoint];
		
        currentPoint.y = graphOrigin.y;
        [bezierPath lineToPoint:currentPoint];
		
		// Set up TnMax line
		
		double tn =  *((double *) getTnMax()) - *((double *) getTnMin());
		
		currentPoint.x = graphOrigin.x + ((float) (*((double *) getTp())) + (float) (*((double *) getTnMin()))
										  + (float) (tn))*(bounds.size.width - graphOrigin.x - GPLEFT_MARGIN - GPRIGHT_MARGIN)/100;
		currentPoint.y = graphOrigin.y + bounds.size.height - (float) GPTOP_MARGIN - (float) GPBOTTOM_MARGIN;
        [bezierPath moveToPoint:currentPoint];
		
        currentPoint.y = graphOrigin.y;
        [bezierPath lineToPoint:currentPoint];
		
		
		[bezierPath stroke];
		[bezierPath release];
		//NSLog(@"Leaving GPPV: drawGlottalPulseAmplitude");
		
	}
	
	
}


- (void)drawGlottalPulseAmplitude


{
	
	[self setNeedsDisplay:YES];	
	
}




@end
