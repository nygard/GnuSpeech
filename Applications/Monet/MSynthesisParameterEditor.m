//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MSynthesisParameterEditor.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

@implementation MSynthesisParameterEditor
{
    // General
    IBOutlet NSTextField *masterVolume;
    IBOutlet NSTextField *length;
    IBOutlet NSTextField *temperature;
    IBOutlet NSTextField *balance;
    IBOutlet NSTextField *breathiness;
    IBOutlet NSTextField *lossFactor;
    IBOutlet NSTextField *pitchMean;
    
    IBOutlet NSSlider *masterVolumeSlider;
    IBOutlet NSSlider *lengthSlider;
    IBOutlet NSSlider *temperatureSlider;
    IBOutlet NSSlider *balanceSlider;
    IBOutlet NSSlider *breathinessSlider;
    IBOutlet NSSlider *lossFactorSlider;
    IBOutlet NSSlider *pitchMeanSlider;
    
    // Nasal Cavity
    IBOutlet NSTextField *n1;
    IBOutlet NSTextField *n2;
    IBOutlet NSTextField *n3;
    IBOutlet NSTextField *n4;
    IBOutlet NSTextField *n5;
    
    IBOutlet NSSlider *n1Slider;
    IBOutlet NSSlider *n2Slider;
    IBOutlet NSSlider *n3Slider;
    IBOutlet NSSlider *n4Slider;
    IBOutlet NSSlider *n5Slider;
    
    IBOutlet NSTextField *tp;
    IBOutlet NSTextField *tnMin;
    IBOutlet NSTextField *tnMax;
    IBOutlet NSMatrix *waveform;
    
    IBOutlet NSSlider *tpSlider;
    IBOutlet NSSlider *tnMinSlider;
    IBOutlet NSSlider *tnMaxSlider;
    
    IBOutlet NSTextField *throatCutoff;
    IBOutlet NSTextField *throatVolume;
    IBOutlet NSTextField *apScale;
    IBOutlet NSTextField *mouthCoef;
    IBOutlet NSTextField *noseCoef;
    IBOutlet NSTextField *mixOffset;
    IBOutlet NSMatrix *modulation;
    
    IBOutlet NSSlider *throatCutoffSlider;
    IBOutlet NSSlider *throatVolumeSlider;
    IBOutlet NSSlider *apScaleSlider;
    IBOutlet NSSlider *mouthCoefSlider;
    IBOutlet NSSlider *noseCoefSlider;
    IBOutlet NSSlider *mixOffsetSlider;
    
    IBOutlet NSMatrix *stereoMono;
    IBOutlet NSMatrix *samplingRate;
    
    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"SynthesisParameters"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Synthesis Parameters"];

    return self;
}

- (void)dealloc;
{
    [model release];

    [super dealloc];
}

#pragma mark -

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel != model) {
        [model release];
        model = [newModel retain];

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

    [masterVolume setFormatter:defaultNumberFormatter];
    [length       setFormatter:defaultNumberFormatter];
    [temperature  setFormatter:defaultNumberFormatter];
    [balance      setFormatter:defaultNumberFormatter];
    [breathiness  setFormatter:defaultNumberFormatter];
    [lossFactor   setFormatter:defaultNumberFormatter];
    [pitchMean    setFormatter:defaultNumberFormatter];
    [n1           setFormatter:defaultNumberFormatter];
    [n2           setFormatter:defaultNumberFormatter];
    [n3           setFormatter:defaultNumberFormatter];
    [n4           setFormatter:defaultNumberFormatter];
    [n5           setFormatter:defaultNumberFormatter];
    [tp           setFormatter:defaultNumberFormatter];
    [tnMin        setFormatter:defaultNumberFormatter];
    [tnMax        setFormatter:defaultNumberFormatter];
    [throatCutoff setFormatter:defaultNumberFormatter];
    [throatVolume setFormatter:defaultNumberFormatter];
    [apScale      setFormatter:defaultNumberFormatter];
    [mouthCoef    setFormatter:defaultNumberFormatter];
    [noseCoef     setFormatter:defaultNumberFormatter];
    [mixOffset    setFormatter:defaultNumberFormatter];

    [self updateViews];
}

