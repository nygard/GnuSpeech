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
//  ChartView.h
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.3
//
////////////////////////////////////////////////////////////////////////////////

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
//- (NSMutableArray *)makeData;
- (void)drawGrid;
- (NSPoint)graphOrigin;

@end
