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
//  Controller.h
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.3
//
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import <CoreAudio/AudioHardware.h>
#import "structs.h"
#import "TubeSection.h"
#import "FricativeArrow.h"
#import "Analysis.h"
#import <pthread.h>

#define MAX_REAL_DIAMETER 4

#define MAX_TUBE_LENGTH 20.0
#define MIN_TUBE_LENGTH 10.0
#define LENGTH_DEF			17.5

#define MAX_TEMP 40.0
#define MIN_TEMP 25.0


// DEFAULT SETTINGS OF SYNTHESISER PARAMETERS

#define VARIABLE_GP			1

//#define TEMPERATURE_DEF		32.0
#define BALANCE_DEF			0
#define BREATHINESS_DEF		2.5
#define LOSSFACTOR_DEF		2.0
#define RISETIME_DEF		40.0
#define FALLTIMEMIN_DEF		12.0
#define FALLTIMEMAX_DEF		35.0
#define THROATCUTOFF_DEF	1500
#define THROATVOLUME_DEF	12
#define APSCALE_DEF			6.01
#define MOUTHCOEF_DEF		4000.0
#define NOSECOEF_DEF		5000.0
#define MIXOFFSET_DEF		48.0
#define GLOTVOL_DEF			60.0
#define GLOTPITCH_DEF		0

#define ASPVOL_DEF			0
#define ASP_VOL_MAX			60

#define FRIC_CF_MIN			100
#define FRIC_CF_DEF			6000
#define FRIC_BW_MIN			250
#define FRIC_BW_DEF			1000

#define FRIC_VOL_MIN		0
#define FRIC_VOL_MAX		60
#define FRIC_VOL_DEF		0

#define FRIC_POS_MIN		0.0
#define FRIC_POS_MAX		7.0
#define FRIC_POS_DEF		7.0

#define VOLUME_MIN			0
#define VOLUME_MAX			60


@class TubeSection, VelumSlider;


@interface Controller : NSObject
{
	id analysis;
    IBOutlet NSWindow *_mainWindow;
    IBOutlet NSTextField *toneFrequencyTextField;
    IBOutlet NSSlider *toneFrequencySlider;

    UInt32 _bufferSize;
    AudioDeviceID _device;
    AudioStreamBasicDescription	_format;
    float toneFrequency;
	
    BOOL _deviceReady;
    //BOOL _isPlaying;
	
	IBOutlet NSMatrix	*testSwitch;
	
	IBOutlet NSTextField *tubeLengthField;
	IBOutlet NSTextField *actualLengthField;
	IBOutlet NSTextField *sampleRateField;
	IBOutlet NSTextField *controlPeriodField;
	IBOutlet NSTextField *temperatureField;
	IBOutlet NSTextField *stereoBalanceField;
	IBOutlet NSTextField *breathinessField;
	IBOutlet NSTextField *lossFactorField;
	IBOutlet NSFormCell *tpField;
	IBOutlet NSFormCell *tnMinField;
	IBOutlet NSFormCell *tnMaxField;
	IBOutlet NSMatrix *harmonicsSwitch;
	IBOutlet NSTextField *throatCutOff;
	IBOutlet NSTextField *throatVolumeField;
	IBOutlet NSTextField *apertureScalingField;
	IBOutlet NSTextField *mouthCoefField;
	IBOutlet NSTextField *noseCoefField;
	IBOutlet NSTextField *mixOffsetField;
	IBOutlet NSTextField *glottalVolumeField;
	IBOutlet NSTextField *pitchField;
	IBOutlet NSTextField *aspVolField;
	IBOutlet NSTextField *fricVolField;
	IBOutlet NSTextField *fricPosField;
	IBOutlet NSTextField *fricCFField;
	IBOutlet NSTextField *fricBWField;	
	IBOutlet TubeSection *rS1;
	IBOutlet TubeSection *rS2;
	IBOutlet TubeSection *rS3;
	IBOutlet TubeSection *rS4;
	IBOutlet TubeSection *rS5;
	IBOutlet TubeSection *rS6;
	IBOutlet TubeSection *rS7;
	IBOutlet TubeSection *rS8;
	IBOutlet VelumSlider *vS;
	IBOutlet NSSlider *tubeLengthSlider;
	IBOutlet NSSlider *temperatureSlider;
	IBOutlet NSSlider *stereoBalanceSlider;
	IBOutlet NSSlider *breathinessSlider;
	IBOutlet NSSlider *lossFactorSlider;
	IBOutlet NSSlider *tpSlider;
	IBOutlet NSSlider *tnMinSlider;
	IBOutlet NSSlider *tnMaxSlider;
	IBOutlet NSSlider *throatCutOffSlider;
	IBOutlet NSSlider *throatVolumeSlider;
	IBOutlet NSSlider *apertureScalingSlider;
	IBOutlet NSSlider *mouthCoefSlider;
	IBOutlet NSSlider *noseCoefSlider;
	IBOutlet NSSlider *mixOffsetSlider;
	IBOutlet TubeSection *nS1;
	IBOutlet TubeSection *nS2;
	IBOutlet TubeSection *nS3;
	IBOutlet TubeSection *nS4;
	IBOutlet TubeSection *nS5;
	IBOutlet NSSlider *glottalVolumeSlider;
	IBOutlet NSSlider *pitchSlider;
	IBOutlet NSSlider *aspVolSlider;
	IBOutlet NSSlider *fricVolSlider;
	IBOutlet NSSlider *fricPosSlider;
	IBOutlet NSSlider *fricCFSlider;
	IBOutlet NSSlider *fricBWSlider;
	IBOutlet FricativeArrow *fricativeArrow;
	
