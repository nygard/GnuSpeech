//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMSynthesisParameters.h"

// MDK: Monet Default Key
#define MDK_OWNER		            @"MONET"

#define MDK_MASTER_VOLUME	        @"MasterVolume"
#define MDK_VOCAL_TRACT_LENGTH	    @"VocalTractLength"
#define MDK_TEMPERATURE		        @"Temperature"
#define MDK_BALANCE		            @"Balance"
#define MDK_BREATHINESS	      	    @"Breathiness"
#define MDK_LOSS_FACTOR		        @"LossFactor"

#define MDK_THROAT_CUTTOFF	        @"ThroatCuttoff"
#define MDK_THROAT_VOLUME	        @"ThroatVolume"
#define MDK_APERTURE_SCALING	    @"ApertureScaling"
#define MDK_MOUTH_COEF		        @"MouthCoef"
#define MDK_NOSE_COEF		        @"NoseCoef"
#define MDK_MIX_OFFSET		        @"MixOffset"

#define MDK_N1			            @"N1"
#define MDK_N2			            @"N2"
#define MDK_N3			            @"N3"
#define MDK_N4			            @"N4"
#define MDK_N5			            @"N5"

#define MDK_TP		                @"Tp"
#define MDK_TN_MIN		            @"TnMin"
#define MDK_TN_MAX		            @"TnMax"

#define MDK_GP_SHAPE		        @"GpShape"
#define MDK_NOISE_MODULATION	    @"NoiseModulation"

#define MDK_PITCH		            @"Pitch"
#define MDK_SAMPLING_RATE	        @"SamplingRate"
#define MDK_OUTPUT_CHANNELS	        @"OutputChannels"

NSString *MMGlottalPulseShapeName(MMGlottalPulseShape shape);
MMGlottalPulseShape MMGlottalPulseShapeFromString(NSString *string);

NSString *MMSamplingRateName(MMSamplingRate rate);
MMSamplingRate MMSamplingRateFromString(NSString *string);
double MMSampleRate(MMSamplingRate rate);

NSString *MMChannelsName(MMChannels channels);
MMChannels MMChannelsFromString(NSString *string);

NSString *MMGlottalPulseShapeName(MMGlottalPulseShape shape)
{
    switch (shape) {
        case MMGlottalPulseShape_Pulse: return @"Pulse";
        case MMGlottalPulseShape_Sine:  return @"Sine";
    }
    
    return nil;
}

MMGlottalPulseShape MMGlottalPulseShapeFromString(NSString *string)
{
    if ([string isEqualToString:@"Pulse"]) return MMGlottalPulseShape_Pulse;
    if ([string isEqualToString:@"Sine"])  return MMGlottalPulseShape_Sine;
    
    [NSException raise:NSInvalidArgumentException format:@"Unknown glottal pulse shape: '%@'", string];
    return MMGlottalPulseShape_Pulse;
}

NSString *MMSamplingRateName(MMSamplingRate rate)
{
    switch (rate) {
        case MMSamplingRate_22050: return @"22050";
        case MMSamplingRate_44100: return @"44100";
    }
    
    return nil;
}

MMSamplingRate MMSamplingRateFromString(NSString *string)
{
    if ([string isEqualToString:@"22050"]) return MMSamplingRate_22050;
    if ([string isEqualToString:@"44100"]) return MMSamplingRate_44100;
    
    [NSException raise:NSInvalidArgumentException format:@"Unknown sampling rate: '%@'", string];
    return MMSamplingRate_22050;
}

double MMSampleRate(MMSamplingRate rate)
{
    switch (rate) {
        case MMSamplingRate_22050: return 22050;
        case MMSamplingRate_44100: return 44100;
    }
    
    [NSException raise:NSInvalidArgumentException format:@"Unknown sampling rate: %lu", rate];
    return 22050;
}

NSString *MMChannelsName(MMChannels channels)
{
    switch (channels) {
        case MMChannels_Mono:   return @"Mono";
        case MMChannels_Stereo: return @"Stereo";
    }
    
    return nil;
}

MMChannels MMChannelsFromString(NSString *string)
{
    if ([string isEqualToString:@"Mono"])   return MMChannels_Mono;
    if ([string isEqualToString:@"Stereo"]) return MMChannels_Stereo;
    
    [NSException raise:NSInvalidArgumentException format:@"Unknown channels: '%@'", string];
    return MMChannels_Mono;
}

@interface MMSynthesisParameters ()

@end

#pragma mark -

