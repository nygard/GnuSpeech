//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Analysis.h"


#import "AnalysisWindow.h"
#import "Spectrum.h"
#import "Spectrograph.h"
#include <math.h>


/*  LOCAL DEFINES  ***********************************************************/
#define BIN_SIZE_DEF          256
#define OUTPUT_SRATE          22500

#define WINDOW_TYPE_DEF       BLACKMAN

#define ALPHA_MIN             0.0
#define ALPHA_MAX             1.0
#define ALPHA_DEF             0.54

#define BETA_MIN              0.0
#define BETA_MAX              10.0
#define BETA_DEF              5.0

#define CONTINUOUS            0
#define QUANTIZED             1
#define GRAY_LEVEL_DEF        CONTINUOUS

#define LINEAR                0
#define LOG                   1
#define MAGNITUDE_SCALE_DEF   LOG

#define THRESHOLD_LINEAR_MIN  0.0
#define THRESHOLD_LINEAR_MAX  1.0
#define UPPER_THRESH_LIN_DEF  0.15
#define LOWER_THRESH_LIN_DEF  THRESHOLD_LINEAR_MIN

#define THRESHOLD_LOG_MIN     (-120)
#define THRESHOLD_LOG_MAX     0
#define UPPER_THRESH_LOG_DEF  (-18)
#define LOWER_THRESH_LOG_DEF  (-66)

#define UPPER                 0
#define LOWER                 1

#define SNAPSHOT_MODE         0
#define CONTINUOUS_MODE       1
#define UPDATE_MODE_DEF       SNAPSHOT_MODE
#define ENABLED				  1
#define DISABLED			  0

#define UPDATE_RATE_MIN       0.1
#define UPDATE_RATE_MAX       5.0
#define UPDATE_RATE_DEF       1.0

#define NORMALIZE_INPUT_DEF   YES
#define SPECTROGRAPH_GRID_DEF NO
#define SPECTRUM_GRID_DEF     YES



@implementation Analysis

- init
{
    /*  DO REGULAR INITIALIZATION  */
    [super init];

    /*  SET DEFAULT INSTANCE VARIABLES  */
    [self defaultInstanceVariables];

    /*  SOME IVARS ARE SET ONLY AT INIT TIME  */
    updateMode = UPDATE_MODE_DEF;
    updateRate = UPDATE_RATE_DEF;

    /*  ALLOCATE A SOUND DATA OBJECT  */
    //soundDataObject = [[SoundData alloc] init];

    /*  ALLOCATE AN ANALYSIS DATA OBJECT  */
    //analysisDataObject = [[AnalysisData alloc] init];
	//NSLog(@"Analysis.m:105 AnalysisData and SoundData objects allocated");

    return self;
}



- (void)dealloc
{
    /*  FREE THE SOUND DATA OBJECT  */
    //[soundDataObject release];

    /*  FREE THE ANALYSIS DATA OBJECT  */
    //[analysisDataObject release];

    /*  DO REGULAR FREE  */
    [super dealloc]; 
}



- (void)defaultInstanceVariables
{
    /*  SET DEFAULTS  */
    normalizeInput = NORMALIZE_INPUT_DEF;
    binSize = BIN_SIZE_DEF;
    windowType = WINDOW_TYPE_DEF;
    alpha = ALPHA_DEF;
    beta = BETA_DEF;
    grayLevel = GRAY_LEVEL_DEF;
    magnitudeScale = MAGNITUDE_SCALE_DEF;
    linearUpperThreshold = UPPER_THRESH_LIN_DEF;
    linearLowerThreshold = LOWER_THRESH_LIN_DEF;
    logUpperThreshold = UPPER_THRESH_LOG_DEF;
    logLowerThreshold = LOWER_THRESH_LOG_DEF;
    spectrographGrid = SPECTROGRAPH_GRID_DEF;
    spectrumGrid = SPECTRUM_GRID_DEF; 
}