	IBOutlet NSButton *runStopButton;
	
}

- (id)init;
- (void)awakeFromNib;

- (float)toneFrequency;
- (void)setToneFrequency:(float)newValue;
- (void)sliderMoved:(NSNotification *)originator;

- (IBAction)updateToneFrequency:(id)sender;

- (IBAction)playSine:(id)sender;
- (IBAction)stopPlaying:(id)sender;

//- (IBAction)loadParameterFile:(id)sender;
- (IBAction)saveOutputFile:(id)sender;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)setupSoundDevice;
- (void)setDefaults;

- (UInt32)bufferSize;
- (double)sRate; //- (double)sampleRate;

- (void)setDirtyBit;

- (IBAction)runButtonPushed:(id)sender;
- (IBAction)loadDefaultsButtonPushed:(id)sender;
- (IBAction)saveToDefaultsButtonPushed:(id)sender;
- (IBAction)loadFileButtonPushed:(id)sender;
- (IBAction)glottalWaveformSelected:(id)sender;
- (IBAction)noisePulseModulationSelected:(id)sender;
- (IBAction)samplingRateSelected:(id)sender;
- (IBAction)monoStereoSelected:(id)sender;
//- (IBAction)tpFieldEntered:(id)sender;
//- (IBAction)tnMinFieldEntered:(id)sender;
//- (IBAction)tnMaxFieldEntered:(id)sender;
- (IBAction)tubeLengthFieldEntered:(id)sender;
- (IBAction)temperatureFieldEntered:(id)sender;
- (IBAction)stereoBalanceFieldEntered:(id)sender;
- (IBAction)breathinessFieldEntered:(id)sender;
- (IBAction)lossFactorFieldEntered:(id)sender;
- (IBAction)throatCutoffFieldEntered:(id)sender;
- (IBAction)throatVolumeFieldEntered:(id)sender;
- (IBAction)apertureScalingFieldEntered:(id)sender;
- (IBAction)mouthApertureCoefficientFieldEntered:(id)sender;
- (IBAction)noseApertureCoefficientFieldEntered:(id)sender;
- (IBAction)mixOffsetFieldEntered:(id)sender;
- (IBAction)n1RadiusFieldEntered:(id)sender;
- (IBAction)n2RadiusFieldEntered:(id)sender;
- (IBAction)n3RadiusFieldEntered:(id)sender;
- (IBAction)n4RadiusFieldEntered:(id)sender;
- (IBAction)n5RadiusFieldEntered:(id)sender;
- (IBAction)glottalVolumeFieldEntered:(id)sender;
- (IBAction)pitchFieldEntered:(id)sender;
- (IBAction)aspVolFieldEntered:(id)sender;
- (IBAction)fricVolFieldEntered:(id)sender;
- (IBAction)fricPosFieldEntered:(id)sender;
- (IBAction)fricCFFieldEntered:(id)sender;
- (IBAction)fricBWFieldEntered:(id)sender;	

