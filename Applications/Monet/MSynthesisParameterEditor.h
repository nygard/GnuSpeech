////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
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
//  MSynthesisParameterEditor.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.6
//
////////////////////////////////////////////////////////////////////////////////

#import "MWindowController.h"

@class NSTextField, NSSlider, NSMatrix, NSUndoManager;

@class MModel;
@class NSSlider;

@interface MSynthesisParameterEditor : MWindowController
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
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;
- (void)updateViews;

- (IBAction)revertToDefaults:(id)sender;
- (IBAction)saveAsDefaults:(id)sender;

- (IBAction)updateMasterVolume:(id)sender;
- (IBAction)updateTubeLength:(id)sender;
- (IBAction)updateTemperature:(id)sender;
- (IBAction)updateBalance:(id)sender;
- (IBAction)updateBreathiness:(id)sender;
- (IBAction)updateLossFactor:(id)sender;
- (IBAction)updatePitchMean:(id)sender;

- (IBAction)updateThroatCutoff:(id)sender;
- (IBAction)updateThroatVolume:(id)sender;
- (IBAction)updateAperatureScaling:(id)sender;
- (IBAction)updateMouthCoef:(id)sender;
- (IBAction)updateNoseCoef:(id)sender;
- (IBAction)updateMixOffset:(id)sender;

- (IBAction)updateN1:(id)sender;
- (IBAction)updateN2:(id)sender;
- (IBAction)updateN3:(id)sender;
- (IBAction)updateN4:(id)sender;
- (IBAction)updateN5:(id)sender;

- (IBAction)updateTp:(id)sender;
- (IBAction)updateTnMin:(id)sender;
- (IBAction)updateTnMax:(id)sender;

- (IBAction)updateGlottalPulseShape:(id)sender;
- (IBAction)updateNoiseModulation:(id)sender;
- (IBAction)updateSamplingRate:(id)sender;
- (IBAction)updateOutputChannels:(id)sender;

@end
