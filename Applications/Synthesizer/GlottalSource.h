////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Adam Fedor, David Hill
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
//  GlottalSource.h
//  Synthesizer
//
//  Created by Adam Fedor on 1/18/2003.
//
//  Version: 0.7.3
//
////////////////////////////////////////////////////////////////////////////////


/*  REVISION INFORMATION  *****************************************************

$Author: fedor $
$Date: 2003/01/18 05:04:50 $
$Revision: 1.2 $
$Source: /cvsroot/gnuspeech/gnuspeech/trillium/src/Synthesizer/GlottalSource.h,v $
$State: Exp $


$Log: GlottalSource.h,v $
Revision 1.2  2003/01/18 05:04:50  fedor
Port to OpenStep/GNUstep

Revision 1.1  2002/03/21 16:49:54  rao
Initial import.

 * Revision 1.1.1.1  1994/05/20  00:21:40  len
 * Initial archive of TRM interactive Synthesizer.
 *

******************************************************************************/

#import <AppKit/AppKit.h>
#import "Harmonics.h"
#import "Waveform.h"
#import "structs.h"
//#import "tube.c"


/*  GLOBAL DEFINES  **********************************************************/
#define WAVEFORMTYPE_GP   0
#define WAVEFORMTYPE_SINE 1


@interface GlottalSource:NSObject
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
-(void)handleSynthDefaultsReloaded;

- (void)awakeFromNib;
//- (void)displayAndSynthesizeIvars;

- (void)saveToStream:(NSArchiver *)typedStream;
//- (void)openFromStream:(NSArchiver *)typedStream;

- (void)breathinessEntered:sender;
- (void)breathinessSliderMoved:sender;

- (void)waveformTypeSwitchPushed:sender;

- (IBAction)glottalPulseParametersChanged:sender;
//- (void)riseTimeEntered:sender;
//- (void)fallTimeMinEntered:sender;
//- (void)fallTimeMaxEntered:sender;

- (void)frequencyEntered:sender;
- (void)pitchEntered:sender;
- (void)pitchSliderMoved:sender;
- (void)showAmplitudeSwitchPushed:sender;
- (void)harmonicsSwitchPushed:sender;
- (void)unitButtonPushed:sender;
- (void)volumeEntered:sender;
- (void)volumeSliderMoved:sender;

- (void)displayWaveformAndHarmonics;
- (int)glottalVolume;

- (void)windowWillMiniaturize:sender;

@end