- (IBAction)r1RadiusFieldEntered:(id)sender;
- (IBAction)r2RadiusFieldEntered:(id)sender;
- (IBAction)r3RadiusFieldEntered:(id)sender;
- (IBAction)r4RadiusFieldEntered:(id)sender;
- (IBAction)r5RadiusFieldEntered:(id)sender;
- (IBAction)r6RadiusFieldEntered:(id)sender;
- (IBAction)r7RadiusFieldEntered:(id)sender;
- (IBAction)r8RadiusFieldEntered:(id)sender;
- (IBAction)vRadiusFieldEntered:(id)sender;

//- (IBAction)tpSliderMoved:(id)sender;
//- (IBAction)tnMinSliderMoved:(id)sender;
//- (IBAction)tnMaxSliderMoved:(id)sender;
- (IBAction)tubeLengthSliderMoved:(id)sender;
- (IBAction)temperatureSliderMoved:(id)sender;
- (IBAction)stereoBalanceSliderMoved:(id)sender;
- (IBAction)breathinessSliderMoved:(id)sender;
- (IBAction)lossFactorSliderMoved:(id)sender;
- (IBAction)throatCutoffSliderMoved:(id)sender;
- (IBAction)throatVolumeSliderMoved:(id)sender;
- (IBAction)apertureScalingSliderMoved:(id)sender;
- (IBAction)mouthApertureCoefficientSliderMoved:(id)sender;
- (IBAction)noseApertureCoefficientSliderMoved:(id)sender;
- (IBAction)mixOffsetSliderMoved:(id)sender;
- (IBAction)n1RadiusSliderMoved:(id)sender;
- (IBAction)n2RadiusSliderMoved:(id)sender;
- (IBAction)n3RadiusSliderMoved:(id)sender;
- (IBAction)n4RadiusSliderMoved:(id)sender;
- (IBAction)n5RadiusSliderMoved:(id)sender;
- (IBAction)glottalVolumeSliderMoved:(id)sender;
// - (IBAction)pitchSliderMoved:(id)sender;
- (IBAction)aspVolSliderMoved:(id)sender;
- (IBAction)fricVolSliderMoved:(id)sender;
- (IBAction)fricPosSliderMoved:(id)sender;
- (IBAction)fricCFSliderMoved:(id)sender;
- (IBAction)fricBWSliderMoved:(id)sender;	
- (IBAction)r1RadiusSliderMoved:(id)sender;
- (IBAction)r2RadiusSliderMoved:(id)sender;
- (IBAction)r3RadiusSliderMoved:(id)sender;
- (IBAction)r4RadiusSliderMoved:(id)sender;
- (IBAction)r5RadiusSliderMoved:(id)sender;
- (IBAction)r6RadiusSliderMoved:(id)sender;
- (IBAction)r7RadiusSliderMoved:(id)sender;
- (IBAction)r8RadiusSliderMoved:(id)sender;
- (IBAction)vSliderMoved:(id)sender;

/*  Methods to set the interface widgets  */

- (void)runButtonPushed:(id)sender;
- (void)loadDefaultsButtonPushed:(id)sender;
- (void)saveToDefaultsButtonPushed:(id)sender;
- (void)loadFileButtonPushed:(id)sender;
- (void)glottalWaveformSelected:(id)sender;
- (void)noisePulseModulationSelected:(id)sender;
- (void)samplingRateSelected:(id)sender;
- (void)monoStereoSelected:(id)sender;
//- (void)tpFieldEntered:(id)sender;
//- (void)tnMinFieldEntered:(id)sender;
//- (void)tnMaxFieldEntered:(id)sender;
- (void)tubeLengthFieldEntered:(id)sender;
- (void)temperatureFieldEntered:(id)sender;
- (void)stereoBalanceFieldEntered:(id)sender;
- (void)breathinessFieldEntered:(id)sender;
- (void)lossFactorFieldEntered:(id)sender;
- (void)throatCutoffFieldEntered:(id)sender;
- (void)throatVolumeFieldEntered:(id)sender;
- (void)apertureScalingFieldEntered:(id)sender;
- (void)mouthApertureCoefficientFieldEntered:(id)sender;
- (void)noseApertureCoefficientFieldEntered:(id)sender;
- (void)mixOffsetFieldEntered:(id)sender;
- (void)n1RadiusFieldEntered:(id)sender;
- (void)n2RadiusFieldEntered:(id)sender;
- (void)n3RadiusFieldEntered:(id)sender;
- (void)n4RadiusFieldEntered:(id)sender;
- (void)n5RadiusFieldEntered:(id)sender;
- (void)glottalVolumeFieldEntered:(id)sender;
- (void)pitchFieldEntered:(id)sender;
- (void)aspVolFieldEntered:(id)sender;
- (void)fricVolFieldEntered:(id)sender;
- (void)fricPosFieldEntered:(id)sender;
- (void)fricCFFieldEntered:(id)sender;
- (IBAction)fricBWFieldEntered:(id)sender;

