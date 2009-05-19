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
//  Spectrum.m
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////

#import "Spectrum.h"

static const float testWave[1024] = {
	0.0,0.200278,0.355332,0.458712,0.540701,0.629713,0.721118,0.78768,0.817848,0.836308,0.88137,0.963177,
	1.049632,1.097102,1.093599,1.068286,1.058425,1.071522,1.084409,1.078341,1.068092,1.089952,1.160582,
	1.252807,1.316845,1.325547,1.295627,1.26345,1.243892,1.218336,1.163765,1.087857,1.028074,1.013795,
	1.033272,1.043131,1.011551,0.94897,0.894009,0.871678,0.870763,0.864377,0.84825,0.851162,0.903769,1,
	1.095013,1.143966,1.140793,1.116159,1.098853,1.084617,1.046582,0.973553,0.890562,0.836255,0.821096,
	0.813296,0.769514,0.678038,0.568286,0.47776,0.414183,0.354584,0.280395,0.206541,0.169445,0.185873,
	0.228734,0.248309,0.217483,0.152982,0.091161,0.046864,0.001413422,-0.068286,-0.154656,-0.22036,-0.236159,
	-0.213964,-0.197329,-0.218274,-0.266573,-0.303836,-0.305294,-0.282417,-0.262355,-0.249655,-0.215819,
	-0.130479,-0.0,0.130479,0.215819,0.249655,0.262355,0.282417,0.305294,0.303836,0.266573,0.218274,0.197329,
	0.213964,0.236159,0.22036,0.154656,0.068286,-0.001413422,-0.046864,-0.091161,-0.152982,-0.217483,
	-0.248309,-0.228734,-0.185873,-0.169445,-0.206541,-0.280395,-0.354584,-0.414183,-0.47776,-0.568286,
	-0.678038,-0.769514,-0.813296,-0.821096,-0.836255,-0.890562,-0.973553,-1.046582,-1.084617,-1.098853,
	-1.116159,-1.140793,-1.143966,-1.095013,-1,-0.903769,-0.851162,-0.84825,-0.864377,-0.870763,-0.871678,
	-0.894009,-0.94897,-1.011551,-1.043131,-1.033272,-1.013795,-1.028074,-1.087857,-1.163765,-1.218336,
	-1.243892,-1.26345,-1.295627,-1.325547,-1.316845,-1.252807,-1.160582,-1.089952,-1.068092,-1.078341,
	-1.084409,-1.071522,-1.058425,-1.068286,-1.093599,-1.097102,-1.049632,-0.963177,-0.88137,-0.836308,
	-0.817848,-0.78768,-0.721118,-0.629713,-0.540701,-0.458712,-0.355332,-0.200278,0.0,0.200278,0.355332,
	0.458712,0.540701,0.629713,0.721118,0.78768,0.817848,0.836308,0.88137,0.963177,1.049632,1.097102,
	1.093599,1.068286,1.058425,1.071522,1.084409,1.078341,1.068092,1.089952,1.160582,1.252807,1.316845,
	1.325547,1.295627,1.26345,1.243892,1.218336,1.163765,1.087857,1.028074,1.013795,1.033272,1.043131,
	1.011551,0.94897,0.894009,0.871678,0.870763,0.864377,0.84825,0.851162,0.903769,1,1.095013,1.143966,
	1.140793,1.116159,1.098853,1.084617,1.046582,0.973553,0.890562,0.836255,0.821096,0.813296,0.769514,
	0.678038,0.568286,0.47776,0.414183,0.354584,0.280395,0.206541,0.169445,0.185873,0.228734,0.248309,
	0.217483,0.152982,0.091161,0.046864,0.001413422,-0.068286,-0.154656,-0.22036,-0.236159,-0.213964,
	-0.197329,-0.218274,-0.266573,-0.303836,-0.305294,-0.282417,-0.262355,-0.249655,-0.215819,-0.130479,
	0.0,0.130479,0.215819,0.249655,0.262355,0.282417,0.305294,0.303836,0.266573,0.218274,0.197329,0.213964,
	0.236159,0.22036,0.154656,0.068286,-0.001413422,-0.046864,-0.091161,-0.152982,-0.217483,-0.248309,
	-0.228734,-0.185873,-0.169445,-0.206541,-0.280395,-0.354584,-0.414183,-0.47776,-0.568286,-0.678038,
	-0.769514,-0.813296,-0.821096,-0.836255,-0.890562,-0.973553,-1.046582,-1.084617,-1.098853,-1.116159,
	-1.140793,-1.143966,-1.095013,-1,-0.903769,-0.851162,-0.84825,-0.864377,-0.870763,-0.871678,-0.894009,
	-0.94897,-1.011551,-1.043131,-1.033272,-1.013795,-1.028074,-1.087857,-1.163765,-1.218336,-1.243892,
	-1.26345,-1.295627,-1.325547,-1.316845,-1.252807,-1.160582,-1.089952,-1.068092,-1.078341,-1.084409,
	-1.071522,-1.058425,-1.068286,-1.093599,-1.097102,-1.049632,-0.963177,-0.88137,-0.836308,-0.817848,
	-0.78768,-0.721118,-0.629713,-0.540701,-0.458712,-0.355332,-0.200278,0.0,0.200278,0.355332,0.458712,
	0.540701,0.629713,0.721118,0.78768,0.817848,0.836308,0.88137,0.963177,1.049632,1.097102,1.093599,
	1.068286,1.058425,1.071522,1.084409,1.078341,1.068092,1.089952,1.160582,1.252807,1.316845,1.325547,
	1.295627,1.26345,1.243892,1.218336,1.163765,1.087857,1.028074,1.013795,1.033272,1.043131,1.011551,
	0.94897,0.894009,0.871678,0.870763,0.864377,0.84825,0.851162,0.903769,1,1.095013,1.143966,1.140793,
	1.116159,1.098853,1.084617,1.046582,0.973553,0.890562,0.836255,0.821096,0.813296,0.769514,0.678038,
	0.568286,0.47776,0.414183,0.354584,0.280395,0.206541,0.169445,0.185873,0.228734,0.248309,0.217483,
	0.152982,0.091161,0.046864,0.001413422,-0.068286,-0.154656,-0.22036,-0.236159,-0.213964,-0.197329,
	-0.218274,-0.266573,-0.303836,-0.305294,-0.282417,-0.262355,-0.249655,-0.215819,-0.130479,0.0,0.130479,
	0.215819,0.249655,0.262355,0.282417,0.305294,0.303836,0.266573,0.218274,0.197329,0.213964,0.236159,
	0.22036,0.154656,0.068286,-0.001413422,-0.046864,-0.091161,-0.152982,-0.217483,-0.248309,-0.228734,
	-0.185873,-0.169445,-0.206541,-0.280395,-0.354584,-0.414183,-0.47776,-0.568286,-0.678038,-0.769514,
	-0.813296,-0.821096,-0.836255,-0.890562,-0.973553,-1.046582,-1.084617,-1.098853,-1.116159,-1.140793,
	-1.143966,-1.095013,-1,-0.903769,-0.851162,-0.84825,-0.864377,-0.870763,-0.871678,-0.894009,-0.94897,
	-1.011551,-1.043131,-1.033272,-1.013795,-1.028074,-1.087857,-1.163765,-1.218336,-1.243892,-1.26345,
	-1.295627,-1.325547,-1.316845,-1.252807,-1.160582,-1.089952,-1.068092,-1.078341,-1.084409,-1.071522,
	-1.058425,-1.068286,-1.093599,-1.097102,-1.049632,-0.963177,-0.88137,-0.836308,-0.817848,-0.78768,
	-0.721118,-0.629713,-0.540701,-0.458712,-0.355332,-0.200278,0.0,0.200278,0.355332,0.458712,0.540701,
	0.629713,0.721118,0.78768,0.817848,0.836308,0.88137,0.963177,1.049632,1.097102,1.093599,1.068286,
	1.058425,1.071522,1.084409,1.078341,1.068092,1.089952,1.160582,1.252807,1.316845,1.325547,1.295627,
	1.26345,1.243892,1.218336,1.163765,1.087857,1.028074,1.013795,1.033272,1.043131,1.011551,0.94897,
	0.894009,0.871678,0.870763,0.864377,0.84825,0.851162,0.903769,1,1.095013,1.143966,1.140793,1.116159,
	1.098853,1.084617,1.046582,0.973553,0.890562,0.836255,0.821096,0.813296,0.769514,0.678038,0.568286,
	0.47776,0.414183,0.354584,0.280395,0.206541,0.169445,0.185873,0.228734,0.248309,0.217483,0.152982,
	0.091161,0.046864,0.001413422,-0.068286,-0.154656,-0.22036,-0.236159,-0.213964,-0.197329,-0.218274,
	-0.266573,-0.303836,-0.305294,-0.282417,-0.262355,-0.249655,-0.215819,-0.130479,0.0,0.130479,0.215819,
	0.249655,0.262355,0.282417,0.305294,0.303836,0.266573,0.218274,0.197329,0.213964,0.236159,0.22036,
	0.154656,0.068286,-0.001413422,-0.046864,-0.091161,-0.152982,-0.217483,-0.248309,-0.228734,-0.185873,
	-0.169445,-0.206541,-0.280395,-0.354584,-0.414183,-0.47776,-0.568286,-0.678038,-0.769514,-0.813296,
	-0.821096,-0.836255,-0.890562,-0.973553,-1.046582,-1.084617,-1.098853,-1.116159,-1.140793,-1.143966,
	-1.095013,-1,-0.903769,-0.851162,-0.84825,-0.864377,-0.870763,-0.871678,-0.894009,-0.94897,-1.011551,
	-1.043131,-1.033272,-1.013795,-1.028074,-1.087857,-1.163765,-1.218336,-1.243892,-1.26345,-1.295627,
	-1.325547,-1.316845,-1.252807,-1.160582,-1.089952,-1.068092,-1.078341,-1.084409,-1.071522,-1.058425,
	-1.068286,-1.093599,-1.097102,-1.049632,-0.963177,-0.88137,-0.836308,-0.817848,-0.78768,-0.721118,
	-0.629713,-0.540701,-0.458712,-0.355332,-0.200278,0.0,0.200278,0.355332,0.458712,0.540701,0.629713,
	0.721118,0.78768,0.817848,0.836308,0.88137,0.963177,1.049632,1.097102,1.093599,1.068286,1.058425,
	1.071522,1.084409,1.078341,1.068092,1.068092,1.089952,1.160582,1.252807,1.316845,1.325547,1.295627,
	1.26345,1.243892,1.218336,1.163765,1.087857,1.028074,1.013795,1.033272,1.043131,1.011551,0.94897,
	0.894009,0.871678,0.870763,0.864377,0.84825,0.851162,0.903769,1,1.095013,1.143966,1.140793,1.116159,
	1.098853,1.084617,1.046582,0.973553,0.890562,0.836255,0.821096,0.813296,0.769514,0.678038,0.568286,
	0.47776,0.414183,0.354584,0.280395,0.206541,0.169445,0.185873,0.228734,0.248309,0.217483,0.152982,
	0.091161,0.046864,0.001413422,-0.068286,-0.154656,-0.22036,-0.236159,-0.213964,-0.197329,-0.218274,
	-0.266573,-0.303836,-0.305294,-0.282417,-0.262355,-0.249655,-0.215819,-0.130479,0.0,0.130479,0.215819,
	0.249655,0.262355,0.282417,0.305294,0.303836,0.266573,0.218274,0.197329,0.213964,0.236159,0.22036,
	0.154656,0.068286,-0.001413422,-0.046864,-0.091161,-0.152982,-0.217483,-0.248309,-0.228734,-0.185873,
	-0.169445,-0.206541,-0.280395,-0.354584,-0.414183,-0.47776,-0.568286,-0.678038,-0.769514,-0.813296,
	-0.821096,-0.836255,-0.890562,-0.973553,-1.046582,-1.084617,-1.098853,-1.116159,-1.140793,-1.143966,
	-1.095013,-1,-0.903769,-0.851162,-0.84825,-0.864377,-0.870763,-0.871678,-0.894009,-0.94897,-1.011551,
	-1.043131,-1.033272,-1.013795,-1.028074,-1.087857,-1.163765,-1.218336,-1.243892,-1.26345,-1.295627,
	-1.325547,-1.316845,-1.252807,-1.160582,-1.089952,-1.068092,-1.078341,-1.084409,-1.071522,-1.058425,
	-1.068286,-1.093599,-1.097102,-1.049632,-0.963177,-0.88137,-0.836308,-0.817848,-0.78768,-0.721118,
	-0.629713,-0.540701,-0.458712,-0.355332,-0.200278,0.0,0.200278,0.355332,0.458712,0.540701,0.629713,
	0.721118,0.78768,0.817848,0.836308,0.88137,0.963177,1.049632,1.097102,1.093599,1.068286,1.058425,
	1.071522,1.084409,1.078341,1.068092,1.089952,1.160582,1.252807,1.316845,1.325547,1.295627,1.26345,
	1.243892,1.218336,1.163765,1.087857,1.028074,1.013795,1.033272,1.043131,1.011551,0.94897,0.894009,
	0.871678,0.870763,0.864377,0.84825,0.851162,0.903769,1,1.095013,1.143966,1.140793,1.116159,1.098853,
	1.084617,1.046582,0.973553,0.890562,0.836255,0.821096,0.813296,0.769514,0.678038,0.568286,0.47776,
	0.414183,0.354584,0.280395,0.206541,0.169445,0.185873,0.228734,0.248309,0.217483,0.152982,0.091161,
	0.046864,0.001413422,-0.068286,-0.154656,-0.22036,-0.236159,-0.213964,-0.197329,-0.218274,-0.266573,
	-0.303836,-0.305294,-0.282417,-0.262355,-0.249655,-0.215819,-0.130479,0.0,0.130479,0.215819,0.249655,
	0.262355,0.282417,0.305294,0.303836,0.266573,0.218274,0.197329,0.213964,0.236159,0.22036,0.154656,
	0.068286,-0.001413422,-0.046864,-0.091161,-0.152982,-0.217483,-0.248309,-0.228734,-0.185873,-0.169445,
	-0.206541,-0.280395,-0.354584,-0.414183,-0.47776,-0.568286,-0.678038,-0.769514
	};



