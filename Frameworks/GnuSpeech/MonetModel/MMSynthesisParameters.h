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
//  MMSynthesisParameters.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSObject.h>

typedef enum {
    MMGPShapePulse = 0,
    MMGPShapeSine = 1,
} MMGlottalPulseShape;

typedef enum {
    MMSamplingRate22050 = 0,
    MMSamplingRate44100 = 1,
} MMSamplingRate;

typedef enum {
    MMChannelsMono = 0,
    MMChannelsStereo = 1,
} MMChannels;

@interface MMSynthesisParameters : NSObject
{
    double masterVolume;
    double vocalTractLength;
    double temperature;
    double balance;
    double breathiness;
    double lossFactor;
    double pitch;

    double throatCutoff;
    double throatVolume;
    double apertureScaling;
    double mouthCoef;
    double noseCoef;
    double mixOffset;

    double n1;
    double n2;
    double n3;
    double n4;
    double n5;

    double tp;
    double tnMin;
    double tnMax;

    MMGlottalPulseShape glottalPulseShape;
    BOOL shouldUseNoiseModulation;

    MMSamplingRate samplingRate;
    MMChannels outputChannels;
}

+ (void)initialize;

+ (NSString *)stringForGlottalPulseShape:(MMGlottalPulseShape)aShape;
+ (MMGlottalPulseShape)glottalPulseShapeFromString:(NSString *)aString;

+ (NSString *)stringForSamplingRate:(MMSamplingRate)aRate;
+ (MMSamplingRate)samplingRateFromString:(NSString *)aString;
+ (double)samplingRate:(MMSamplingRate)aRate;

+ (NSString *)stringForChannels:(MMChannels)channels;
+ (MMChannels)channelsFromString:(NSString *)aString;

- (id)init;

- (void)restoreDefaultValues;
- (void)saveAsDefaults;

- (double)masterVolume;
- (void)setMasterVolume:(double)value;

- (double)vocalTractLength;
- (void)setVocalTractLength:(double)value;

- (double)temperature;
- (void)setTemperature:(double)value;

- (double)balance;
- (void)setBalance:(double)value;

- (double)breathiness;
- (void)setBreathiness:(double)value;

- (double)lossFactor;
- (void)setLossFactor:(double)value;

- (double)pitch;
- (void)setPitch:(double)value;

- (double)throatCutoff;
- (void)setThroatCutoff:(double)value;

- (double)throatVolume;
- (void)setThroatVolume:(double)value;

- (double)apertureScaling;
- (void)setApertureScaling:(double)value;

- (double)mouthCoef;
- (void)setMouthCoef:(double)value;

- (double)noseCoef;
- (void)setNoseCoef:(double)value;

- (double)mixOffset;
- (void)setMixOffset:(double)value;

- (double)n1;
- (void)setN1:(double)value;

- (double)n2;
- (void)setN2:(double)value;

- (double)n3;
- (void)setN3:(double)value;

- (double)n4;
- (void)setN4:(double)value;

- (double)n5;
- (void)setN5:(double)value;

- (double)tp;
- (void)setTp:(double)value;

- (double)tnMin;
- (void)setTnMin:(double)value;

- (double)tnMax;
- (void)setTnMax:(double)value;

- (MMGlottalPulseShape)glottalPulseShape;
- (void)setGlottalPulseShape:(MMGlottalPulseShape)value;

- (BOOL)shouldUseNoiseModulation;
- (void)setShouldUseNoiseModulation:(BOOL)value;

- (MMSamplingRate)samplingRate;
- (void)setSamplingRate:(MMSamplingRate)value;

- (MMChannels)outputChannels;
- (void)setOutputChannels:(MMChannels)value;

- (void)writeToFile:(NSString *)aFilename includeComments:(BOOL)shouldIncludeComments;

@end