- (void)awakeFromNib
{
    /*  USE OPTIMIZED DRAWING IN THE WINDOW  */
    //[analysisWindow useOptimizedDrawing:YES];
	//NSArray binSizeTitles[3] = {@"512", @"256", @"128"};
	
    /*  SAVE THE FRAME FOR THE WINDOW  */
    //[analysisWindow setFrameAutosaveName:@"analysisWindow"];

    /*  SET FORMAT OF FIELDS  */
    [binSizeFrequency setFloatingPointFormat:NO left:3 right:2];
    [windowForm setFloatingPointFormat:NO left:3 right:2];
    [rateForm setFloatingPointFormat:NO left:1 right:1];

    /*  SET UPDATE RATE  */
    [rateForm setFloatValue:updateRate];
	[doAnalysisButton setEnabled:NO];
	[rateForm setEnabled:NO];
	//[updateMatrix setEmabled:NO];
	
	[windowForm setEnabled:NO];
	[windowForm setTitle:@"           "];
	[windowForm setStringValue:@""];
	
	NSLog(@"Analysis.m:167 Analysis wake from Nib");

	
	[self displayAndSynthesizeIvars];
}



- (void)displayAndSynthesizeIvars
{
    //  SET INPUT AMPLITUDE NORMALIZE SWITCH
    [normalizeSwitch setState:normalizeInput];

    //  SET BIN SIZE
    [binSizePopUp selectItemAtIndex:[binSizePopUp indexOfItemWithTag: binSize]];
    [binSizePopUp setTitle: [binSizePopUp titleOfSelectedItem]];
    [self binSizeSelected: binSizePopUp ];

    //  SET WINDOW TYPE
    [windowPopUp selectItemAtIndex:[windowPopUp indexOfItemWithTag: windowType]];
    [windowPopUp setTitle: [windowPopUp titleOfSelectedItem]];
    [self windowSelected: windowPopUp];

    //  SET GRAY LEVEL
    [grayLevelPopUp selectItemAtIndex:
	[grayLevelPopUp indexOfItemWithTag: grayLevel]];
    [grayLevelPopUp setTitle: [grayLevelPopUp titleOfSelectedItem]];
    [self grayLevelSelected: grayLevelPopUp];

    //  SET MAGNITUDE AND THRESHOLD LEVELS
    [magnitudePopUp selectItemAtIndex:
	[magnitudePopUp indexOfItemWithTag: magnitudeScale]];
    [magnitudePopUp setTitle: [magnitudePopUp titleOfSelectedItem]];
    [self magnitudeScaleSelected: magnitudePopUp];

    //  SET SPECTROGRAPH AND SPECTRUM GRID SWITCHES
    [spectrographGridButton setState:spectrographGrid];
    [spectrumGridButton setState:spectrumGrid];
	
	// SET UP INITIAL WINDOW
	[analysisWindow setWindowType:WINDOW_TYPE_DEF alpha:ALPHA_DEF beta:BETA_DEF size:BIN_SIZE_DEF];




}

- (void)saveToStream:(NSArchiver *)typedStream
{
    /*  WRITE INSTANCE VARIABLES TO TYPED STREAM  */
    [typedStream encodeValuesOfObjCTypes:"ciiffiiffiicc", &normalizeInput, &binSize,
		 &windowType, &alpha, &beta, &grayLevel, &magnitudeScale,
		 &linearUpperThreshold, &linearLowerThreshold,
		 &logUpperThreshold, &logLowerThreshold,
		 &spectrographGrid, &spectrumGrid]; 
}



- (void)openFromStream:(NSArchiver *)typedStream
{
    /*  READ INSTANCE VARIABLES FROM TYPED STREAM  */
    [typedStream decodeValuesOfObjCTypes:"ciiffiiffiicc", &normalizeInput, &binSize,
		&windowType, &alpha, &beta, &grayLevel, &magnitudeScale,
		&linearUpperThreshold, &linearLowerThreshold,
		&logUpperThreshold, &logLowerThreshold,
		&spectrographGrid, &spectrumGrid];

    /*  DISPLAY THE NEW VALUES  */
    [self displayAndSynthesizeIvars]; 
}


- (void)windowWillMiniaturize:sender
{
    [sender setMiniwindowImage:[NSImage imageNamed:@"Synthesizer.tiff"]];
}



