//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Crossmix.h"
#import "ChartView.h"

@implementation Crossmix

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		[self setAxesWithScale:CMX_SCALE_DIVS xScaleOrigin:CMX_SCALE_ORIGIN xScaleSteps:CMX_SCALE_STEPS
				xLabelInterval:CMX_LABEL_INTERVAL yScaleDivs:CMY_SCALE_DIVS yScaleOrigin:CMY_SCALE_ORIGIN
				   yScaleSteps:CMY_SCALE_STEPS yLabelInterval:CMY_LABEL_INTERVAL];
	}
	return self;
}

/*
- (void)setAxes:(float)xScaleDivs:(float)xScaleOrigin:(float)xScaleSteps:(int)xLabelInterval:(float)yScaleDivs:(float)yScaleOrigin:(float)yScaleSteps:(int)yLabelInterval;
{
	
	_xScaleDivs = xScaleDivs;
	_xScaleOrigin = xScaleOrigin;
	_xScaleSteps = xScaleSteps;
	_xLabelInterval = xLabelInterval;
	_yScaleDivs = yScaleDivs;
	_yScaleOrigin = yScaleOrigin;
	_yScaleSteps = yScaleSteps;
	_yLabelInterval = yLabelInterval;
	
}

*/

@end
