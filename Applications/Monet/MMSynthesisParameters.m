//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMSynthesisParameters.h"

#import <Foundation/Foundation.h>
#import "NSUserDefaults-Extensions.h"

#import "MonetDefaults.h"

#define MonetDefCount 25

static NSString *MonetDefVal[] = {
    DEFAULT_MASTER_VOLUME,
    DEFAULT_VOCAL_TRACT_LENGTH,
    DEFAULT_TEMPERATURE,
    DEFAULT_BALANCE,
    DEFAULT_BREATHINESS,
    DEFAULT_LOSS_FACTOR,
    DEFAULT_THROAT_CUTTOFF,
    DEFAULT_THROAT_VOLUME,
    DEFAULT_APERTURE_SCALING,
    DEFAULT_MOUTH_COEF,
    DEFAULT_NOSE_COEF,
    DEFAULT_MIX_OFFSET,
    DEFAULT_N1,
    DEFAULT_N2,
    DEFAULT_N3,
    DEFAULT_N4,
    DEFAULT_N5,
    DEFAULT_TP,
    DEFAULT_TN_MIN,
    DEFAULT_TN_MAX,
    DEFAULT_GP_SHAPE,
    DEFAULT_NOISE_MODULATION,
    DEFAULT_PITCH,
    DEFAULT_SAMPLING_RATE,
    DEFAULT_OUTPUT_CHANNELS,
    nil
};

static NSString *MonetDefKeys[] = {
    MDK_MASTER_VOLUME,
    MDK_VOCAL_TRACT_LENGTH,
    MDK_TEMPERATURE,
    MDK_BALANCE,
    MDK_BREATHINESS,
    MDK_LOSS_FACTOR,
    MDK_THROAT_CUTTOFF,
    MDK_THROAT_VOLUME,
    MDK_APERTURE_SCALING,
    MDK_MOUTH_COEF,
    MDK_NOSE_COEF,
    MDK_MIX_OFFSET,
    MDK_N1,
    MDK_N2,
    MDK_N3,
    MDK_N4,
    MDK_N5,
    MDK_TP,
    MDK_TN_MIN,
    MDK_TN_MAX,
    MDK_GP_SHAPE,
    MDK_NOISE_MODULATION,
    MDK_PITCH,
    MDK_SAMPLING_RATE,
    MDK_OUTPUT_CHANNELS,
    nil
};

@implementation MMSynthesisParameters