- (void)setAnalysisEnabled:(BOOL)flag
{
      //  ENABLE/DISABLE BUTTONS ACCORDING TO MODE
    if ([runButton state]) {
		
	//  ENABLE UPDATEMATRIX
	[updateMatrix setEnabled:YES];
		
	//  ENABLE/DISABLE BUTTONS ACCORDING TO MODE
	[self updateMatrixPushed:updateMatrix];
    }
    else {
	//  DISABLE ALL UPDATE CONTROLS
	[updateMatrix setEnabled:NO];
	[doAnalysisButton setEnabled:NO];
	[rateForm setEnabled:NO];
	[rateSecond setTextColor:[NSColor darkGrayColor]];
    }

    //  DISPLAY CHANGES TO SUBVIEWS OF WINDOW
    //[analysisWindow displayIfNeeded]; 
}


- startContinuousAnalysis
{
    /*  CREATE A TIMED ENTRY, AS LONG AS ONE DOESN'T ALREADY EXIST  */
    if (!timedEntry)
	timedEntry = [[NSTimer scheduledTimerWithTimeInterval:updateRate 
			target: self
			selector: @selector(doAnalysisButtonPushed:)
			userInfo: nil
			repeats:YES] 
			retain];

    return self;
}



- stopContinuousAnalysis
{
    //  REMOVE THE TIMED ENTRY, IF IT EXISTS
    if (timedEntry)
      {
	[timedEntry invalidate]; [timedEntry release];
      }

    //  SET THE TIMED ENTRY TAG TO NULL
    timedEntry = NULL;

    return self;
}



- resetContinuousAnalysis
{
    //  STOP THE ANALYSIS
    [self stopContinuousAnalysis];

    //  RESTART THE ANALYSIS WITH THE NEW RATE
    [self startContinuousAnalysis];

    return self;
}



- (void)setRunning
{
    //  RECORD WHETHER RUNNING OR NOT
    running = [runButton state];  // [controller tubeRunState];
	[updateMatrix setEnabled:YES];

    //  ENABLE/DISABLE DO ANALYSIS BUTTON, ACCORDING TO STATE
	if (running) {
		//[updateMatrix setEnabled:YES];
		if (updateMode == CONTINUOUS_MODE) {
			[self startContinuousAnalysis];
			[doAnalysisButton setEnabled:NO];
			[updateMatrix setEnabled:YES];
			NSLog(@"Analysis.m:331 running + continuous mode");
		}
		else {
			[doAnalysisButton setEnabled:YES];
			[updateMatrix setEnabled:YES];
			[self stopContinuousAnalysis];
			NSLog(@"Analysis.m:336 running + snapshot mode");
		}
	}
	else {
		//[updateMatrix setEnabled:NO];
		[doAnalysisButton setEnabled:NO];		
	}

}



- (void)normalizeSwitchPushed:sender
{
    //  RECORD VALUE
    normalizeInput = [sender state];

    //  ANALYZE SOUND DATA, PUT INTO ANALYSIS DATA OBJECT
    //[analysisDataObject analyzeSoundData:soundDataObject windowSize:binSize windowType:windowType alpha:alpha beta:beta normalizeAmplitude:normalizeInput];

    //  DISPLAY
    //[self displayAnalysis]; // ****
}