- (void)injectFricationAt:(float)position;

- (void)r1RadiusFieldEntered:(id)sender;
- (void)r2RadiusFieldEntered:(id)sender;
- (void)r3RadiusFieldEntered:(id)sender;
- (void)r4RadiusFieldEntered:(id)sender;
- (void)r5RadiusFieldEntered:(id)sender;
- (void)r6RadiusFieldEntered:(id)sender;
- (void)r7RadiusFieldEntered:(id)sender;
- (void)r8RadiusFieldEntered:(id)sender;
- (void)vRadiusFieldEntered:(id)sender;

//- (void)tpSliderMoved:(id)sender;
//- (void)tnMinSliderMoved:(id)sender;
//- (void)tnMaxSliderMoved:(id)sender;
- (void)tubeLengthSliderMoved:(id)sender;
- (void)temperatureSliderMoved:(id)sender;
- (void)stereoBalanceSliderMoved:(id)sender;
- (void)breathinessSliderMoved:(id)sender;
- (void)lossFactorSliderMoved:(id)sender;
- (void)throatCutoffSliderMoved:(id)sender;
- (void)throatVolumeSliderMoved:(id)sender;
- (void)apertureScalingSliderMoved:(id)sender;
- (void)mouthApertureCoefficientSliderMoved:(id)sender;
- (void)noseApertureCoefficientSliderMoved:(id)sender;
- (void)mixOffsetSliderMoved:(id)sender;
- (void)n2RadiusSliderMoved:(id)sender;
- (void)n3RadiusSliderMoved:(id)sender;
- (void)n4RadiusSliderMoved:(id)sender;
- (void)n5RadiusSliderMoved:(id)sender;
- (void)glottalVolumeSliderMoved:(id)sender;
//- (void)pitchSliderMoved:(id)sender;
- (void)aspVolSliderMoved:(id)sender;
- (void)fricVolSliderMoved:(id)sender;
- (void)fricPosSliderMoved:(id)sender;
- (void)fricCFSliderMoved:(id)sender;
- (void)fricBWSliderMoved:(id)sender;	
- (void)r1RadiusSliderMoved:(id)sender;
- (void)r2RadiusSliderMoved:(id)sender;
- (void)r3RadiusSliderMoved:(id)sender;
- (void)r4RadiusSliderMoved:(id)sender;
- (void)r5RadiusSliderMoved:(id)sender;
- (void)r6RadiusSliderMoved:(id)sender;
- (void)r7RadiusSliderMoved:(id)sender;
- (void)r8RadiusSliderMoved:(id)sender;
- (void)vSliderMoved:(id)sender;

- (void)handleFricArrowMoved:(NSNotification *)note;

/*  METHODS FOR LINKING OBJECTIVE-C CODE TO C MODULES  */

- (void)csetGlotPitch:(float) value;
- (void)csetGlotVol:(float) value;
- (void)csetAspVol:(float) value;
- (void)csetFricVol:(float) value;
- (void)csetfricPos:(float) value;
- (void)csetFricCF:(float) value;
- (void)csetFricBW:(float) value;
- (void)csetRadius:(float) value: (int) index;
- (void)csetVelum:(float) value;
- (void)csetVolume:(double) value;
- (void)csetWaveform:(int) value;
- (void)csetTp:(double) value;
- (void)csetTnMin:(double) value;
- (void)csetTnMax:(double) value;
- (void)csetBreathiness:(double) value;
- (void)csetLength:(double) value;
- (void)csetTemperature:(double) value;
- (void)csetLossFactor:(double) value;
- (void)csetApScale:(double) value;
- (void)csetMouthCoef:(double) value;
- (void)csetNoseCoef:(double) value;
- (void)csetNoseRadius:(double) value: (int) index;
- (void)csetThroatCoef:(double) value;
- (void)csetModulation:(int) value;
- (void)csetMixOffset:(double) value;
- (void)csetThroatCutoff:(double) value;
- (void)csetThroatVolume:(double) value;

- (void)setTitle:(NSString *)path;
- (void)adjustSampleRate;
- (void)adjustToNewSampleRate;
- (void)calculateSampleRate;
- (BOOL)tubeRunState;



@end
