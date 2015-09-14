//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Spectrograph.h"
#import "Spectrum.h"

@implementation Spectrograph
{
	id magnitudeForm;
	BOOL sgGridDisplay;
	int envelopeSize;
	float *spectrographEnvelopeData;
	float *spectrographScaledData;
	int drawFlag;
	float upperThreshold, lowerThreshold;
	int scaledSpectrographDataExists;
	int magnitudeScale;
}

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setAxesWithScale:SGX_SCALE_DIVS xScaleOrigin:SGX_SCALE_ORIGIN xScaleSteps:SGX_SCALE_STEPS
				xLabelInterval:SGX_LABEL_INTERVAL yScaleDivs:SGY_SCALE_DIVS yScaleOrigin:SGY_SCALE_ORIGIN
				   yScaleSteps:SGY_SCALE_STEPS yLabelInterval:SGY_LABEL_INTERVAL];
		drawFlag = 0;
	}

	return self;
}

- (void) awakeFromNib
{
	sgGridDisplay = SGGRID_DISPLAY_DEF;
	drawFlag = 0;
}

- (void)drawRect:(NSRect)rect
{
	
	NSString *gray00 = @"00-gray.tif", *gray01 = @"01-gray.tif", *gray02 = @"02-gray.tif", *gray03 = @"03-gray.tif", *gray04 = @"04-gray.tif",
	*gray05 = @"05-gray.tif", *gray06 = @"06-gray.tif", *gray07 = @"07-gray.tif", *gray08 = @"08-gray.tif", 
	*gray09 = @"09-gray.tif", *gray10 = @"10-gray.tif", *gray11 = @"11-gray.tif", *gray12 = @"12-gray.tif", *gray13 = @"13-gray.tif",
	*gray14 = @"14-gray.tif", *gray15 = @"15-gray.tif", *gray16 = @"16-gray.tif", *gray17 = @"17-gray.tif", 
	*gray18 = @"18-gray.tif", *gray19 = @"19-gray.tif", *gray20 = @"20-gray.tif", *gray21 = @"21-gray.tif", *gray22 = @"22-gray.tif",
	*gray23 = @"23-gray.tif", *gray24 = @"24-gray.tif", *gray25 = @"25-gray.tif", *gray26 = @"26-gray.tif", 
	*gray27 = @"27-gray.tif", *gray28 = @"28-gray.tif", *gray29 = @"29-gray.tif", *gray30 = @"30-gray.tif", *gray31 = @"31-gray.tif",
	*gray32 = @"32-gray.tif", *gray33 = @"33-gray.tif", *gray34 = @"34-gray.tif", *gray35 = @"35-gray.tif", 
	*gray36 = @"36-gray.tif", *gray37 = @"37-gray.tif", *gray38 = @"38-gray.tif", *gray39 = @"39-gray.tif", *gray40 = @"40-gray.tif",
	*gray41 = @"41-gray.tif", *gray42 = @"42-gray.tif", *gray43 = @"43-gray.tif", *gray44 = @"44-gray.tif", 
	*gray45 = @"45-gray.tif", *gray46 = @"46-gray.tif", *gray47 = @"47-gray.tif", *gray48 = @"48-gray.tif", *gray49 = @"49-gray.tif",
	*gray50 = @"50-gray.tif", *gray51 = @"51-gray.tif", *gray52 = @"52-gray.tif", *gray53 = @"53-gray.tif", 
	*gray54 = @"54-gray.tif", *gray55 = @"55-gray.tif", *gray56 = @"56-gray.tif", *gray57 = @"57-gray.tif", *gray58 = @"58-gray.tif",
	*gray59 = @"59-gray.tif", *gray60 = @"60-gray.tif", *gray61 = @"61-gray.tif", *gray62 = @"62-gray.tif", 
	*gray63 = @"63-gray.tif", *gray64 = @"64-gray.tif", *gray65 = @"65-gray.tif", *gray66 = @"66-gray.tif", *gray67 = @"67-gray.tif",
	*gray68 = @"68-gray.tif", *gray69 = @"69-gray.tif", *gray70 = @"70-gray.tif", *gray71 = @"71-gray.tif", 
	*gray72 = @"72-gray.tif", *gray73 = @"73-gray.tif", *gray74 = @"74-gray.tif", *gray75 = @"75-gray.tif", *gray76 = @"76-gray.tif",
	*gray77 = @"77-gray.tif", *gray78 = @"78-gray.tif", *gray79 = @"79-gray.tif", *gray80 = @"80-gray.tif", 
	*gray81 = @"81-gray.tif", *gray82 = @"82-gray.tif", *gray83 = @"83-gray.tif", *gray84 = @"84-gray.tif", *gray85 = @"85-gray.tif",
	*gray86 = @"86-gray.tif", *gray87 = @"87-gray.tif", *gray88 = @"88-gray.tif", *gray89 = @"89-gray.tif", 
	*gray90 = @"90-gray.tif", *gray91 = @"91-gray.tif", *gray92 = @"92-gray.tif", *gray93 = @"93-gray.tif", *gray94 = @"94-gray.tif",
	*gray95 = @"95-gray.tif", *gray96 = @"96-gray.tif", *gray97 = @"97-gray.tif", *gray98 = @"98-gray.tif",
	*gray99 = @"99-gray.tif"
	;
	NSArray *grayScale = [NSArray arrayWithObjects:
		gray00, gray01, gray02, gray03, gray04, gray05, gray06, gray07, gray08, gray09, gray10, gray11, gray12, gray13,
		gray14, gray15, gray16, gray17, gray18, gray19, gray20, gray21, gray22, gray23, gray24, gray25, gray26, 
		gray27, gray28, gray29, gray30, gray31, gray32, gray33, gray34, gray35, gray36, gray37, gray38, gray39, gray40,
		gray41, gray42, gray43, gray44, gray45, gray46, gray47, gray48, gray49, gray50, gray51, gray52, gray53, 
		gray54, gray55, gray56, gray57, gray58, gray59, gray60, gray61, gray62, gray63, gray64, gray65, gray66, gray67,
		gray68, gray69, gray70, gray71, gray72, gray73, gray74, gray75, gray76, gray77, gray78, gray79, gray80, 
		gray81, gray82, gray83, gray84, gray85, gray86, gray87, gray88, gray89, gray90, gray91, gray92, gray93, gray94,
		gray95, gray96, gray97, gray98, gray99, nil		
		];
	
	NSRect viewRect = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:viewRect];
	[self addLabels];
	
	
	//DRAW THE SPECTROGRAM USING 1-PIXEL TALL GRAY-SCALE IMAGES RANGING IN DENSITY FROM 0 1O 100
	
	NSLog(@"Spectrograph.m:77 drawFlag is %d", drawFlag);
	
	if (drawFlag == 1) { // Start of draw segment

		int i;
		float markLevel;
		markLevel = 1.0;
	
		NSRect imageRect;
		NSRect drawingRect;
		NSImage *sampleImage = [NSImage imageNamed:[grayScale objectAtIndex:0]];
		imageRect.origin = NSZeroPoint;

		drawingRect.size = [sampleImage size];
	
		drawingRect.origin.y = SGBOTTOM_MARGIN;
		drawingRect.origin.x = SGLEFT_MARGIN + SGGRAPH_MARGIN + 3;
	
		// Copy, scale & set mark levels for spectrograph creation for using gray scale & apply thresholds
		float maxData, minData;
		maxData = 0.0;
		minData = 400.0;
		//NSLog(@"Spectrograph.m:93 envelopeSize =%d", envelopeSize);
	
		for (i = 0; i < envelopeSize; i++) { // Trim envelope data
											 //NSLog(@"Spectrograph.m:95 envelope data %d is %f", i, spectrographEnvelopeData[i]);
			if (spectrographEnvelopeData[i] < 0) spectrographEnvelopeData[i] = 0;
			if (maxData < spectrographEnvelopeData[i]) maxData = spectrographEnvelopeData[i];
			if (minData > spectrographEnvelopeData[i]) minData = spectrographEnvelopeData[i];
		}
	
		[self readUpperThreshold]; // Get mark level thresholds
		[self readLowerThreshold];
		//NSLog(@"Spectrograph.m:106 upperThreshold is %f, lower is %f", upperThreshold, lowerThreshold);

		//NSLog(@"spectrograph.m:104 minData is %f, maxData is %f", minData, maxData);
		spectrographScaledData = (float *)calloc(envelopeSize, sizeof(float));
		//NSLog(@"spectrograph.m:120 minData is %f, maxData is %f", minData, maxData);
		float spectrographScale = 99 /(maxData - minData);
		if (magnitudeScale == 1) { // Logarithmic display
			minData = 99.0 + lowerThreshold / spectrographScale;
			maxData = 99.0 + upperThreshold / spectrographScale;		
		}
		else {
			minData = 99.0 + lowerThreshold * 99.0 / spectrographScale;
			maxData = 99.0 + upperThreshold * 99.0 / spectrographScale;		
		}
		//NSLog(@"spectrograph.m:124 minData is %f, maxData is %f", minData, maxData);
		spectrographScale = 99.0 / (maxData - minData);
		for (i = 0; i < envelopeSize; i++) {
			spectrographScaledData[i] = ((spectrographEnvelopeData[i] - minData) * spectrographScale);
			//NSLog(@"Spectrograph.m:128 envelope data %d is %f scaledData is %f", i, spectrographEnvelopeData[i], spectrographScaledData[i]);
			if (spectrographScaledData[i] < 0) spectrographScaledData[i] = 0;
			if (spectrographScaledData[i] > 99) spectrographScaledData[i] = 99;		
		}
	
	
	
		// Draw spectrograph
		i = 1;
		int j;
		int k = 0;

		int n = rint((2.0 * ((float)viewRect.size.height - (float)SGTOP_MARGIN - (float)SGBOTTOM_MARGIN)/(float)envelopeSize + 0.5)); // 
		NSLog(@"Spectrograph.m:116 drawing height is %f", (viewRect.size.height - SGTOP_MARGIN - SGBOTTOM_MARGIN));

		NSLog(@"Spectrograph.m:119 About to draw");

			
		for (k = 0; k < envelopeSize; k++) {

			NSImage *spectrographImage = [NSImage imageNamed:[grayScale objectAtIndex:rint(spectrographScaledData[k])]];
			//NSLog(@"spectrographScaleData[%d] is %d", k, spectrographScaleData[k]);
			imageRect.size = [spectrographImage size];

			for (j = 0; j < n; j++) {
				//NSLog(@"Spectrograph.m:130 About to draw spectrograph image %@", [spectrographImage description]);
				[spectrographImage drawInRect:drawingRect
								fromRect:imageRect
								operation:NSCompositeSourceOver
								fraction:markLevel];
								drawingRect.origin.y += 1;
				//NSLog(@". %d %d", k,i);
			
				}	// End for j		
			
			} // End for k

	}

	// THE GRID IS DRAWN LAST (IF DRAWN) IN ORDER TO OVERLAY THE SPECTROGRAM
	if (sgGridDisplay == 1)
	[self drawGrid];
	free(spectrographScaledData);
}