- (void)magnitudeFormEntered:sender
{
    BOOL rangeError = NO;
    id selectedCell = [sender selectedCell];
    int threshold = [selectedCell tag];
	NSLog(@"Analysis.m:363 select form tag is %d", threshold);

    
    if (magnitudeScale == LINEAR) {
	/*  GET CURRENT VALUE FROM FIELD  */
	float currentValue = [selectedCell floatValue];

	/*  CHECK FOR RANGE ERRORS  */
	if (threshold == UPPER) {
	    if (currentValue < linearLowerThreshold) {
		currentValue = linearLowerThreshold;
		rangeError = YES;
	    }
	    else if (currentValue > THRESHOLD_LINEAR_MAX) {
		currentValue = THRESHOLD_LINEAR_MAX;
		rangeError = YES;
	    }
	    /*  SAVE THE VALUE  */
	    linearUpperThreshold = currentValue;
	}
	else {
	    if (currentValue < THRESHOLD_LINEAR_MIN) {
		currentValue = THRESHOLD_LINEAR_MIN;
		rangeError = YES;
	    }
	    else if (currentValue > linearUpperThreshold) {
		currentValue = linearUpperThreshold;
		rangeError = YES;
	    }
	    /*  SAVE THE VALUE  */
	    linearLowerThreshold = currentValue;
	}
    }
    else {
	/*  GET CURRENT (ROUNDED) VALUE FROM FIELD  */
	int currentValue = (int)rint([sender doubleValue]);

	/*  CHECK FOR RANGE ERRORS  */
	if (threshold == UPPER) {
	    if (currentValue < logLowerThreshold) {
		currentValue = logLowerThreshold;
		rangeError = YES;
	    }
	    else if (currentValue > THRESHOLD_LOG_MAX) {
		currentValue = THRESHOLD_LOG_MAX;
		rangeError = YES;
	    }
	    /*  SAVE THE VALUE  */
	    logUpperThreshold = currentValue;

	    /*  DISPLAY ROUNDED VALUE  */
	    [selectedCell setIntValue:logUpperThreshold];
	}
	else {
	    if (currentValue < THRESHOLD_LOG_MIN) {
		currentValue = THRESHOLD_LOG_MIN;
		rangeError = YES;
	    }
	    else if (currentValue > logUpperThreshold) {
		currentValue = logUpperThreshold;
		rangeError = YES;
	    }
	    /*  SAVE THE VALUE  */
	    logLowerThreshold = currentValue;

	    /*  DISPLAY ROUNDED VALUE  */
	    [selectedCell setIntValue:logLowerThreshold];
	}
    }

    /*  DISPLAY  */
    //[self displayAnalysis]; // ****

    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
	NSBeep();
	if (magnitudeScale == LINEAR) {
	    if (threshold == UPPER)
		[selectedCell setFloatValue:linearUpperThreshold];
	    else
		[selectedCell setFloatValue:linearLowerThreshold];
	}
	else {
	    if (threshold == UPPER)
		[selectedCell setIntValue:logUpperThreshold];
	    else
		[selectedCell setIntValue:logLowerThreshold];
	}
	[sender selectCellWithTag:threshold];
    } 
	[spectrograph setNeedsDisplay:YES];
}



- (void)magnitudeScaleSelected:sender
{
    /*  RECORD MAGNITUDE SCALE TYPE  */
    magnitudeScale = [[sender selectedItem] tag];
	NSLog(@"Analysis.m:456 magnitude scale is %d", magnitudeScale);
	[sender selectItemWithTag:magnitudeScale];

    /*  DEAL WITH THRESHOLD DISPLAY  */
    switch (magnitudeScale) {
      case LINEAR:
	[[magnitudeForm cellWithTag:UPPER] setFloatingPointFormat:NO left:1 right:3];
	[[magnitudeForm cellWithTag:LOWER] setFloatingPointFormat:NO left:1 right:3];
	[[magnitudeForm cellWithTag:UPPER] setFloatValue:linearUpperThreshold];
	[[magnitudeForm cellWithTag:LOWER] setFloatValue:linearLowerThreshold];
	[magnitudeLabel setTextColor:[NSColor lightGrayColor]];
	break;
      case LOG:
	[[magnitudeForm cellWithTag:UPPER] setFloatingPointFormat:NO left:2 right:0];
	[[magnitudeForm cellWithTag:LOWER] setFloatingPointFormat:NO left:2 right:0];
	[[magnitudeForm cellWithTag:UPPER] setIntValue:logUpperThreshold];
	[[magnitudeForm cellWithTag:LOWER] setIntValue:logLowerThreshold];
	[magnitudeLabel setTextColor:[NSColor blackColor]];
	break;
      default:
	break;
    }
	[spectrum setMagnitudeScale:magnitudeScale];
	[spectrograph setMagnitudeScale:magnitudeScale];
    /*  DISPLAY  */
    [spectrum setNeedsDisplay:YES];
    //[analysisWindow displayIfNeeded]; 
}



- (void)binSizeSelected:sender
{
	
    //  RECORD THE BIN SIZE AND CHANGE TITLE DISPLAYED TO SELECTION
    binSize = [[sender selectedItem] tag];
	NSLog(@"In Analysis.m:491, binSizeSelected is %f, tag is %d", (float)binSize, [[sender selectedItem] tag]);
	[binSizePopUp setTitle:[sender titleOfSelectedItem]];


    /*  CALCULATE AND DISPLAY THE BIN SIZE IN HZ  */
    [binSizeFrequency setFloatValue:(OUTPUT_SRATE/2.0)/((float)binSize/2.0)];
	
	[self updateWindow];
	
	[spectrum setAnalysisBinSize:binSize]; // ****
	


    /*  ANALYZE SOUND DATA, PUT INTO ANALYSIS DATA OBJECT  */
    //[analysisDataObject analyzeSoundData:soundDataObject windowSize:binSize windowType:windowType alpha:alpha beta:beta normalizeAmplitude:normalizeInput];

}



