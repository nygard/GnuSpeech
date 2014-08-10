//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MSynthesisParameterEditor.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

@implementation MSynthesisParameterEditor
{
    // General
    IBOutlet NSTextField *_masterVolume;
    IBOutlet NSTextField *_length;
    IBOutlet NSTextField *_temperature;
    IBOutlet NSTextField *_balance;
    IBOutlet NSTextField *_breathiness;
    IBOutlet NSTextField *_lossFactor;
    IBOutlet NSTextField *_pitchMean;

    IBOutlet NSSlider *_masterVolumeSlider;
    IBOutlet NSSlider *_lengthSlider;
    IBOutlet NSSlider *_temperatureSlider;
    IBOutlet NSSlider *_balanceSlider;
    IBOutlet NSSlider *_breathinessSlider;
    IBOutlet NSSlider *_lossFactorSlider;
    IBOutlet NSSlider *_pitchMeanSlider;

    // Nasal Cavity
    IBOutlet NSTextField *_n1;
    IBOutlet NSTextField *_n2;
    IBOutlet NSTextField *_n3;
    IBOutlet NSTextField *_n4;
    IBOutlet NSTextField *_n5;

    IBOutlet NSSlider *_n1Slider;
    IBOutlet NSSlider *_n2Slider;
    IBOutlet NSSlider *_n3Slider;
    IBOutlet NSSlider *_n4Slider;
    IBOutlet NSSlider *_n5Slider;

    IBOutlet NSTextField *_tp;
    IBOutlet NSTextField *_tnMin;
    IBOutlet NSTextField *_tnMax;
    IBOutlet NSMatrix *_waveform;

    IBOutlet NSSlider *_tpSlider;
    IBOutlet NSSlider *_tnMinSlider;
    IBOutlet NSSlider *_tnMaxSlider;

    IBOutlet NSTextField *_throatCutoff;
    IBOutlet NSTextField *_throatVolume;
    IBOutlet NSTextField *_apScale;
    IBOutlet NSTextField *_mouthCoef;
    IBOutlet NSTextField *_noseCoef;
    IBOutlet NSTextField *_mixOffset;
    IBOutlet NSMatrix *_modulation;

    IBOutlet NSSlider *_throatCutoffSlider;
    IBOutlet NSSlider *_throatVolumeSlider;
    IBOutlet NSSlider *_apScaleSlider;
    IBOutlet NSSlider *_mouthCoefSlider;
    IBOutlet NSSlider *_noseCoefSlider;
    IBOutlet NSSlider *_mixOffsetSlider;

    IBOutlet NSMatrix *_stereoMono;
    IBOutlet NSMatrix *_samplingRate;

    MModel *_model;
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super initWithWindowNibName:@"SynthesisParameters"])) {
        _model = model;

        [self setWindowFrameAutosaveName:@"Synthesis Parameters"];
    }

    return self;
}

#pragma mark -

- (MModel *)model;
{
    return _model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel != _model) {
        _model = newModel;

        [self updateViews];
    }
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    NSNumberFormatter *defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];

    [_masterVolume setFormatter:defaultNumberFormatter];
    [_length       setFormatter:defaultNumberFormatter];
    [_temperature  setFormatter:defaultNumberFormatter];
    [_balance      setFormatter:defaultNumberFormatter];
    [_breathiness  setFormatter:defaultNumberFormatter];
    [_lossFactor   setFormatter:defaultNumberFormatter];
    [_pitchMean    setFormatter:defaultNumberFormatter];
    [_n1           setFormatter:defaultNumberFormatter];
    [_n2           setFormatter:defaultNumberFormatter];
    [_n3           setFormatter:defaultNumberFormatter];
    [_n4           setFormatter:defaultNumberFormatter];
    [_n5           setFormatter:defaultNumberFormatter];
    [_tp           setFormatter:defaultNumberFormatter];
    [_tnMin        setFormatter:defaultNumberFormatter];
    [_tnMax        setFormatter:defaultNumberFormatter];
    [_throatCutoff setFormatter:defaultNumberFormatter];
    [_throatVolume setFormatter:defaultNumberFormatter];
    [_apScale      setFormatter:defaultNumberFormatter];
    [_mouthCoef    setFormatter:defaultNumberFormatter];
    [_noseCoef     setFormatter:defaultNumberFormatter];
    [_mixOffset    setFormatter:defaultNumberFormatter];

    [self updateViews];
}