@implementation Spectrum

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
/*		
		[self setAxesWithScale:SMX_SCALE_DIVS xScaleOrigin:SMX_SCALE_ORIGIN xScaleSteps:SMX_SCALE_STEPS
				xLabelInterval:SMX_LABEL_INTERVAL yScaleDivs:SMY_SCALE_DIVS yScaleOrigin:SMY_SCALE_ORIGIN
				   yScaleSteps:SMY_SCALE_STEPS yLabelInterval:SMY_LABEL_INTERVAL];
/*
		[self setAxesWithScale:SMX_SCALE_DIVS/2 xScaleOrigin:SMX_SCALE_ORIGIN xScaleSteps:SMX_SCALE_STEPS/2
				xLabelInterval:SMX_LABEL_INTERVAL/2 yScaleDivs:SMY_SCALE_DIVS yScaleOrigin:SMY_SCALE_ORIGIN
				   yScaleSteps:SMY_SCALE_STEPS yLabelInterval:SMY_LABEL_INTERVAL];
*/		
		 gridDisplay = YES;
		analysisDataExists = FALSE;
		normalize = TRUE;
		
		
	}
	return self;
}

- (void) awakeFromNib
{
	NSLog(@"Spectrum.m:33 waking from nib");
	[envelopeField setFloatingPointFormat:(BOOL)NO left:(unsigned)1 right:(unsigned)3];
	spectralEnvelopeOnOff = YES;
	spectralEnvelopeSpan = SPAN_DEF;
	spectrumGraphOnOff = YES;
	NSLog(@"Spectrum.m:37 about to set envelope controls, on/off is %d, span is %f", spectralEnvelopeOnOff, spectralEnvelopeSpan);
	[envelopeSwitch setState:spectralEnvelopeOnOff];	// 0 IS OFF, 1 IS ON
	[envelopeField setFloatValue:spectralEnvelopeSpan]; // RANGE IS 0.0 TO 0.2 OF ANALYSIS WINDOW/BIN SIZE
	[graphSwitch setState:spectrumGraphOnOff];
	
	samplingWindowSize = 256;
	magnitudeScale = 1; // DEFAULT 1 GIVES A LOG SCALE, 0 WOULD BE LINEAR
	analysisDataExists = 0;

}