- (NSPoint)graphOrigin;
{
	NSPoint graphOrigin = [self bounds].origin;
	graphOrigin.x += SGLEFT_MARGIN;
	graphOrigin.y += SGBOTTOM_MARGIN;
    return graphOrigin;
}

- (void)drawGrid;
{
	// Draw in best fit grid markers
	
	NSRect bounds = [self bounds];
    NSPoint graphOrigin = [self graphOrigin];
	float sectionHeight = ((float)bounds.size.height - (float)graphOrigin.y - (float)SGTOP_MARGIN - (float)SGBOTTOM_MARGIN)/_yScaleDivs;
	float sectionWidth = ((float)bounds.size.width - (float)graphOrigin.x - (float)SGRIGHT_MARGIN)/_xScaleDivs;
	
	[[NSColor greenColor] set];
	NSPoint aPoint;
	
	//	First Y-axis grid lines
	
	[[NSColor greenColor] set];
	
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	for (NSUInteger index = 0; index <= _yScaleDivs; index++) {
		aPoint.x = graphOrigin.x + 12;
		aPoint.y = graphOrigin.y + index * sectionHeight * SG_YSCALE_FUDGE;
        [bezierPath moveToPoint:aPoint];
		
        aPoint.x = bounds.size.width - SGRIGHT_MARGIN + 15;
        [bezierPath lineToPoint:aPoint];
    }
    [bezierPath stroke];
    [bezierPath release];
	
	/* then X-axis grid lines */
	
	bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	for (NSUInteger index = 0; index <= SGX_SCALE_DIVS; index++) {
		aPoint.y = graphOrigin.y;
        aPoint.x = graphOrigin.x + index * sectionWidth + SGLABEL_MARGIN + 10;
        [bezierPath moveToPoint:aPoint];
		
        aPoint.y = ((float)bounds.size.height - (float)SGTOP_MARGIN);
        [bezierPath lineToPoint:aPoint];
    }
    [bezierPath stroke];
    [bezierPath release];
	
}