- (void)doAnalysisButtonPushed:sender
{
	// RELEASE OLD SOUND DATA
    [spectrum freeAnalysisData];
	NSLog(@"Analysis.m:514 doAnalysisButton pushed");
	
	
	[spectrum setNeedsDisplay:YES];
}



- (void)grayLevelSelected:sender
{
    /*  RECORD GRAY-LEVEL TYPE  */
    grayLevel = [[sender selectedItem] tag];

    /*  DISPLAY  */
    //[self displayAnalysis]; // ****
}



- (void)rateFormEntered:sender
{
    BOOL rangeError = NO;

    /*  GET CURRENT VALUE FROM FIELD  */
    float currentValue = [sender floatValue];
	NSLog(@"Analysis.m:539, Update rate form entered value %f updateRate is %f", currentValue, updateRate);
    
    /*  RETURN IMMEDIATELY IF THE RATE HAS NOT CHANGED  */
    if (currentValue == updateRate)
	return;

    /*  CHECK FOR RANGE ERRORS  */
    if (currentValue < UPDATE_RATE_MIN) {
	currentValue = UPDATE_RATE_MIN;
	rangeError = YES;
	NSLog(@"Below minimum update period");
    }
    else if (currentValue > UPDATE_RATE_MAX) {
	currentValue = UPDATE_RATE_MAX;
	rangeError = YES;
	NSLog(@"Exceeded max update period");
    }

    /*  SAVE THE VALUE  */
    updateRate = currentValue;

    //  RESET THE CONTINUOUS ANALYSIS RATE, IF CURRENTLY RUNNING
    if ((updateMode == CONTINUOUS_MODE) && [runButton state]) // && analysisEnabled)
	[self resetContinuousAnalysis];

    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
	NSBeep();
	[sender setFloatValue:updateRate];
	//[sender selectText:self];
    } 
}



- (void)spectrographGridPushed:sender
{
    /*  RECORD GRID STATUS  */
    spectrographGrid = [sender state];

    /*  SET THE GRID ON THE SPECTROGRAPH  */
    [spectrograph setSpectrographGrid:(BOOL)spectrographGrid]; 
}



- (void)spectrumGridPushed:sender
{
    /*  RECORD GRID STATUS  */
    spectrumGrid = [sender state];

    /*  SET THE GRID ON THE SPECTRUM  */
    [spectrum setSpectrumGrid:(BOOL)spectrumGrid]; 
}



- (void)updateMatrixPushed:sender
{
    /*  GET THE UPDATE STATE  */
    int currentValue = [[sender selectedCell] tag];
	NSLog(@"Analysis.m:610 updateMatrix state %d", currentValue);

    /*  ENABLE/DISABLE OTHER BUTTONS ACCORDING TO MODE  */
    if (currentValue == SNAPSHOT_MODE) {
		if ([runButton state]) [doAnalysisButton setEnabled:YES];
		NSLog(@"Analysis.m:616 updateMatrix state %d", currentValue);
		
		[rateForm setEnabled:NO];
		[rateSecond setTextColor:[NSColor darkGrayColor]];
		[testSwitch setEnabled:YES];
		}
    else {
		[doAnalysisButton setEnabled:NO];
		NSLog(@"Analysis.m:626 updateMatrix state %d", currentValue);
		//[testSwitch setState:1 atRow:0 column:0];
		[rateForm setEnabled:YES];
		[rateSecond setTextColor:[NSColor blackColor]];
		[testSwitch setEnabled:NO];
		[self setRunning];

    }

    /*  DISPLAY CHANGES TO SUBVIEWS OF WINDOW  */
    //[analysisWindow displayIfNeeded];

    /*  RETURN IMMEDIATELY, IF NO CHANGE OF MODE  */
    if (currentValue == updateMode)
	return;

    /*  RECORD CHANGED UPDATE MODE  */
    updateMode = currentValue;

    /*  START OR STOP CONTINUOUS ANALYSIS, IF CURRENTLY RUNNING  */
    if ([runButton state]) {		// WAS 'RUNNING'
	if (updateMode == CONTINUOUS_MODE)
	    [self startContinuousAnalysis];
	else
	    [self stopContinuousAnalysis];
    } 
}



