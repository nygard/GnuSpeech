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
//  MonetDefaults.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSString.h>

// MDK: Monet Default Key
#define MDK_OWNER		@"MONET"
#define MDK_NUMBER		22

#define MDK_MASTER_VOLUME	@"MasterVolume"
#define MDK_VOCAL_TRACT_LENGTH	@"VocalTractLength"
#define MDK_TEMPERATURE		@"Temperature"
#define MDK_BALANCE		@"Balance"
#define MDK_BREATHINESS		@"Breathiness"
#define MDK_LOSS_FACTOR		@"LossFactor"

#define MDK_THROAT_CUTTOFF	@"ThroatCuttoff"
#define MDK_THROAT_VOLUME	@"ThroatVolume"
#define MDK_APERTURE_SCALING	@"ApertureScaling"
#define MDK_MOUTH_COEF		@"MouthCoef"
#define MDK_NOSE_COEF		@"NoseCoef"
#define MDK_MIX_OFFSET		@"MixOffset"

#define MDK_N1			@"N1"
#define MDK_N2			@"N2"
#define MDK_N3			@"N3"
#define MDK_N4			@"N4"
#define MDK_N5			@"N5"

#define MDK_TP			@"Tp"
#define MDK_TN_MIN		@"TnMin"
#define MDK_TN_MAX		@"TnMax"

#define MDK_GP_SHAPE		@"GpShape"
#define MDK_NOISE_MODULATION	@"NoiseModulation"

#define MDK_PITCH		@"Pitch"
#define MDK_SAMPLING_RATE	@"SamplingRate"
#define MDK_OUTPUT_CHANNELS	@"OutputChannels"

#define DEFAULT_MASTER_VOLUME		@"60"
#define DEFAULT_VOCAL_TRACT_LENGTH	@"17.5"
#define DEFAULT_TEMPERATURE		@"25"
#define DEFAULT_BALANCE			@"0"
#define DEFAULT_BREATHINESS		@"1"
#define DEFAULT_LOSS_FACTOR		@"0.5"
#define DEFAULT_THROAT_CUTTOFF		@"1500"
#define DEFAULT_THROAT_VOLUME		@"6"
#define DEFAULT_APERTURE_SCALING	@"3.05"
#define DEFAULT_MOUTH_COEF		@"5000"
#define DEFAULT_NOSE_COEF		@"5000"
#define DEFAULT_MIX_OFFSET		@"54"
#define DEFAULT_N1			@"1.35"
#define DEFAULT_N2			@"1.96"
#define DEFAULT_N3			@"1.91"
#define DEFAULT_N4			@"1.3"
#define DEFAULT_N5			@"0.73"
#define DEFAULT_TP			@"40"
#define DEFAULT_TN_MIN			@"16"
#define DEFAULT_TN_MAX			@"32"
#define DEFAULT_GP_SHAPE		@"Pulse"
#define DEFAULT_NOISE_MODULATION	@"YES"

#define DEFAULT_PITCH			@"-12"
#define DEFAULT_SAMPLING_RATE		@"22050"
#define DEFAULT_OUTPUT_CHANNELS		@"Mono"