@implementation MMSynthesisParameters
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
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithDouble:60],                     MDK_MASTER_VOLUME,
                          [NSNumber numberWithDouble:17.5],                   MDK_VOCAL_TRACT_LENGTH,
                          [NSNumber numberWithDouble:25],                     MDK_TEMPERATURE,
                          [NSNumber numberWithDouble:0],                      MDK_BALANCE,
                          [NSNumber numberWithDouble:1],                      MDK_BREATHINESS,
                          [NSNumber numberWithDouble:0.5],                    MDK_LOSS_FACTOR,
                          [NSNumber numberWithDouble:1500],                   MDK_THROAT_CUTTOFF,
                          [NSNumber numberWithDouble:6],                      MDK_THROAT_VOLUME,
                          [NSNumber numberWithDouble:3.05],                   MDK_APERTURE_SCALING,
                          [NSNumber numberWithDouble:5000],                   MDK_MOUTH_COEF,
                          [NSNumber numberWithDouble:5000],                   MDK_NOSE_COEF,
                          [NSNumber numberWithDouble:54],                     MDK_MIX_OFFSET,
                          [NSNumber numberWithDouble:1.35],                   MDK_N1,
                          [NSNumber numberWithDouble:1.96],                   MDK_N2,
                          [NSNumber numberWithDouble:1.91],                   MDK_N3,
                          [NSNumber numberWithDouble:1.3],                    MDK_N4,
                          [NSNumber numberWithDouble:0.73],                   MDK_N5,
                          [NSNumber numberWithDouble:40],                     MDK_TP,
                          [NSNumber numberWithDouble:16],                     MDK_TN_MIN,
                          [NSNumber numberWithDouble:32],                     MDK_TN_MAX,
                          MMGlottalPulseShapeName(MMGlottalPulseShape_Pulse), MDK_GP_SHAPE,
                          [NSNumber numberWithBool:YES],                      MDK_NOISE_MODULATION,
                          [NSNumber numberWithDouble:-12],                    MDK_PITCH,
                          [NSNumber numberWithDouble:22050],                  MDK_SAMPLING_RATE,
                          MMChannelsName(MMChannels_Mono),                    MDK_OUTPUT_CHANNELS,
                          nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

- (id)init;
{
    if ((self = [super init])) {
        [self restoreDefaultValues];
    }

    return self;
}

- (void)restoreDefaultValues;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    masterVolume     = [defaults doubleForKey:MDK_MASTER_VOLUME];
    vocalTractLength = [defaults doubleForKey:MDK_VOCAL_TRACT_LENGTH];
    temperature      = [defaults doubleForKey:MDK_TEMPERATURE];
    balance          = [defaults doubleForKey:MDK_BALANCE];
    breathiness      = [defaults doubleForKey:MDK_BREATHINESS];
    lossFactor       = [defaults doubleForKey:MDK_LOSS_FACTOR];
    pitch            = [defaults doubleForKey:MDK_PITCH];

    throatCutoff     = [defaults doubleForKey:MDK_THROAT_CUTTOFF];
    throatVolume     = [defaults doubleForKey:MDK_THROAT_VOLUME];
    apertureScaling  = [defaults doubleForKey:MDK_APERTURE_SCALING];
    mouthCoef        = [defaults doubleForKey:MDK_MOUTH_COEF];
    noseCoef         = [defaults doubleForKey:MDK_NOSE_COEF];
    mixOffset        = [defaults doubleForKey:MDK_MIX_OFFSET];

    n1 = [defaults doubleForKey:MDK_N1];
    n2 = [defaults doubleForKey:MDK_N2];
    n3 = [defaults doubleForKey:MDK_N3];
    n4 = [defaults doubleForKey:MDK_N4];
    n5 = [defaults doubleForKey:MDK_N5];

    tp    = [defaults doubleForKey:MDK_TP];
    tnMin = [defaults doubleForKey:MDK_TN_MIN];
    tnMax = [defaults doubleForKey:MDK_TN_MAX];

    glottalPulseShape        = MMGlottalPulseShapeFromString([defaults stringForKey:MDK_GP_SHAPE]);
    shouldUseNoiseModulation = [defaults boolForKey:MDK_NOISE_MODULATION];

    samplingRate   = MMSamplingRateFromString([defaults stringForKey:MDK_SAMPLING_RATE]);
    outputChannels = MMChannelsFromString([defaults stringForKey:MDK_OUTPUT_CHANNELS]);
}

