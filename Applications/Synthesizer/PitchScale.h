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
//  PitchScale.h
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import "ChartView.h"
#import"structs.h"
//#import "tube.c"

@interface PitchScale : ChartView

#define PSLEFT_MARGIN 10
#define PSRIGHT_MARGIN 10
#define PSTOP_BOTTOM_MARGIN 10

#define PSY_SCALE_DIVS 14
#define PSX_SCALE_DIVS 1

{
	float horizontalCenter;
    float verticalCenter;
    float sharpCenter;
    float arrowCenter;
	
    id background;
    id foreground;
	float notePosition;
	BOOL sharpNeeded;
	BOOL arrowNeeded;
	int upDown;
	
	
}

- (void)dealloc;
- (void)awakeFromNib;
- (IBAction)drawPitch:(int)pitch Cents:(int)cents Volume:(float)volume;


@end
