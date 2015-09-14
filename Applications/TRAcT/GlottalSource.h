//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <AppKit/AppKit.h>
#import "Harmonics.h"
#import "Waveform.h"
#import "syn_structs.h"
//#import "tube.c"


/*  GLOBAL DEFINES  **********************************************************/
#define WAVEFORMTYPE_GP   0
#define WAVEFORMTYPE_SINE 1


@interface GlottalSource : NSObject
{
    id	breathinessField;
    id	breathinessSlider;
    id	frequencyField;
	id	gpParameterView;
    id	parameterForm;
    id  parameterPercent;
    id	parameterView;
    id	pitchField;
    id	pitchSlider;
    id  pitchMaxField;
    id  pitchMinField;
    id	scaleView; // Note that this outlet is connected to PitchScale in IB
    id	showAmplitudeSwitch;
    id	harmonicsSwitch;
    id	harmonics;
    id	unitButton;
    id	volumeField;
    id	volumeSlider;
    id	waveform;
    id  glottalSourceWindow;
    id  waveformTypeSwitch;
    id  noiseSource;
    id	synthesizer;
    id  controller;

    int waveformType;
    int showAmplitude;
    int harmonicsScale;

    int unit;
    int pitch;
	double ampl;
    float cents;

    float breathiness;
    int volume;

	float riseTime;
    float fallTimeMin;
    float fallTimeMax;
	
}

- (void)defaultInstanceVariables;
- (void)handleSynthDefaultsReloaded;

- (void)awakeFromNib;
//- (void)displayAndSynthesizeIvars;

- (void)saveToStream:(NSArchiver *)typedStream;
//- (void)openFromStream:(NSArchiver *)typedStream;

- (void)breathinessEntered:(id)sender;
- (void)breathinessSliderMoved:(id)sender;

- (void)waveformTypeSwitchPushed:(id)sender;

- (IBAction)glottalPulseParametersChanged:(id)sender;
//- (void)riseTimeEntered:(id)sender;
//- (void)fallTimeMinEntered:(id)sender;
//- (void)fallTimeMaxEntered:(id)sender;

- (void)frequencyEntered:(id)sender;
- (void)pitchEntered:(id)sender;
- (void)pitchSliderMoved:(id)sender;
- (void)showAmplitudeSwitchPushed:(id)sender;
- (void)harmonicsSwitchPushed:(id)sender;
- (void)unitButtonPushed:(id)sender;
- (void)volumeEntered:(id)sender;
- (void)volumeSliderMoved:(id)sender;

- (void)displayWaveformAndHarmonics;
- (int)glottalVolume;

- (void)windowWillMiniaturize:(id)sender;

@end