- (void)updateViews;
{
    MMSynthesisParameters *synthesisParameters = [[self model] synthesisParameters];

    [_masterVolume setDoubleValue:[synthesisParameters masterVolume]];
    [_length       setDoubleValue:[synthesisParameters vocalTractLength]];
    [_temperature  setDoubleValue:[synthesisParameters temperature]];
    [_balance      setDoubleValue:[synthesisParameters balance]];
    [_breathiness  setDoubleValue:[synthesisParameters breathiness]];
    [_lossFactor   setDoubleValue:[synthesisParameters lossFactor]];
    [_pitchMean    setDoubleValue:[synthesisParameters pitch]];

    [_masterVolumeSlider setDoubleValue:[synthesisParameters masterVolume]];
    [_lengthSlider       setDoubleValue:[synthesisParameters vocalTractLength]];
    [_temperatureSlider  setDoubleValue:[synthesisParameters temperature]];
    [_balanceSlider      setDoubleValue:[synthesisParameters balance]];
    [_breathinessSlider  setDoubleValue:[synthesisParameters breathiness]];
    [_lossFactorSlider   setDoubleValue:[synthesisParameters lossFactor]];
    [_pitchMeanSlider    setDoubleValue:[synthesisParameters pitch]];

    [_n1 setDoubleValue:[synthesisParameters n1]];
    [_n2 setDoubleValue:[synthesisParameters n2]];
    [_n3 setDoubleValue:[synthesisParameters n3]];
    [_n4 setDoubleValue:[synthesisParameters n4]];
    [_n5 setDoubleValue:[synthesisParameters n5]];

    [_n1Slider setDoubleValue:[synthesisParameters n1]];
    [_n2Slider setDoubleValue:[synthesisParameters n2]];
    [_n3Slider setDoubleValue:[synthesisParameters n3]];
    [_n4Slider setDoubleValue:[synthesisParameters n4]];
    [_n5Slider setDoubleValue:[synthesisParameters n5]];

    [_tp    setDoubleValue:[synthesisParameters tp]];
    [_tnMin setDoubleValue:[synthesisParameters tnMin]];
    [_tnMax setDoubleValue:[synthesisParameters tnMax]];

    [_tpSlider    setDoubleValue:[synthesisParameters tp]];
    [_tnMinSlider setDoubleValue:[synthesisParameters tnMin]];
    [_tnMaxSlider setDoubleValue:[synthesisParameters tnMax]];

    [_throatCutoff setDoubleValue:[synthesisParameters throatCutoff]];
    [_throatVolume setDoubleValue:[synthesisParameters throatVolume]];
    [_apScale      setDoubleValue:[synthesisParameters apertureScaling]];
    [_mouthCoef    setDoubleValue:[synthesisParameters mouthCoef]];
    [_noseCoef     setDoubleValue:[synthesisParameters noseCoef]];
    [_mixOffset    setDoubleValue:[synthesisParameters mixOffset]];

    [_throatCutoffSlider setDoubleValue:[synthesisParameters throatCutoff]];
    [_throatVolumeSlider setDoubleValue:[synthesisParameters throatVolume]];
    [_apScaleSlider      setDoubleValue:[synthesisParameters apertureScaling]];
    [_mouthCoefSlider    setDoubleValue:[synthesisParameters mouthCoef]];
    [_noseCoefSlider     setDoubleValue:[synthesisParameters noseCoef]];
    [_mixOffsetSlider    setDoubleValue:[synthesisParameters mixOffset]];

    if ([synthesisParameters shouldUseNoiseModulation] == YES)
        [_modulation selectCellAtRow:0 column:1];
    else
        [_modulation selectCellAtRow:0 column:0];

    if ([synthesisParameters glottalPulseShape] == MMGlottalPulseShape_Pulse)
        [_waveform selectCellAtRow:0 column:0];
    else
        [_waveform selectCellAtRow:0 column:1];

    if ([synthesisParameters outputChannels] == MMChannels_Mono)
        [_stereoMono selectCellAtRow:0 column:0];
    else
        [_stereoMono selectCellAtRow:0 column:1];

    if ([synthesisParameters samplingRate] == MMSamplingRate_22050)
        [_samplingRate selectCellAtRow:0 column:0];
    else
        [_samplingRate selectCellAtRow:0 column:1];
}