+ (void)initialize;
{
    NSDictionary *dict;

    dict = [NSDictionary dictionaryWithObjects:MonetDefVal forKeys:MonetDefKeys count:MonetDefCount];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

+ (NSString *)stringForGlottalPulseShape:(MMGlottalPulseShape)aShape;
{
    switch (aShape) {
      case MMGPShapePulse: return @"Pulse";
      case MMGPShapeSine: return @"Sine";
    }

    return nil;
}

+ (MMGlottalPulseShape)glottalPulseShapeFromString:(NSString *)aString;
{
    if ([aString isEqualToString:@"Pulse"])
        return MMGPShapePulse;
    if ([aString isEqualToString:@"Sine"])
        return MMGPShapeSine;

    [NSException raise:NSInvalidArgumentException format:@"Unknown glottal pulse shape: '%@'", aString];
    return MMGPShapePulse;
}

+ (NSString *)stringForSamplingRate:(MMSamplingRate)aRate;
{
    switch (aRate) {
      case MMSamplingRate22050: return @"22050";
      case MMSamplingRate44100: return @"44100";
    }

    return nil;
}

+ (MMSamplingRate)samplingRateFromString:(NSString *)aString;
{
    if ([aString isEqualToString:@"22050"])
        return MMSamplingRate22050;
    if ([aString isEqualToString:@"44100"])
        return MMSamplingRate44100;

    [NSException raise:NSInvalidArgumentException format:@"Unknown sampling rate: '%@'", aString];
    return MMSamplingRate22050;
}

+ (double)samplingRate:(MMSamplingRate)aRate;
{
    switch (aRate) {
      case MMSamplingRate22050: return 22050;
      case MMSamplingRate44100: return 44100;
    }

    [NSException raise:NSInvalidArgumentException format:@"Unknown sampling rate: %d", aRate];
    return 22050;
}

+ (NSString *)stringForChannels:(MMChannels)channels;
{
    switch (channels) {
      case MMChannelsMono: return @"Mono";
      case MMChannelsStereo: return @"Stereo";
    }

    return nil;
}

+ (MMChannels)channelsFromString:(NSString *)aString;
{
    if ([aString isEqualToString:@"Mono"])
        return MMChannelsMono;
    if ([aString isEqualToString:@"Stereo"])
        return MMChannelsStereo;

    [NSException raise:NSInvalidArgumentException format:@"Unknown channels: '%@'", aString];
    return MMChannelsMono;
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    [self restoreDefaultValues];

    return self;
}

- (void)restoreDefaultValues;
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];

    masterVolume = [defaults doubleForKey:MDK_MASTER_VOLUME];
    vocalTractLength = [defaults doubleForKey:MDK_VOCAL_TRACT_LENGTH];
    temperature = [defaults doubleForKey:MDK_TEMPERATURE];
    balance = [defaults doubleForKey:MDK_BALANCE];
    breathiness = [defaults doubleForKey:MDK_BREATHINESS];
    lossFactor = [defaults doubleForKey:MDK_LOSS_FACTOR];
    pitch = [defaults doubleForKey:MDK_PITCH];

    throatCutoff = [defaults doubleForKey:MDK_THROAT_CUTTOFF];
    throatVolume = [defaults doubleForKey:MDK_THROAT_VOLUME];
    apertureScaling = [defaults doubleForKey:MDK_APERTURE_SCALING];
    mouthCoef = [defaults doubleForKey:MDK_MOUTH_COEF];
    noseCoef = [defaults doubleForKey:MDK_NOSE_COEF];
    mixOffset = [defaults doubleForKey:MDK_MIX_OFFSET];

    n1 = [defaults doubleForKey:MDK_N1];
    n2 = [defaults doubleForKey:MDK_N2];
    n3 = [defaults doubleForKey:MDK_N3];
    n4 = [defaults doubleForKey:MDK_N4];
    n5 = [defaults doubleForKey:MDK_N5];

    tp = [defaults doubleForKey:MDK_TP];
    tnMin = [defaults doubleForKey:MDK_TN_MIN];
    tnMax = [defaults doubleForKey:MDK_TN_MAX];

    glottalPulseShape = [MMSynthesisParameters glottalPulseShapeFromString:[defaults stringForKey:MDK_GP_SHAPE]];
    shouldUseNoiseModulation = [defaults boolForKey:MDK_NOISE_MODULATION];

    samplingRate = [MMSynthesisParameters samplingRateFromString:[defaults stringForKey:MDK_SAMPLING_RATE]];
    outputChannels = [MMSynthesisParameters channelsFromString:[defaults stringForKey:MDK_OUTPUT_CHANNELS]];
}

- (void)saveAsDefaults;
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];

    [defaults setDouble:masterVolume forKey:MDK_MASTER_VOLUME];
    [defaults setDouble:vocalTractLength forKey:MDK_VOCAL_TRACT_LENGTH];
    [defaults setDouble:temperature forKey:MDK_TEMPERATURE];
    [defaults setDouble:balance forKey:MDK_BALANCE];
    [defaults setDouble:breathiness forKey:MDK_BREATHINESS];
    [defaults setDouble:lossFactor forKey:MDK_LOSS_FACTOR];
    [defaults setDouble:pitch forKey:MDK_PITCH];

    [defaults setDouble:throatCutoff forKey:MDK_THROAT_CUTTOFF];
    [defaults setDouble:throatVolume forKey:MDK_THROAT_VOLUME];
    [defaults setDouble:apertureScaling forKey:MDK_APERTURE_SCALING];
    [defaults setDouble:mouthCoef forKey:MDK_MOUTH_COEF];
    [defaults setDouble:noseCoef forKey:MDK_NOSE_COEF];
    [defaults setDouble:mixOffset forKey:MDK_MIX_OFFSET];

    [defaults setDouble:n1 forKey:MDK_N1];
    [defaults setDouble:n2 forKey:MDK_N2];
    [defaults setDouble:n3 forKey:MDK_N3];
    [defaults setDouble:n4 forKey:MDK_N4];
    [defaults setDouble:n5 forKey:MDK_N5];

    [defaults setDouble:tp forKey:MDK_TP];
    [defaults setDouble:tnMin forKey:MDK_TN_MIN];
    [defaults setDouble:tnMax forKey:MDK_TN_MAX];

    NSLog(@"%s, glottalPulseShape: %d, str: %@", _cmd, glottalPulseShape, [MMSynthesisParameters stringForGlottalPulseShape:glottalPulseShape]);
    [defaults setObject:[MMSynthesisParameters stringForGlottalPulseShape:glottalPulseShape] forKey:MDK_GP_SHAPE];
    [defaults setBool:shouldUseNoiseModulation forKey:MDK_NOISE_MODULATION];
    [defaults setObject:[MMSynthesisParameters stringForSamplingRate:samplingRate] forKey:MDK_SAMPLING_RATE];
    [defaults setObject:[MMSynthesisParameters stringForChannels:outputChannels] forKey:MDK_OUTPUT_CHANNELS];
}