- (void)drawRect:(NSRect)rect // This method over-rides ChartView
{

	NSRect viewRect = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:viewRect];
	if (!magnitudeScale) {
		[self setAxesWithScale:SMX_SCALE_DIVS xScaleOrigin:SMX_SCALE_ORIGIN xScaleSteps:SMX_SCALE_STEPS
				xLabelInterval:SMX_LABEL_INTERVAL yScaleDivs:SMY_SCALE_DIVS_LIN yScaleOrigin:SMY_SCALE_ORIGIN_LIN
					yScaleSteps:(SMY_SCALE_STEPS_LIN) yLabelInterval:SMY_LABEL_INTERVAL];
			
	} // end magnitude scale is 0
	else {
		[self setAxesWithScale:SMX_SCALE_DIVS xScaleOrigin:SMX_SCALE_ORIGIN xScaleSteps:SMX_SCALE_STEPS
			xLabelInterval:SMX_LABEL_INTERVAL yScaleDivs:SMY_SCALE_DIVS_LOG yScaleOrigin:SMY_SCALE_ORIGIN_LOG
				yScaleSteps:SMY_SCALE_STEPS_LOG yLabelInterval:SMY_LABEL_INTERVAL];
		
	} // end magnitude scale is 1
	
	if (!gridDisplay);
	else [self drawGrid]; // SKIP DRAWING THE GRID IF SWITCH IS OFF
	[self addLabels];
		
	
	// DRAW THE GRAPH
	
	NSBezierPath *bezierPath;
    int index;
    NSPoint currentPoint;
    NSRect bounds;
    NSPoint graphOrigin, start;
	
	int i;
    bounds = [self bounds];
    graphOrigin.x = (float) SMLEFT_MARGIN;
	graphOrigin.y = (float) SMBOTTOM_MARGIN;
	//NSLog(@" Graph origin waveform is %f %f", graphOrigin.x, graphOrigin.y);
	NSLog(@"Spectrum.m:147 Entering drawSpectrum");
	
	// REDO ANALYSIS, OR COPY THE CURRENT SOUND OUTPUT CIRCULAR BUFFER VALUES, OR TEST DATA AND PROCESS
	// ACCORDING TO ANALYSIS SWITCH SETTINGS

	if (normalTestState == 0 && analysisDataExists == TRUE) {
		NSLog(@"Spectrum.m:156, Normal analysis (flag is %d) and analysisDataExists TRUE (flag is %d)", normalTestState, analysisDataExists);		
	}
	
	else { // Either normalTestState is 1 or analysisDataExists is FALSE

		if (normalTestState == 0) {
			NSLog(@"Spectrum.m:159, analysisDataExists FALSE (flag is %d)", analysisDataExists);
			analysisData = (float *)calloc(CIRC_BUFF_SIZE, sizeof(float)); // was TABLE_LENGTH
			int runButtonState = [runButton state];
			if (runButtonState == 1) {
				for (i = 0; i < CIRC_BUFF_SIZE; i++) {
					// move data to transform buffer
					analysisData[i] = (float)getCircBuff(); 
					//NSLog(@"Spectrum.m:170 analysisData %d is %f circBuff %d is %f", i, analysisData[i], i, circBuff[i]);				
					analysisDataExists = TRUE;
				} // End of analysisData transfer loop
			}
			else for (i = 0; i < CIRC_BUFF_SIZE; i++) analysisData[i] = 0.03;
		} // End normalTestState is 0
		
		else { // normalTestState is 1
			analysisData = (float *)calloc(TEST_DATA_SIZE, sizeof(float)); // was TABLE_LENGTH
			NSLog(@"Spectrum.m:192 entering test data loop");
			for (i = 0; i < TEST_DATA_SIZE; i++)
				{  // move data to transform buffer
				analysisData[i] = testWave[i]/100.0;
				//NSLog(@"Spectrum.m:164 analysisData %d is %f testWave %d is %f", i, analysisData[i], i, testWave[i]);
				analysisDataExists = TRUE; // #### was TRUE
				
				} // End of testWave data tranfer loop
			
			} //End normalTestState i 1	

	} // End of actions when normalTestState is 1 &/OR analysisDataExists is FALSE
	
	[analysis updateWindow]; // MAKE SURE OUR WINDOW CONTROL IS UP-TO-DATE

	
	
	// MAKE A COPY OF THE ANALYSIS DATA
	tempData = (float *)calloc(samplingWindowSize, sizeof(float));
	spectrum = (float *)calloc(samplingWindowSize/2, sizeof(float));
	for (i = 0; i < samplingWindowSize/2; i++) spectrum[i] = 0; // Zero out spectral magnitude accumulator

	int kk, frames;
	
	// Calculate number of frames to be processed in spectral average

	if (normalTestState == 0) frames = CIRC_BUFF_SIZE/samplingWindowSize;
	else frames = TEST_DATA_SIZE/samplingWindowSize;

	for (kk = 0; kk < frames; kk++) { // Loop to analyse successive frames and accumlate spctral magnitudes
		
		for (i = 0; i < samplingWindowSize; i++) { // Transfer next frames worth to tempData buffer
			tempData[i] = analysisData[i + kk * samplingWindowSize];
			//NSLog(@"Spectrum.m:90 tempData %d is %f analysisData %d is %f", i, tempData[i], i, analysisData[i]);
			
		} // End of frame transfer
		

		// Determine the largest signal magnitude in the frame (maybe should do whole buffer to start)
		
		float magnitude = 0.0;
		float largestMagnitude = 0.0;
		float leastMagnitude = 0.0;
				
		for (i = 0; i < samplingWindowSize; i++) {
			magnitude = fabs(tempData[i]);
			if (largestMagnitude < magnitude) largestMagnitude = magnitude;
			if (leastMagnitude < magnitude) leastMagnitude = magnitude;
			//NSLog(@"Spectrum.m:101 tempData[%d] is %f", i, tempData[i]);
			
		} // End of largest magnitude determination


		
		//  Calculate the amplitude scale (this doesn't look right)
		scale = 1000.0 / largestMagnitude - leastMagnitude;
		//if (normalize && (largestMagnitude > 0.0)) scale = 1000.0 / largestMagnitude - leastMagnitude; //bounds.size.height - SMTOP_MARGIN - SMBOTTOM_MARGIN / (largestMagnitude - leastMagnitude);
		//else scale = 10000.0;

		// NSLog(@"Spectrum.m:115 samplingWindowSize is %f\n", i, samplingWindowSize);

		samplingWindowSize = [analysisWindow windowSize];
		//samplingWindowShape = [analysisWindow windowBuffer];
		//NSLog(@"Spectrum.m:119 samplingWindowSize is %d, samplingWindowShape[samplingWindowSize-1] is",
		//	  samplingWindowSize, samplingWindowShape[samplingWindowSize-1]);

	
		// Modify sound data in tempData to apply scaling & samplingWindowShape
		for (i = 0; i < samplingWindowSize; i++) {
			tempData[i] = tempData[i] * scale * samplingWindowShape[i];
			//NSLog(@"Spectrum.m:101 samplingWindowShape[%d] is %f\n", i, samplingWindowShape[i]);
		}
	
		realfft(tempData, samplingWindowSize); // Do the FFT on current frame
	
		for (i = 0; i < samplingWindowSize/2; i++) spectrum[i] += tempData[i]; // Accumulate successive spectral magnitudes
	
	
	} // End of kk loop for accumulating spectral magnitudes
	
	for (i = 0; i < samplingWindowSize/2; i++) {
		
		spectrum[i] = spectrum[i]/frames; // Average spectrum values
		//NSLog(@"Spectrum.m:274 spectrum[%d] is %f", i, spectrum[i]);		
	}
	
		
	
	// Convert spectral magnitudes to a logarithmic scale if magnitudeScale = 1
	if (magnitudeScale == 1) {
		//NSLog(@"Spectrum.m:279 magnitudeScale is %d", magnitudeScale);
		float dbRef = spectrum[0];
		for (i = 0; i < samplingWindowSize / 2; i++) {
			spectrum[i] = 20 * log10f(spectrum[i] /dbRef);
			//NSLog(@"Spectrum.m:281 spectrum[%d] is %f", i, spectrum[i]);
		}
	}
	
	float spectrumMax =-400;
	float spectrumMin = 400;
	for (i = 0; i < samplingWindowSize/2; i++) {
		//NSLog(@"Spectrum.m:236 spectrum data %d is %f", i, spectrum[i]);
		if (spectrumMax < spectrum[i]) spectrumMax = spectrum[i];
		if (spectrumMin > spectrum[i]) spectrumMin = spectrum[i];
	}
	
	
	// Produce smoothed spectral envelope based on envelope span size, averaging for spectralEnevlopeSpan either side of the
	// frequency value.  spectralEnvelopeSpan is set in the span fraction window as a fraction of the total spectral frequency values
	int j;
	float envelopeDataMax = 0;
	float envelopeDataMin = 1;
	startEnvelope = (int)rint((float)spectralEnvelopeSpan * ((float)samplingWindowSize / 2.0));
	endEnvelope = (int)rint(((float) samplingWindowSize / 2) - (float)startEnvelope);
	//NSLog(@"Spectrum.m:145 startEnvelope is %d, endEnvelope is %d", startEnvelope, endEnvelope);
	if (envelopeData) free(envelopeData); // Free any previous values
	envelopeData = (float *)calloc(samplingWindowSize / 2, sizeof(float));
	for (i = 0; i < samplingWindowSize/2; i++) envelopeData[i] = 0;
	for (i = startEnvelope; i < endEnvelope; i++) { // Accumulate the values spanned
		for (j = (i - startEnvelope); j <= i + startEnvelope; j++) {

			envelopeData[i] += spectrum[j] * (1 - abs(i - j)/(startEnvelope + 1));
		}
		envelopeData[i] = envelopeData[i] / (2 * startEnvelope + 1); // Average the span values collected
	
	} // End of computing the smoothed envelope magnitudes
	
	
	for (i = startEnvelope; i < (samplingWindowSize/2 - startEnvelope); i++) {  // Identify the maximum and minimum values of the smoothed spectral values
		//NSLog(@"Spectrum.m:236 FFT data %d is %f", i, tempData[i]);
		if (envelopeDataMax < envelopeData[i]) envelopeDataMax = envelopeData[i];
		if (envelopeDataMin > envelopeData[i]) envelopeDataMin = envelopeData[i];
	}


	// Scale the envelopeData
	float envelopeScale = (bounds.size.height - SMBOTTOM_MARGIN - TOP_MARGIN) / (envelopeDataMax - envelopeDataMin);
	for (i = 0; i < samplingWindowSize/2; i++) envelopeData[i] = (envelopeData[i] - envelopeDataMin) * envelopeScale;


	// Draw spectrograph unless there's no data
	
	int flag;
	if (analysisDataExists == TRUE) // ####
		flag = 1;
	else
		flag = 0;
	
	// display envelopeData on run log
	//for (i = 0; i < samplingWindowSize; i++) NSLog(@"Spectrum.m:315 envelopeData[%d] is %f", i, envelopeData[i]);
	
	
	[spectrograph drawSpectrograph:(float *)spectrum size:(int)samplingWindowSize/2 okFlag:(int)flag];
	//NSLog(@"Spectrum.m:322 Just did spectrograph call flag was %d", flag);
	
	
	// Draw the spectrum graph if required
	
	if (spectrumGraphOnOff == 1) {
	
		bezierPath = [[NSBezierPath alloc] init];
		[bezierPath setLineWidth:1];
		[bezierPath setCachesBezierPath:NO];
		[[NSColor darkGrayColor] set];

		int xScaleSize = bounds.size.width - SMLEFT_MARGIN - SMRIGHT_MARGIN;
		int yScaleSize = bounds.size.height - SMBOTTOM_MARGIN - SMTOP_MARGIN;
		float yScaleFactor = (float) yScaleSize / ((spectrumMax - spectrumMin));
		float xScaleFactor = (float) xScaleSize / ((float) samplingWindowSize / X_SCALE_FUDGE);

		
	
		start.x = graphOrigin.x + SMLEFT_MARGIN;
		start.y = rint((float)graphOrigin.y + (float)yScaleSize - spectrumMax - (float)SMBOTTOM_MARGIN - (float)SMTOP_MARGIN -20.0); // - (envelopeData[startEnvelope] * 2); //graphOrigin.y + SMBOTTOM_MARGIN; // + (bounds.size.height - SMBOTTOM_MARGIN - SMTOP_MARGIN));

		[bezierPath moveToPoint:start];
	
		//NSLog(@"Spectrum.m:97 spectrumSize is %d", (samplingWindowSize / 2)); //windowSize/2);
		for (index = 0; index < samplingWindowSize/2; index++) {
		
			// Draw averaged signal spectrum (averaged from CIRC_BUFF_SIZE/samplingWindowSize successive spectra)
			
			currentPoint.x = start.x + rint(((float) index) * xScaleFactor); //spectrumSize;
			//currentPoint.y = graphOrigin.y + SMBOTTOM_MARGIN + tempData[index]; // (bounds.size.height - SMBOTTOM_MARGIN - SMTOP_MARGIN)) + 10000 * analysisData[index];
			currentPoint.y = start.y + spectrum[index] * yScaleFactor; // * (float) yScaleFactor; // / (4 * scaleFactor));
			if (currentPoint.y < (float)graphOrigin.y + SMBOTTOM_MARGIN) currentPoint.y = (float)graphOrigin.y + SMBOTTOM_MARGIN;
			[bezierPath lineToPoint:currentPoint];
		}
	
		// NSLog(@"Spectrum.m:350 spectralEnvelopeOnOff state is %d switch is %d", spectralEnvelopeOnOff, [envelopeSwitch state]);

		[bezierPath stroke];
		[bezierPath release];
	
	
	}


	// Draw spectral envelope, if required and not test state (the data is already scaled -- see above)
	if (spectralEnvelopeOnOff == 1 && normalTestState == 0) {

		bezierPath = [[NSBezierPath alloc] init];
		[bezierPath setLineWidth:1];
		[bezierPath setCachesBezierPath:NO];
		[[NSColor greenColor] set];
	
		int xScaleSize = bounds.size.width - SMLEFT_MARGIN - SMRIGHT_MARGIN;
		int yScaleSize = bounds.size.height - SMBOTTOM_MARGIN;
		float xScaleFactor = (float) xScaleSize / ((float)samplingWindowSize / X_SCALE_FUDGE);
		xScaleFactor = xScaleFactor * xScaleSize/(xScaleSize - startEnvelope / xScaleFactor);
		
		start.x = graphOrigin.x + SMLEFT_MARGIN;
		//NSLog(@"Spectrum.m:494 graphOrigin.y is %d, yScaleSize is %d, envelopeDataMax is %f", graphOrigin.y, yScaleSize, envelopeDataMax);
		start.y = graphOrigin.y + yScaleSize;


		[bezierPath moveToPoint:start];
		//NSLog(@"Spectrum.m:109 spectrumSize is %d", (samplingWindowSize / 2)); //windowSize/2);
		for (index = startEnvelope; index < (samplingWindowSize/2) - startEnvelope; index++) {
			
			currentPoint.x = start.x + rint(((float) index) * xScaleFactor);
			currentPoint.y = envelopeData[index] - SMBOTTOM_MARGIN;
			if (currentPoint.y < (float)graphOrigin.y + SMBOTTOM_MARGIN) currentPoint.y = (float)graphOrigin.y + SMBOTTOM_MARGIN;
			if (index == startEnvelope) [bezierPath moveToPoint:currentPoint];
			else [bezierPath lineToPoint:currentPoint];
			
		
		}
	
		[bezierPath stroke];
		[bezierPath release];
	
	}
	
	free(tempData);
	free(spectrum);

}



