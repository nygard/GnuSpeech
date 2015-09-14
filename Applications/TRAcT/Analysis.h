//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface Analysis : NSObject
{
    id  analysisWindow;
    id	magnitudeForm;
    id	magnitudePopUp;
    id  magnitudeLabel;
    id	binSizeFrequency;
    id	binSizePopUp;
    id	doAnalysisButton;
    id	grayLevelPopUp;
    id  normalizeSwitch;
    id	rateForm;
    id	rateSecond;
    id	spectrograph;
    id	spectrographGridButton;
    id	spectrum;
    id	spectrumGridButton;
    id	updateMatrix;
    id	windowForm;
    id	windowPopUp;
    id  synthesizer;
	id  runButton;
	id	testSwitch;

    //id  soundDataObject;
    id  analysisDataObject;
	id controller;
	
    BOOL normalizeInput;
    int binSize;
    int windowType;
    float alpha;
    float beta;
    int grayLevel;
    int magnitudeScale;
    float linearUpperThreshold;
    float linearLowerThreshold;
    int logUpperThreshold;
    int logLowerThreshold;
    BOOL spectrographGrid;
    BOOL spectrumGrid;

    int updateMode;
    float updateRate;
    BOOL analysisEnabled;
    BOOL running;
	

    NSTimer *timedEntry;
}

- (void)defaultInstanceVariables;
- (void)awakeFromNib;
- (void)displayAndSynthesizeIvars;

- (void)saveToStream:(NSArchiver *)typedStream;
- (void)openFromStream:(NSArchiver *)typedStream;

- (void)windowWillMiniaturize:(id)sender;

- (void)setAnalysisEnabled:(BOOL)flag;
- (IBAction)setRunning;

- (void)normalizeSwitchPushed:(id)sender;
- (void)magnitudeFormEntered:(id)sender;
- (void)magnitudeScaleSelected:(id)sender;
- (void)binSizeSelected:(id)sender;
- (void)doAnalysisButtonPushed:(id)sender;
- (void)grayLevelSelected:(id)sender;
- (void)rateFormEntered:(id)sender;
- (void)spectrographGridPushed:(id)sender;
- (void)spectrumGridPushed:(id)sender;
- (void)updateMatrixPushed:(id)sender;
- (void)windowFormEntered:(id)sender;
- (void)windowSelected:(id)sender;
- (void)updateWindow;

//- (void)displayAnalysis;

- (int)runState;


@end