- (double)masterVolume;
{
    return masterVolume;
}

- (void)setMasterVolume:(double)value;
{
    masterVolume = value;
}

- (double)vocalTractLength;
{
    return vocalTractLength;
}

- (void)setVocalTractLength:(double)value;
{
    vocalTractLength = value;
}

- (double)temperature;
{
    return temperature;
}

- (void)setTemperature:(double)value;
{
    temperature = value;
}

- (double)balance;
{
    return balance;
}

- (void)setBalance:(double)value;
{
    balance = value;
}

- (double)breathiness;
{
    return breathiness;
}

- (void)setBreathiness:(double)value;
{
    breathiness = value;
}

- (double)lossFactor;
{
    return lossFactor;
}

- (void)setLossFactor:(double)value;
{
    lossFactor = value;
}

- (double)pitch;
{
    return pitch;
}

- (void)setPitch:(double)value;
{
    pitch = value;
}

- (double)throatCutoff;
{
    return throatCutoff;
}

- (void)setThroatCutoff:(double)value;
{
    throatCutoff = value;
}

- (double)throatVolume;
{
    return throatVolume;
}

- (void)setThroatVolume:(double)value;
{
    throatVolume = value;
}

- (double)apertureScaling;
{
    return apertureScaling;
}

- (void)setApertureScaling:(double)value;
{
    apertureScaling = value;
}

- (double)mouthCoef;
{
    return mouthCoef;
}

- (void)setMouthCoef:(double)value;
{
    mouthCoef = value;
}

- (double)noseCoef;
{
    return noseCoef;
}

- (void)setNoseCoef:(double)value;
{
    noseCoef = value;
}

- (double)mixOffset;
{
    return mixOffset;
}

- (void)setMixOffset:(double)value;
{
    mixOffset = value;
}

- (double)n1;
{
    return n1;
}

- (void)setN1:(double)value;
{
    n1 = value;
}

- (double)n2;
{
    return n2;
}

- (void)setN2:(double)value;
{
    n2 = value;
}

- (double)n3;
{
    return n3;
}

- (void)setN3:(double)value;
{
    n3 = value;
}

- (double)n4;
{
    return n4;
}

- (void)setN4:(double)value;
{
    n4 = value;
}

- (double)n5;
{
    return n5;
}

- (void)setN5:(double)value;
{
    n5 = value;
}

- (double)tp;
{
    return tp;
}

- (void)setTp:(double)value;
{
    tp = value;
}

- (double)tnMin;
{
    return tnMin;
}

- (void)setTnMin:(double)value;
{
    tnMin = value;
}

- (double)tnMax;
{
    return tnMax;
}

- (void)setTnMax:(double)value;
{
    tnMax = value;
}

- (MMGlottalPulseShape)glottalPulseShape;
{
    return glottalPulseShape;
}

- (void)setGlottalPulseShape:(MMGlottalPulseShape)value;
{
    glottalPulseShape = value;
}

- (BOOL)shouldUseNoiseModulation;
{
    return shouldUseNoiseModulation;
}

- (void)setShouldUseNoiseModulation:(BOOL)value;
{
    shouldUseNoiseModulation = value;
}

- (MMSamplingRate)samplingRate;
{
    return samplingRate;
}

- (void)setSamplingRate:(MMSamplingRate)value;
{
    samplingRate = value;
}

- (MMChannels)outputChannels;
{
    return outputChannels;
}

- (void)setOutputChannels:(MMChannels)value;
{
    outputChannels = value;
}

@end