- (void) addLabels
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
	
	//[[NSColor greenColor] set];
    [timesFont set];
	
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
	[[NSColor greenColor] set];
	
	currentYPos = graphOrigin.y;
	
    for (i = 0; i <= _yScaleDivs; i+=_yLabelInterval) {
        NSString *label;
        NSSize labelSize;
		
        [bezierPath moveToPoint:NSMakePoint(graphOrigin.x, currentYPos)];
		currentYPos = graphOrigin.y + i * sectionHeight;
		if (!magnitudeScale){
			label = [NSString stringWithFormat:@"%2.1f", i * _yScaleSteps + _yScaleOrigin];
		}
		else {
			label = [NSString stringWithFormat:@"%3.0f", i * _yScaleSteps + _yScaleOrigin];
		}
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

- (IBAction) setNormalTestState:sender
{
	int runButtonState = [runButton state];
	normalTestState = [[sender selectedCell] tag];
	if (normalTestState == 0) {
		[self freeAnalysisData];
		[updateMatrix setEnabled:YES];
		//NSLog(@"Spectrum.m:499 runButtonState is %d", runButtonState);
		if (runButtonState == 1) [doAnalysisButton setEnabled:YES]; // 
	}
	else {
		[updateMatrix setEnabled:NO];
		[doAnalysisButton setEnabled:NO];		
	}

	//NSLog(@"Spectrum.m421 normalTestState is %d", normalTestState);
	[self setNeedsDisplay:YES];
}

- (IBAction) setShowSpectralEnvelope:sender
{
	spectralEnvelopeOnOff = [sender state];
	NSLog(@"Spectrum.m:273 spectralEnvelopeOnOff state is %d", spectralEnvelopeOnOff);
	[self setNeedsDisplay:YES];
}

- (IBAction) setShowGraph:sender
{
	spectrumGraphOnOff = [sender state];
	[self setNeedsDisplay:YES];
}

- (IBAction) setEnvelopeSmoothingSpan:sender;
{
	BOOL rangeError = 0;
	spectralEnvelopeSpan = [sender floatValue];
	if (spectralEnvelopeSpan < MIN_SPAN) {
		rangeError = 1;
		spectralEnvelopeSpan = MIN_SPAN;
	}
	if (spectralEnvelopeSpan > MAX_SPAN) {
		rangeError = 1;
		spectralEnvelopeSpan = MAX_SPAN;
	}
	if (rangeError) {
		NSBeep();
		[sender setFloatValue:spectralEnvelopeSpan];
    } 
	else
		[self setNeedsDisplay:YES];
}


- (void) setSpectrumGrid:(BOOL)spectrumGridState
{
	gridDisplay = (int)spectrumGridState;
	NSLog(@"Spectrum.m:535 gridDisplay is %d\n", gridDisplay);
	[self setNeedsDisplay:YES];
}


- (void) freeAnalysisData
{
	free(analysisData);
	analysisDataExists = FALSE;
}

- (void)normalizeSwitchPushed:sender
{
    //  RECORD VALUE
    normalize = [sender state];
		
    //  DISPLAY
    [self setNeedsDisplay:YES]; 
}


- (void) setAnalysisBinSize:(int)value
{
	samplingWindowSize = value;
	NSLog(@"Spectrum.m:295 samplingWindowSize is %d", samplingWindowSize);
	[self setNeedsDisplay:YES];
}


- (void) setAnalysisWindowShape:(float *)window
{
	samplingWindowShape = window;
	NSLog(@"Spectrum.m:373 samplingWindowShape set");
	[self setNeedsDisplay:YES];
}

- (void) setMagnitudeScale:(int)value
{
	magnitudeScale = value;
}


@end
