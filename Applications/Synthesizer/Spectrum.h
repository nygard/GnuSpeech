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
//  Spectrum.h
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
#import "AnalysisWindow.h"
#import "Spectrograph.h"
#import "Analysis.h"

@interface Spectrum : ChartView

#define SMLEFT_MARGIN 15.0 // ####
#define SMRIGHT_MARGIN 5
#define SMTOP_MARGIN 5
#define SMBOTTOM_MARGIN 15.0

/*
//#define LABEL_MARGIN 3 
#define SMLEFT_MARGIN 30
#define SMRIGHT_MARGIN 20
#define SMTOP_MARGIN 15
#define SMBOTTOM_MARGIN 30
*/

#define SMX_SCALE_DIVS 11
#define SMX_SCALE_ORIGIN 0
#define SMX_SCALE_STEPS 1000
#define SMX_LABEL_INTERVAL 2
#define SMY_SCALE_DIVS_LOG 9
#define SMY_SCALE_DIVS_LIN 10
#define SMY_SCALE_ORIGIN_LOG -90
#define SMY_SCALE_ORIGIN_LIN 0
#define SMY_SCALE_STEPS_LOG 10
#define SMY_SCALE_STEPS_LIN 0.1
#define SMY_LABEL_INTERVAL 1

#define MIN_SPAN 0.0
#define MAX_SPAN 0.02
#define SPAN_DEF 0.02
#define TEST_DATA_SIZE 1024
#define X_SCALE_FUDGE 3.74


#define MAX_SAMPLE_SIZE    32768.0          /*  LARGEST SIGNED SHORT INT  */



{
	id runButton;
	id spectrograph;
	id analysis;
	id envelopeField;
	id envelopeSwitch;
	id graphSwitch;
	id testSwitch;
	id analysisWindow;
	id updateMatrix;
	id doAnalysisButton;
	float *analysisData;
	float *tempData;
	float *spectrum;
	BOOL analysisDataExists;
	BOOL gridDisplay;
	int samplingWindowSize;
	float *samplingWindowShape;
	BOOL normalize;
	float scale;
	int normalTestState;
	int spectralEnvelopeOnOff;	// 0 IS OFF, 1 IS ON
	int spectrumGraphOnOff;     // 0 IS OFF, 1 IS ON
	float spectralEnvelopeSpan;	// SPAN SETS # OF SAMPLES EITHER SIDE USED IN AVERAGE DEF
	int magnitudeScale;
	int startEnvelope;
	int endEnvelope;

	

}

- (IBAction) setNormalTestState:sender;
- (IBAction) setShowSpectralEnvelope:sender;
- (IBAction) setEnvelopeSmoothingSpan:sender;
- (IBAction) setShowGraph:sender;
- (void) setSpectrumGrid:(BOOL)spectrumGridState;
- (void) freeAnalysisData;
- (void) normalizeSwitchPushed:sender;
- (void) setAnalysisBinSize:(int)value;
- (void) setAnalysisWindowShape:(float *) window;
- (void) setMagnitudeScale:(int)value;


@end
