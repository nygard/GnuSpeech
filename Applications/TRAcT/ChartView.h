//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

#define NO_OF_POINTS 10

#define LABEL_MARGIN 3 
#define LEFT_MARGIN 30
#define RIGHT_MARGIN 20
#define TOP_MARGIN 15
#define BOTTOM_MARGIN 30

#define X_SCALE_DIVS 15
#define X_SCALE_ORIGIN 0
#define X_SCALE_STEPS 1000
#define X_LABEL_INTERVAL 3
#define Y_SCALE_DIVS 4
#define Y_SCALE_ORIGIN 0
#define Y_SCALE_STEPS 0.25
#define Y_LABEL_INTERVAL 1

@interface ChartView : NSView
{
	NSFont *timesFont;
	float _xScaleDivs, _xScaleOrigin, _xScaleSteps, _yScaleDivs, _yScaleOrigin, _yScaleSteps;
	int _xLabelInterval, _yLabelInterval;
}

- (void)setAxesWithScale:(float)xScaleDivs xScaleOrigin:(float)xScaleOrigin xScaleSteps:(float)xScaleSteps
		  xLabelInterval:(int)xLabelInterval yScaleDivs:(float)yScaleDivs yScaleOrigin:(float)yScaleOrigin
			 yScaleSteps:(float)yScaleSteps yLabelInterval:(int)yLabelInterval;
- (void)drawGraph;
- (void)addLabels;
- (void)drawGrid;
- (NSPoint)graphOrigin;

@end
