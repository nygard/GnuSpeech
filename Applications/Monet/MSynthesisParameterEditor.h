//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class MModel;

@interface MSynthesisParameterEditor : MWindowController

- (id)initWithModel:(MModel *)aModel;

@property (nonatomic, retain) MModel *model;

- (NSUndoManager *)undoManager;

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
