//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMSynthesisParameters.h"

#import "STLogger.h"

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
    double _masterVolume;
    double _vocalTractLength;
    double _temperature;
    double _balance;
    double _breathiness;
    double _lossFactor;
    double _pitch;

    double _throatCutoff;
    double _throatVolume;
    double _apertureScaling;
    double _mouthCoef;
    double _noseCoef;
    double _mixOffset;

    double _n1;
    double _n2;
    double _n3;
    double _n4;
    double _n5;

    double _tp;
    double _tnMin;
    double _tnMax;

    MMGlottalPulseShape _glottalPulseShape;
    BOOL _shouldUseNoiseModulation;

    MMSamplingRate _samplingRate;
    MMChannels _outputChannels;
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

    _masterVolume     = [defaults doubleForKey:MDK_MASTER_VOLUME];
    _vocalTractLength = [defaults doubleForKey:MDK_VOCAL_TRACT_LENGTH];
    _temperature      = [defaults doubleForKey:MDK_TEMPERATURE];
    _balance          = [defaults doubleForKey:MDK_BALANCE];
    _breathiness      = [defaults doubleForKey:MDK_BREATHINESS];
    _lossFactor       = [defaults doubleForKey:MDK_LOSS_FACTOR];
    _pitch            = [defaults doubleForKey:MDK_PITCH];

    _throatCutoff     = [defaults doubleForKey:MDK_THROAT_CUTTOFF];
    _throatVolume     = [defaults doubleForKey:MDK_THROAT_VOLUME];
    _apertureScaling  = [defaults doubleForKey:MDK_APERTURE_SCALING];
    _mouthCoef        = [defaults doubleForKey:MDK_MOUTH_COEF];
    _noseCoef         = [defaults doubleForKey:MDK_NOSE_COEF];
    _mixOffset        = [defaults doubleForKey:MDK_MIX_OFFSET];

    _n1 = [defaults doubleForKey:MDK_N1];
    _n2 = [defaults doubleForKey:MDK_N2];
    _n3 = [defaults doubleForKey:MDK_N3];
    _n4 = [defaults doubleForKey:MDK_N4];
    _n5 = [defaults doubleForKey:MDK_N5];

    _tp    = [defaults doubleForKey:MDK_TP];
    _tnMin = [defaults doubleForKey:MDK_TN_MIN];
    _tnMax = [defaults doubleForKey:MDK_TN_MAX];

    _glottalPulseShape        = MMGlottalPulseShapeFromString([defaults stringForKey:MDK_GP_SHAPE]);
    _shouldUseNoiseModulation = [defaults boolForKey:MDK_NOISE_MODULATION];

    _samplingRate   = MMSamplingRateFromString([defaults stringForKey:MDK_SAMPLING_RATE]);
    _outputChannels = MMChannelsFromString([defaults stringForKey:MDK_OUTPUT_CHANNELS]);
}

- (void)saveAsDefaults;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setDouble:_masterVolume     forKey:MDK_MASTER_VOLUME];
    [defaults setDouble:_vocalTractLength forKey:MDK_VOCAL_TRACT_LENGTH];
    [defaults setDouble:_temperature      forKey:MDK_TEMPERATURE];
    [defaults setDouble:_balance          forKey:MDK_BALANCE];
    [defaults setDouble:_breathiness      forKey:MDK_BREATHINESS];
    [defaults setDouble:_lossFactor       forKey:MDK_LOSS_FACTOR];
    [defaults setDouble:_pitch            forKey:MDK_PITCH];

    [defaults setDouble:_throatCutoff    forKey:MDK_THROAT_CUTTOFF];
    [defaults setDouble:_throatVolume    forKey:MDK_THROAT_VOLUME];
    [defaults setDouble:_apertureScaling forKey:MDK_APERTURE_SCALING];
    [defaults setDouble:_mouthCoef       forKey:MDK_MOUTH_COEF];
    [defaults setDouble:_noseCoef        forKey:MDK_NOSE_COEF];
    [defaults setDouble:_mixOffset       forKey:MDK_MIX_OFFSET];

    [defaults setDouble:_n1 forKey:MDK_N1];
    [defaults setDouble:_n2 forKey:MDK_N2];
    [defaults setDouble:_n3 forKey:MDK_N3];
    [defaults setDouble:_n4 forKey:MDK_N4];
    [defaults setDouble:_n5 forKey:MDK_N5];

    [defaults setDouble:_tp    forKey:MDK_TP];
    [defaults setDouble:_tnMin forKey:MDK_TN_MIN];
    [defaults setDouble:_tnMax forKey:MDK_TN_MAX];

    [defaults setObject:MMGlottalPulseShapeName(_glottalPulseShape) forKey:MDK_GP_SHAPE];
    [defaults setBool:_shouldUseNoiseModulation                     forKey:MDK_NOISE_MODULATION];
    [defaults setObject:MMSamplingRateName(_samplingRate)           forKey:MDK_SAMPLING_RATE];
    [defaults setObject:MMChannelsName(_outputChannels)             forKey:MDK_OUTPUT_CHANNELS];
}

