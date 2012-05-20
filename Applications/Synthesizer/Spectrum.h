//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

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
