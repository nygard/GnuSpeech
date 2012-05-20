//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

@interface Analysis:NSObject
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

- (void)windowWillMiniaturize:sender;

- (void)setAnalysisEnabled:(BOOL)flag;
- (IBAction)setRunning;

- (void)normalizeSwitchPushed:sender;
- (void)magnitudeFormEntered:sender;
- (void)magnitudeScaleSelected:sender;
- (void)binSizeSelected:sender;
- (void)doAnalysisButtonPushed:sender;
- (void)grayLevelSelected:sender;
- (void)rateFormEntered:sender;
- (void)spectrographGridPushed:sender;
- (void)spectrumGridPushed:sender;
- (void)updateMatrixPushed:sender;
- (void)windowFormEntered:sender;
- (void)windowSelected:sender;
- (void)updateWindow;

//- (void)displayAnalysis;

- (int)runState;


@end