- (void)updateViews;
{
    MMSynthesisParameters *synthesisParameters = [[self model] synthesisParameters];

    [masterVolume setDoubleValue:[synthesisParameters masterVolume]];
    [length       setDoubleValue:[synthesisParameters vocalTractLength]];
    [temperature  setDoubleValue:[synthesisParameters temperature]];
    [balance      setDoubleValue:[synthesisParameters balance]];
    [breathiness  setDoubleValue:[synthesisParameters breathiness]];
    [lossFactor   setDoubleValue:[synthesisParameters lossFactor]];
    [pitchMean    setDoubleValue:[synthesisParameters pitch]];

    [masterVolumeSlider setDoubleValue:[synthesisParameters masterVolume]];
    [lengthSlider       setDoubleValue:[synthesisParameters vocalTractLength]];
    [temperatureSlider  setDoubleValue:[synthesisParameters temperature]];
    [balanceSlider      setDoubleValue:[synthesisParameters balance]];
    [breathinessSlider  setDoubleValue:[synthesisParameters breathiness]];
    [lossFactorSlider   setDoubleValue:[synthesisParameters lossFactor]];
    [pitchMeanSlider    setDoubleValue:[synthesisParameters pitch]];

    [n1 setDoubleValue:[synthesisParameters n1]];
    [n2 setDoubleValue:[synthesisParameters n2]];
    [n3 setDoubleValue:[synthesisParameters n3]];
    [n4 setDoubleValue:[synthesisParameters n4]];
    [n5 setDoubleValue:[synthesisParameters n5]];

    [n1Slider setDoubleValue:[synthesisParameters n1]];
    [n2Slider setDoubleValue:[synthesisParameters n2]];
    [n3Slider setDoubleValue:[synthesisParameters n3]];
    [n4Slider setDoubleValue:[synthesisParameters n4]];
    [n5Slider setDoubleValue:[synthesisParameters n5]];

    [tp    setDoubleValue:[synthesisParameters tp]];
    [tnMin setDoubleValue:[synthesisParameters tnMin]];
    [tnMax setDoubleValue:[synthesisParameters tnMax]];

    [tpSlider    setDoubleValue:[synthesisParameters tp]];
    [tnMinSlider setDoubleValue:[synthesisParameters tnMin]];
    [tnMaxSlider setDoubleValue:[synthesisParameters tnMax]];

    [throatCutoff setDoubleValue:[synthesisParameters throatCutoff]];
    [throatVolume setDoubleValue:[synthesisParameters throatVolume]];
    [apScale      setDoubleValue:[synthesisParameters apertureScaling]];
    [mouthCoef    setDoubleValue:[synthesisParameters mouthCoef]];
    [noseCoef     setDoubleValue:[synthesisParameters noseCoef]];
    [mixOffset    setDoubleValue:[synthesisParameters mixOffset]];

    [throatCutoffSlider setDoubleValue:[synthesisParameters throatCutoff]];
    [throatVolumeSlider setDoubleValue:[synthesisParameters throatVolume]];
    [apScaleSlider      setDoubleValue:[synthesisParameters apertureScaling]];
    [mouthCoefSlider    setDoubleValue:[synthesisParameters mouthCoef]];
    [noseCoefSlider     setDoubleValue:[synthesisParameters noseCoef]];
    [mixOffsetSlider    setDoubleValue:[synthesisParameters mixOffset]];

    if ([synthesisParameters shouldUseNoiseModulation] == YES)
        [modulation selectCellAtRow:0 column:1];
    else
        [modulation selectCellAtRow:0 column:0];

    if ([synthesisParameters glottalPulseShape] == MMGlottalPulseShape_Pulse)
        [waveform selectCellAtRow:0 column:0];
    else
        [waveform selectCellAtRow:0 column:1];

    if ([synthesisParameters outputChannels] == MMChannels_Mono)
        [stereoMono selectCellAtRow:0 column:0];
    else
        [stereoMono selectCellAtRow:0 column:1];

    if ([synthesisParameters samplingRate] == MMSamplingRate_22050)
        [samplingRate selectCellAtRow:0 column:0];
    else
        [samplingRate selectCellAtRow:0 column:1];
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
    [masterVolume setDoubleValue:value];
    [masterVolumeSlider setDoubleValue:value];
}