- (void)addLabels;
{
	NSRect bounds = [self bounds];
    NSPoint graphOrigin = [self graphOrigin];
	float sectionHeight = (bounds.size.height - graphOrigin.y - SGTOP_MARGIN - SGBOTTOM_MARGIN) * SG_YSCALE_FUDGE/_yScaleDivs;
	//float sectionWidth = (bounds.size.width - graphOrigin.x - SGRIGHT_MARGIN) / _xScaleDivs;
	
	
	// First Y-axis labels
	
	[[NSColor greenColor] set];
    [timesFont set];
	
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	
	float currentYPos = graphOrigin.y;
	
    for (NSUInteger index = 0; index <= _yScaleDivs; index += _yLabelInterval) {
        [bezierPath moveToPoint:NSMakePoint(graphOrigin.x, currentYPos)];
		currentYPos = graphOrigin.y + index * sectionHeight;
        NSString *label = [NSString stringWithFormat:@"%4.0f-", (int)index * _yScaleSteps + (int)_yScaleOrigin];
        NSSize labelSize = [label sizeWithAttributes:nil];
        [label drawAtPoint:NSMakePoint(SGLEFT_MARGIN - LABEL_MARGIN - labelSize.width, currentYPos - labelSize.height/2) withAttributes:nil];
    }
	
    [bezierPath stroke];
    [bezierPath release];
}


