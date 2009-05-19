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
//  Spectrograph.h
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import "ChartView.h"
#import "Analysis.h"

@interface Spectrograph : ChartView

#define SGLABEL_MARGIN 3 
#define SGLEFT_MARGIN 45
#define SGRIGHT_MARGIN 20
#define SGTOP_MARGIN 15
#define SGBOTTOM_MARGIN 18
#define SGGRAPH_MARGIN 10

#define SGX_SCALE_DIVS 1
#define SGX_SCALE_ORIGIN 0
#define SGX_SCALE_STEPS 1
#define SGX_LABEL_INTERVAL 3
#define SGY_SCALE_DIVS 11
#define SGY_SCALE_ORIGIN 0
#define SGY_SCALE_STEPS 1000
#define SGY_LABEL_INTERVAL 1

#define SG_YSCALE_FUDGE 1.03

// DEFAULT FOR SPECTROGRAPH GIRD IS OFF (0)
#define SGGRID_DISPLAY_DEF 0


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

- (void) setSpectrographGrid:(BOOL)spectrographGridState;
- (void) drawSpectrograph:(float *)data size:(int)size okFlag:(int)flag;
- (void) readUpperThreshold;
- (void) readLowerThreshold;
- (void) setMagnitudeScale:(int)value;



@end