- (IBAction)revertToDefaults:(id)sender;
{
    [[[self model] synthesisParameters] restoreDefaultValues];
    [self updateViews];
}

- (IBAction)saveAsDefaults:(id)sender;
{
    [[[self model] synthesisParameters] saveAsDefaults];
}

- (IBAction)updateMasterVolume:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setMasterVolume:value];
    [_masterVolume setDoubleValue:value];
    [_masterVolumeSlider setDoubleValue:value];
}

- (IBAction)updateTubeLength:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setVocalTractLength:value];
    [_length setDoubleValue:value];
    [_lengthSlider setDoubleValue:value];
}

- (IBAction)updateTemperature:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setTemperature:value];
    [_temperature setDoubleValue:value];
    [_temperatureSlider setDoubleValue:value];
}

- (IBAction)updateBalance:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setBalance:value];
    [_balance setDoubleValue:value];
    [_balanceSlider setDoubleValue:value];
}

- (IBAction)updateBreathiness:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setBreathiness:value];
    [_breathiness setDoubleValue:value];
    [_breathinessSlider setDoubleValue:value];
}

- (IBAction)updateLossFactor:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setLossFactor:value];
    [_lossFactor setDoubleValue:value];
    [_lossFactorSlider setDoubleValue:value];
}

- (IBAction)updatePitchMean:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setPitch:value];
    [_pitchMean setDoubleValue:value];
    [_pitchMeanSlider setDoubleValue:value];
}

- (IBAction)updateThroatCutoff:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setThroatCutoff:value];
    [_throatCutoff setDoubleValue:value];
    [_throatCutoffSlider setDoubleValue:value];
}

- (IBAction)updateThroatVolume:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setThroatVolume:value];
    [_throatVolume setDoubleValue:value];
    [_throatVolumeSlider setDoubleValue:value];
}

- (IBAction)updateAperatureScaling:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setApertureScaling:value];
    [_apScale setDoubleValue:value];
    [_apScaleSlider setDoubleValue:value];
}

- (IBAction)updateMouthCoef:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setMouthCoef:value];
    [_mouthCoef setDoubleValue:value];
    [_mouthCoefSlider setDoubleValue:value];
}

- (IBAction)updateNoseCoef:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setNoseCoef:value];
    [_noseCoef setDoubleValue:value];
    [_noseCoefSlider setDoubleValue:value];
}

- (IBAction)updateMixOffset:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setMixOffset:value];
    [_mixOffset setDoubleValue:value];
    [_mixOffsetSlider setDoubleValue:value];
}

- (IBAction)updateN1:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN1:value];
    [_n1 setDoubleValue:value];
    [_n1Slider setDoubleValue:value];
}

- (IBAction)updateN2:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN2:value];
    [_n2 setDoubleValue:value];
    [_n2Slider setDoubleValue:value];
}

- (IBAction)updateN3:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN3:value];
    [_n3 setDoubleValue:value];
    [_n3Slider setDoubleValue:value];
}

- (IBAction)updateN4:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN4:value];
    [_n4 setDoubleValue:value];
    [_n4Slider setDoubleValue:value];
}

- (IBAction)updateN5:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN5:value];
    [_n5 setDoubleValue:value];
    [_n5Slider setDoubleValue:value];
}

- (IBAction)updateTp:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setTp:value];
    [_tp setDoubleValue:value];
    [_tpSlider setDoubleValue:value];
}

- (IBAction)updateTnMin:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setTnMin:value];
    [_tnMin setDoubleValue:value];
    [_tnMinSlider setDoubleValue:value];
}

- (IBAction)updateTnMax:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setTnMax:value];
    [_tnMax setDoubleValue:value];
    [_tnMaxSlider setDoubleValue:value];
}

#pragma mark -

- (IBAction)updateGlottalPulseShape:(id)sender;
{
    [[[self model] synthesisParameters] setGlottalPulseShape:[[sender selectedCell] tag]];
}

- (IBAction)updateNoiseModulation:(id)sender;
{
    [[[self model] synthesisParameters] setShouldUseNoiseModulation:[[sender selectedCell] tag]];
}

- (IBAction)updateSamplingRate:(id)sender;
{
    [[[self model] synthesisParameters] setSamplingRate:[[sender selectedCell] tag]];
}

- (IBAction)updateOutputChannels:(id)sender;
{
    [[[self model] synthesisParameters] setOutputChannels:[[sender selectedCell] tag]];
}

@end