- (IBAction)updateTubeLength:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setVocalTractLength:value];
    [length setDoubleValue:value];
    [lengthSlider setDoubleValue:value];
}

- (IBAction)updateTemperature:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setTemperature:value];
    [temperature setDoubleValue:value];
    [temperatureSlider setDoubleValue:value];
}

- (IBAction)updateBalance:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setBalance:value];
    [balance setDoubleValue:value];
    [balanceSlider setDoubleValue:value];
}

- (IBAction)updateBreathiness:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setBreathiness:value];
    [breathiness setDoubleValue:value];
    [breathinessSlider setDoubleValue:value];
}

- (IBAction)updateLossFactor:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setLossFactor:value];
    [lossFactor setDoubleValue:value];
    [lossFactorSlider setDoubleValue:value];
}

- (IBAction)updatePitchMean:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setPitch:value];
    [pitchMean setDoubleValue:value];
    [pitchMeanSlider setDoubleValue:value];
}

- (IBAction)updateThroatCutoff:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setThroatCutoff:value];
    [throatCutoff setDoubleValue:value];
    [throatCutoffSlider setDoubleValue:value];
}

- (IBAction)updateThroatVolume:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setThroatVolume:value];
    [throatVolume setDoubleValue:value];
    [throatVolumeSlider setDoubleValue:value];
}

- (IBAction)updateAperatureScaling:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setApertureScaling:value];
    [apScale setDoubleValue:value];
    [apScaleSlider setDoubleValue:value];
}

- (IBAction)updateMouthCoef:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setMouthCoef:value];
    [mouthCoef setDoubleValue:value];
    [mouthCoefSlider setDoubleValue:value];
}

- (IBAction)updateNoseCoef:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setNoseCoef:value];
    [noseCoef setDoubleValue:value];
    [noseCoefSlider setDoubleValue:value];
}

- (IBAction)updateMixOffset:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setMixOffset:value];
    [mixOffset setDoubleValue:value];
    [mixOffsetSlider setDoubleValue:value];
}

- (IBAction)updateN1:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN1:value];
    [n1 setDoubleValue:value];
    [n1Slider setDoubleValue:value];
}

- (IBAction)updateN2:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN2:value];
    [n2 setDoubleValue:value];
    [n2Slider setDoubleValue:value];
}

- (IBAction)updateN3:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN3:value];
    [n3 setDoubleValue:value];
    [n3Slider setDoubleValue:value];
}

- (IBAction)updateN4:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN4:value];
    [n4 setDoubleValue:value];
    [n4Slider setDoubleValue:value];
}

- (IBAction)updateN5:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setN5:value];
    [n5 setDoubleValue:value];
    [n5Slider setDoubleValue:value];
}

- (IBAction)updateTp:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setTp:value];
    [tp setDoubleValue:value];
    [tpSlider setDoubleValue:value];
}

- (IBAction)updateTnMin:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setTnMin:value];
    [tnMin setDoubleValue:value];
    [tnMinSlider setDoubleValue:value];
}

- (IBAction)updateTnMax:(id)sender;
{
    double value = [sender doubleValue];
    [[[self model] synthesisParameters] setTnMax:value];
    [tnMax setDoubleValue:value];
    [tnMaxSlider setDoubleValue:value];
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