- (void)windowFormEntered:sender
{
    BOOL rangeError = NO;
    /*  GET CURRENT VALUE FROM FIELD  */
    float currentValue = [sender floatValue];
	NSLog(@"Analysis.m:640 windowFormEntered value %f", currentValue);


    if (windowType == HAMMING) {
	/*  CHECK FOR RANGE ERRORS  */
	if (currentValue < ALPHA_MIN) {
	    currentValue = ALPHA_MIN;
	    rangeError = YES;
	}
	else if (currentValue > ALPHA_MAX) {
	    currentValue = ALPHA_MAX;
	    rangeError = YES;
	}
	/*  SAVE THE VALUE  */
	alpha = currentValue;
    }
    else {
	/*  CHECK FOR RANGE ERRORS  */
	if (currentValue < BETA_MIN) {
	    currentValue = BETA_MIN;
	    rangeError = YES;
	}
	else if (currentValue > BETA_MAX) {
	    currentValue = BETA_MAX;
	    rangeError = YES;
	}
	/*  SAVE THE VALUE  */
	beta = currentValue;
    }

	//NSLog(@"Analaysis.m:682 alpha is %f, beta is %f", alpha, beta);
	
    /*  ANALYZE SOUND DATA, PUT INTO ANALYSIS DATA OBJECT  */
    //[analysisDataObject analyzeSoundData:soundDataObject windowSize:binSize windowType:windowType alpha:alpha beta:beta normalizeAmplitude:normalizeInput];

    /*  DISPLAY  */
    [spectrum setNeedsDisplay:YES];

    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
	NSBeep();
	[sender setFloatValue:currentValue];
	[sender selectText:self];
    } 
}



- (void)windowSelected:sender
{
	
    /*  RECORD WINDOW TYPE  */
    windowType = [[sender selectedItem] tag];
	NSLog(@"Analysis.m:680 windowSelected windowType %d", windowType);
	[self updateWindow];
	
}

- (void)updateWindow
{

    /*  DEAL WITH ALPHA OR BETA DISPLAY, IF NECESSARY  */
    switch (windowType) {
      case HAMMING:
	[windowForm setEnabled:YES];
	[windowForm setTitle:@"Alpha:"];
	[windowForm setFloatValue:alpha];
	break;
      case KAISER:
	[windowForm setEnabled:YES];
	[windowForm setTitle:@"Beta:"];
	[windowForm setFloatValue:beta];
	break;
      case RECTANGULAR:
      case TRIANGULAR:
      case HANNING:
      case BLACKMAN:
      default:
	[windowForm setEnabled:NO];
	[windowForm setTitle:@"           "];
	[windowForm setStringValue:@""];
	break;
    }
    
    /*  ANALYZE SOUND DATA, PUT INTO ANALYSIS DATA OBJECT  */
    //[analysisDataObject analyzeSoundData:soundDataObject windowSize:binSize windowType:windowType alpha:alpha beta:beta normalizeAmplitude:normalizeInput];
	NSLog(@"Analysis.m:727 Window changed: window type %d, alpha %f, beta %f, window size %d", windowType, alpha, beta, binSize);
	[analysisWindow setWindowType:(int)windowType alpha:(float)alpha beta:(float)beta size:binSize];
	
	//  DISPLAY
	//[spectrum setNeedsDisplay:YES]; 
}

- (int)runState
{
	running = [runButton state];
	return running;
}

/*
- (void)displayAnalysis
{
/*    //  SEND ANALYSIS TO DISPLAYS
    //[spectrograph displayAnalysis:analysisDataObject
		  grayLevel:grayLevel
		  magnitudeScale:magnitudeScale
		  linearUpperThreshold:linearUpperThreshold
		  linearLowerThreshold:linearLowerThreshold
		  logUpperThreshold:(float)logUpperThreshold
		  logLowerThreshold:(float)logLowerThreshold];

    //[spectrum displayAnalysis:analysisDataObject magnitudeScale:magnitudeScale]; 
}
*/
	
@end