- (void)saveAsDefaults;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setDouble:masterVolume     forKey:MDK_MASTER_VOLUME];
    [defaults setDouble:vocalTractLength forKey:MDK_VOCAL_TRACT_LENGTH];
    [defaults setDouble:temperature      forKey:MDK_TEMPERATURE];
    [defaults setDouble:balance          forKey:MDK_BALANCE];
    [defaults setDouble:breathiness      forKey:MDK_BREATHINESS];
    [defaults setDouble:lossFactor       forKey:MDK_LOSS_FACTOR];
    [defaults setDouble:pitch            forKey:MDK_PITCH];

    [defaults setDouble:throatCutoff    forKey:MDK_THROAT_CUTTOFF];
    [defaults setDouble:throatVolume    forKey:MDK_THROAT_VOLUME];
    [defaults setDouble:apertureScaling forKey:MDK_APERTURE_SCALING];
    [defaults setDouble:mouthCoef       forKey:MDK_MOUTH_COEF];
    [defaults setDouble:noseCoef        forKey:MDK_NOSE_COEF];
    [defaults setDouble:mixOffset       forKey:MDK_MIX_OFFSET];

    [defaults setDouble:n1 forKey:MDK_N1];
    [defaults setDouble:n2 forKey:MDK_N2];
    [defaults setDouble:n3 forKey:MDK_N3];
    [defaults setDouble:n4 forKey:MDK_N4];
    [defaults setDouble:n5 forKey:MDK_N5];

    [defaults setDouble:tp    forKey:MDK_TP];
    [defaults setDouble:tnMin forKey:MDK_TN_MIN];
    [defaults setDouble:tnMax forKey:MDK_TN_MAX];

    [defaults setObject:MMGlottalPulseShapeName(glottalPulseShape) forKey:MDK_GP_SHAPE];
    [defaults setBool:shouldUseNoiseModulation                     forKey:MDK_NOISE_MODULATION];
    [defaults setObject:MMSamplingRateName(samplingRate)           forKey:MDK_SAMPLING_RATE];
    [defaults setObject:MMChannelsName(outputChannels)             forKey:MDK_OUTPUT_CHANNELS];
}

@synthesize masterVolume, vocalTractLength, temperature, balance, breathiness, lossFactor, pitch, throatCutoff, throatVolume, apertureScaling, mouthCoef, noseCoef, mixOffset, n1, n2, n3, n4, n5, tp, tnMin, tnMax, glottalPulseShape, shouldUseNoiseModulation, samplingRate, outputChannels;

- (double)sampleRate;
{
    return MMSampleRate(self.samplingRate);
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)error;
{
    NSMutableString *str = [NSMutableString string];
    
    [str appendFormat:@"%u\t\t; %@\n",  0,                        @"output file format (0 = AU, 1 = AIFF, 2 = WAVE)"];
    [str appendFormat:@"%g\t; %@\n",    self.sampleRate,          @"output sample rate (22050.0, 44100.0)"];
    [str appendFormat:@"%u\t\t; %@\n",  250,                      @"input control rate (1 - 1000 Hz)"];
    [str appendFormat:@"%f\t; %@\n",    masterVolume,             @"master volume (0 - 60 dB)"];
    [str appendFormat:@"%lu\t\t; %@\n", outputChannels + 1,       @"number of sound output channels (1 or 2)"];
    [str appendFormat:@"%f\t; %@\n",    balance,                  @"stereo balance (-1 to +1)"];
    [str appendFormat:@"%lu\t\t; %@\n", glottalPulseShape,        @"glottal source waveform type (0 = pulse, 1 = sine)"];
    [str appendFormat:@"%f\t; %@\n",    tp,                       @"glottal pulse rise time (5 - 50 % of GP period)"];
    [str appendFormat:@"%f\t; %@\n",    tnMin,                    @"glottal pulse fall time minimum (5 - 50 % of GP period)"];
    [str appendFormat:@"%f\t; %@\n",    tnMax,                    @"glottal pulse fall time maximum (5 - 50 % of GP period)"];
    [str appendFormat:@"%f\t; %@\n",    breathiness,              @"glottal source breathiness (0 - 10 % of GS amplitude)"];
    [str appendFormat:@"%f\t; %@\n",    vocalTractLength,         @"nominal tube length (10 - 20 cm)"];
    [str appendFormat:@"%f\t; %@\n",    temperature,              @"tube temperature (25 - 40 degrees celsius)"];
    [str appendFormat:@"%f\t; %@\n",    lossFactor,               @"junction loss factor (0 - 5 % of unity gain)"];
    [str appendFormat:@"%f\t; %@\n",    apertureScaling,          @"aperture scaling radius (3.05 - 12 cm)"];
    [str appendFormat:@"%f\t; %@\n",    mouthCoef,                @"mouth aperture coefficient (0 - 0.99)"];
    [str appendFormat:@"%f\t; %@\n",    noseCoef,                 @"nose aperture coefficient (0 - 0.99)"];
    [str appendFormat:@"%f\t; %@\n",    n1,                       @"radius of nose section 1 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    n2,                       @"radius of nose section 2 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    n3,                       @"radius of nose section 3 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    n4,                       @"radius of nose section 4 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    n5,                       @"radius of nose section 5 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    throatCutoff,             @"throat lowpass frequency cutoff (50 - nyquist Hz)"];
    [str appendFormat:@"%f\t; %@\n",    throatVolume,             @"throat volume (0 - 48 dB)"];
    [str appendFormat:@"%d\t\t; %@\n",  shouldUseNoiseModulation, @"pulse modulation of noise (0 = off, 1 = on)"];
    [str appendFormat:@"%f\t; %@\n",    mixOffset,                @"noise crossmix offset (30 - 60 db)"];
    
    return [str writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:error];
}

@end
