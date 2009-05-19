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
//  GPParamView.h
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import "ChartView.h"
#import "structs.h"


#define GPTOP_MARGIN 5

#define GPLEFT_MARGIN 5
#define GPRIGHT_MARGIN 5
#define GPTOP_MARGIN 5
#define GPBOTTOM_MARGIN 5
#define GPX_SCALE_FACTOR 80


#define WX_SCALE_DIVS 1
#define WX_SCALE_ORIGIN 0
#define WX_SCALE_STEPS 0
#define WX_LABEL_INTERVAL 0
#define WY_SCALE_DIVS 2
#define WY_SCALE_ORIGIN 0
#define WY_SCALE_STEPS 0
#define WY_LABEL_INTERVAL 1





@interface GPParamView : ChartView

{
}

- (void)drawGlottalPulseAmplitude;


@end