- (double)sampleRate;
{
    return MMSampleRate(self.samplingRate);
}

- (NSString *)parameterString;
{
    NSMutableString *str = [NSMutableString string];
    
    [str appendFormat:@"%u\t\t; %@\n",  0,                        @"output file format (0 = AU, 1 = AIFF, 2 = WAVE)"];
    [str appendFormat:@"%g\t\t; %@\n",  self.sampleRate,          @"output sample rate (22050.0, 44100.0)"];
    [str appendFormat:@"%u\t\t; %@\n",  250,                      @"input control rate (1 - 1000 Hz)"];
    [str appendFormat:@"%f\t; %@\n",    _masterVolume,             @"master volume (0 - 60 dB)"];
    [str appendFormat:@"%lu\t\t; %@\n", _outputChannels + 1,       @"number of sound output channels (1 or 2)"];
    [str appendFormat:@"%f\t; %@\n",    _balance,                  @"stereo balance (-1 to +1)"];
    [str appendFormat:@"%lu\t\t; %@\n", _glottalPulseShape,        @"glottal source waveform type (0 = pulse, 1 = sine)"];
    [str appendFormat:@"%f\t; %@\n",    _tp,                       @"glottal pulse rise time (5 - 50 % of GP period)"];
    [str appendFormat:@"%f\t; %@\n",    _tnMin,                    @"glottal pulse fall time minimum (5 - 50 % of GP period)"];
    [str appendFormat:@"%f\t; %@\n",    _tnMax,                    @"glottal pulse fall time maximum (5 - 50 % of GP period)"];
    [str appendFormat:@"%f\t; %@\n",    _breathiness,              @"glottal source breathiness (0 - 10 % of GS amplitude)"];
    [str appendFormat:@"%f\t; %@\n",    _vocalTractLength,         @"nominal tube length (10 - 20 cm)"];
    [str appendFormat:@"%f\t; %@\n",    _temperature,              @"tube temperature (25 - 40 degrees celsius)"];
    [str appendFormat:@"%f\t; %@\n",    _lossFactor,               @"junction loss factor (0 - 5 % of unity gain)"];
    [str appendFormat:@"%f\t; %@\n",    _apertureScaling,          @"aperture scaling radius (3.05 - 12 cm)"];
    [str appendFormat:@"%f\t; %@\n",    _mouthCoef,                @"mouth aperture coefficient (0 - 0.99)"];
    [str appendFormat:@"%f\t; %@\n",    _noseCoef,                 @"nose aperture coefficient (0 - 0.99)"];
    [str appendFormat:@"%f\t; %@\n",    _n1,                       @"radius of nose section 1 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    _n2,                       @"radius of nose section 2 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    _n3,                       @"radius of nose section 3 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    _n4,                       @"radius of nose section 4 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    _n5,                       @"radius of nose section 5 (0 - 3 cm)"];
    [str appendFormat:@"%f\t; %@\n",    _throatCutoff,             @"throat lowpass frequency cutoff (50 - nyquist Hz)"];
    [str appendFormat:@"%f\t; %@\n",    _throatVolume,             @"throat volume (0 - 48 dB)"];
    [str appendFormat:@"%d\t\t; %@\n",  _shouldUseNoiseModulation, @"pulse modulation of noise (0 = off, 1 = on)"];
    [str appendFormat:@"%f\t; %@",    _mixOffset,                @"noise crossmix offset (30 - 60 db)"];
    
    return str;
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)error;
{
    return [self.parameterString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:error];
}

- (void)logToLogger:(STLogger *)logger;
{
    // Well, this isn't perfect, it wouldn't get the proper indentation and prefix from the logger.
    [logger log:self.parameterString];
}

@end
