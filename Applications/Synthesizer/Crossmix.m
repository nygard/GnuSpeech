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
//  Crossmix.m
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.3
//
////////////////////////////////////////////////////////////////////////////////

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