- (void)setSpectrographGrid:(BOOL)spectrographGridState;
{
	sgGridDisplay = (int)spectrographGridState;
	[self setNeedsDisplay:YES];
}

- (void)drawSpectrograph:(float *)data size:(int)size okFlag:(int)flag;
{
	//if (spectrographEnvelopeData) free(spectrographEnvelopeData); This statement was causing a crash
	if (flag == 0) return;
	NSLog(@"Spectrograph.m:331 size %d, flag %d", size, flag);
	envelopeSize = size;
	spectrographEnvelopeData = (float *)calloc(size, sizeof(float));

	for (NSUInteger index = 0; index < size; index++) {
        spectrographEnvelopeData[index] = 100.0 + data[index]/2;
    }
	
	drawFlag = flag;
	//scaledSpectrographDataExists = 0;
	[self setNeedsDisplay:YES];
    
}

- (void)readUpperThreshold;
{
	upperThreshold = [[magnitudeForm cellAtIndex:0] floatValue];
	//NSLog(@"Spectrograph.m:334 upperThreshold is %f", upperThreshold);
}

- (void)readLowerThreshold;
{
	lowerThreshold = [[magnitudeForm cellAtIndex:1] floatValue];
	//NSLog(@"Spectrograph.m:344 upperThreshold is %f", lowerThreshold);
}

- (void)setMagnitudeScale:(int)value;
{
	magnitudeScale = value;
}

@end
