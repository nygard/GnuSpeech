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
//  Harmonics.h
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.3
//
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import "ChartView.h"
#import "structs.h"
#import "fft.h"

#define HLABEL_MARGIN 3 
#define HLEFT_MARGIN 20
#define HRIGHT_MARGIN 5
#define HTOP_MARGIN 5
#define HBOTTOM_MARGIN 5


#define HX_SCALE_DIVS 1
#define HX_SCALE_ORIGIN 0
#define HX_SCALE_STEPS 1
#define HX_LABEL_INTERVAL 1
#define HY_SCALE_DIVS 7
#define HY_SCALE_ORIGIN -70
#define HY_SCALE_STEPS 10
#define HY_LABEL_INTERVAL 1

#define BAR_WIDTH 3
#define BAR_MARGIN 3


@interface Harmonics : ChartView
{
}

- (void)drawSineScale:(float)amplitude;
- (void)drawHarmonics;
@end
