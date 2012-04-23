//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMSynthesisParameters.h"

// MDK: Monet Default Key
#define MDK_OWNER		            @"MONET"
#define MDK_NUMBER		            22

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

#define DEFAULT_MASTER_VOLUME		@"60"
#define DEFAULT_VOCAL_TRACT_LENGTH	@"17.5"
#define DEFAULT_TEMPERATURE		    @"25"
#define DEFAULT_BALANCE			    @"0"
#define DEFAULT_BREATHINESS		    @"1"
#define DEFAULT_LOSS_FACTOR		    @"0.5"
#define DEFAULT_THROAT_CUTTOFF		@"1500"
#define DEFAULT_THROAT_VOLUME		@"6"
#define DEFAULT_APERTURE_SCALING	@"3.05"
#define DEFAULT_MOUTH_COEF		    @"5000"
#define DEFAULT_NOSE_COEF		    @"5000"
#define DEFAULT_MIX_OFFSET		    @"54"
#define DEFAULT_N1			        @"1.35"
#define DEFAULT_N2			        @"1.96"
#define DEFAULT_N3			        @"1.91"
#define DEFAULT_N4		            @"1.3"
#define DEFAULT_N5			        @"0.73"
#define DEFAULT_TP			        @"40"
#define DEFAULT_TN_MIN			    @"16"
#define DEFAULT_TN_MAX			    @"32"
#define DEFAULT_GP_SHAPE		    @"Pulse"
#define DEFAULT_NOISE_MODULATION	@"YES"

#define DEFAULT_PITCH			    @"-12"
#define DEFAULT_SAMPLING_RATE		@"22050"
#define DEFAULT_OUTPUT_CHANNELS		@"Mono"

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

@interface MMSynthesisParameters ()

+ (NSString *)stringForGlottalPulseShape:(MMGlottalPulseShape)shape;
+ (MMGlottalPulseShape)glottalPulseShapeFromString:(NSString *)string;

+ (NSString *)stringForSamplingRate:(MMSamplingRate)rate;
+ (MMSamplingRate)samplingRateFromString:(NSString *)string;

+ (NSString *)stringForChannels:(MMChannels)channels;
+ (MMChannels)channelsFromString:(NSString *)aString;

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
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:MonetDefVal forKeys:MonetDefKeys count:MonetDefCount];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

+ (NSString *)stringForGlottalPulseShape:(MMGlottalPulseShape)shape;
{
    switch (shape) {
        case MMGlottalPulseShape_Pulse: return @"Pulse";
        case MMGlottalPulseShape_Sine:  return @"Sine";
    }

    return nil;
}

+ (MMGlottalPulseShape)glottalPulseShapeFromString:(NSString *)string;
{
    if ([string isEqualToString:@"Pulse"])
        return MMGlottalPulseShape_Pulse;
    if ([string isEqualToString:@"Sine"])
        return MMGlottalPulseShape_Sine;

    [NSException raise:NSInvalidArgumentException format:@"Unknown glottal pulse shape: '%@'", string];
    return MMGlottalPulseShape_Pulse;
}

+ (NSString *)stringForSamplingRate:(MMSamplingRate)rate;
{
    switch (rate) {
        case MMSamplingRate_22050: return @"22050";
        case MMSamplingRate_44100: return @"44100";
    }

    return nil;
}

+ (MMSamplingRate)samplingRateFromString:(NSString *)string;
{
    if ([string isEqualToString:@"22050"])
        return MMSamplingRate_22050;
    if ([string isEqualToString:@"44100"])
        return MMSamplingRate_44100;

    [NSException raise:NSInvalidArgumentException format:@"Unknown sampling rate: '%@'", string];
    return MMSamplingRate_22050;
}

+ (double)samplingRate:(MMSamplingRate)rate;
{
    switch (rate) {
        case MMSamplingRate_22050: return 22050;
        case MMSamplingRate_44100: return 44100;
    }

    [NSException raise:NSInvalidArgumentException format:@"Unknown sampling rate: %lu", rate];
    return 22050;
}

+ (NSString *)stringForChannels:(MMChannels)channels;
{
    switch (channels) {
        case MMChannels_Mono: return @"Mono";
        case MMChannels_Stereo: return @"Stereo";
    }

    return nil;
}

+ (MMChannels)channelsFromString:(NSString *)string;
{
    if ([string isEqualToString:@"Mono"])
        return MMChannels_Mono;
    if ([string isEqualToString:@"Stereo"])
        return MMChannels_Stereo;

    [NSException raise:NSInvalidArgumentException format:@"Unknown channels: '%@'", string];
    return MMChannels_Mono;
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

    throatCutoff    = [defaults doubleForKey:MDK_THROAT_CUTTOFF];
    throatVolume    = [defaults doubleForKey:MDK_THROAT_VOLUME];
    apertureScaling = [defaults doubleForKey:MDK_APERTURE_SCALING];
    mouthCoef       = [defaults doubleForKey:MDK_MOUTH_COEF];
    noseCoef        = [defaults doubleForKey:MDK_NOSE_COEF];
    mixOffset       = [defaults doubleForKey:MDK_MIX_OFFSET];

    n1 = [defaults doubleForKey:MDK_N1];
    n2 = [defaults doubleForKey:MDK_N2];
    n3 = [defaults doubleForKey:MDK_N3];
    n4 = [defaults doubleForKey:MDK_N4];
    n5 = [defaults doubleForKey:MDK_N5];

    tp    = [defaults doubleForKey:MDK_TP];
    tnMin = [defaults doubleForKey:MDK_TN_MIN];
    tnMax = [defaults doubleForKey:MDK_TN_MAX];

    glottalPulseShape        = [MMSynthesisParameters glottalPulseShapeFromString:[defaults stringForKey:MDK_GP_SHAPE]];
    shouldUseNoiseModulation = [defaults boolForKey:MDK_NOISE_MODULATION];

    samplingRate   = [MMSynthesisParameters samplingRateFromString:[defaults stringForKey:MDK_SAMPLING_RATE]];
    outputChannels = [MMSynthesisParameters channelsFromString:[defaults stringForKey:MDK_OUTPUT_CHANNELS]];
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

    NSLog(@"%s, glottalPulseShape: %ldu, str: %@", __PRETTY_FUNCTION__, glottalPulseShape, [MMSynthesisParameters stringForGlottalPulseShape:glottalPulseShape]);
    [defaults setObject:[MMSynthesisParameters stringForGlottalPulseShape:glottalPulseShape] forKey:MDK_GP_SHAPE];
    [defaults setBool:shouldUseNoiseModulation forKey:MDK_NOISE_MODULATION];
    [defaults setObject:[MMSynthesisParameters stringForSamplingRate:samplingRate] forKey:MDK_SAMPLING_RATE];
    [defaults setObject:[MMSynthesisParameters stringForChannels:outputChannels] forKey:MDK_OUTPUT_CHANNELS];
}

@synthesize masterVolume, vocalTractLength, temperature, balance, breathiness, lossFactor, pitch, throatCutoff, throatVolume, apertureScaling, mouthCoef, noseCoef, mixOffset, n1, n2, n3, n4, n5, tp, tnMin, tnMax, glottalPulseShape, shouldUseNoiseModulation, samplingRate, outputChannels;


// TODO (2012-04-23): Just always include the comments.  And save to the specified file!
- (void)writeToFile:(NSString *)filename includeComments:(BOOL)shouldIncludeComments;
{
    float sRate = (samplingRate == MMSamplingRate_44100) ? 44100.0 : 22050.0;

    FILE *fp = fopen("/tmp/Monet.parameters", "w");

    if (shouldIncludeComments) {
        fprintf(fp, "%u\t\t; %s\n",  0,                        "output file format (0 = AU, 1 = AIFF, 2 = WAVE)");
        fprintf(fp, "%f\t; %s\n",    sRate,                    "output sample rate (22050.0, 44100.0)");
        fprintf(fp, "%u\t\t; %s\n",  250,                      "input control rate (1 - 1000 Hz)");
        fprintf(fp, "%f\t; %s\n",    masterVolume,             "master volume (0 - 60 dB)");
        fprintf(fp, "%lu\t\t; %s\n", outputChannels + 1,       "number of sound output channels (1 or 2)");
        fprintf(fp, "%f\t; %s\n",    balance,                  "stereo balance (-1 to +1)");
        fprintf(fp, "%lu\t\t; %s\n", glottalPulseShape,        "glottal source waveform type (0 = pulse, 1 = sine)");
        fprintf(fp, "%f\t; %s\n",    tp,                       "glottal pulse rise time (5 - 50 % of GP period)");
        fprintf(fp, "%f\t; %s\n",    tnMin,                    "glottal pulse fall time minimum (5 - 50 % of GP period)");
        fprintf(fp, "%f\t; %s\n",    tnMax,                    "glottal pulse fall time maximum (5 - 50 % of GP period)");
        fprintf(fp, "%f\t; %s\n",    breathiness,              "glottal source breathiness (0 - 10 % of GS amplitude)");
        fprintf(fp, "%f\t; %s\n",    vocalTractLength,         "nominal tube length (10 - 20 cm)");
        fprintf(fp, "%f\t; %s\n",    temperature,              "tube temperature (25 - 40 degrees celsius)");
        fprintf(fp, "%f\t; %s\n",    lossFactor,               "junction loss factor (0 - 5 % of unity gain)");
        fprintf(fp, "%f\t; %s\n",    apertureScaling,          "aperture scaling radius (3.05 - 12 cm)");
        fprintf(fp, "%f\t; %s\n",    mouthCoef,                "mouth aperture coefficient (0 - 0.99)");
        fprintf(fp, "%f\t; %s\n",    noseCoef,                 "nose aperture coefficient (0 - 0.99)");
        fprintf(fp, "%f\t; %s\n",    n1,                       "radius of nose section 1 (0 - 3 cm)");
        fprintf(fp, "%f\t; %s\n",    n2,                       "radius of nose section 2 (0 - 3 cm)");
        fprintf(fp, "%f\t; %s\n",    n3,                       "radius of nose section 3 (0 - 3 cm)");
        fprintf(fp, "%f\t; %s\n",    n4,                       "radius of nose section 4 (0 - 3 cm)");
        fprintf(fp, "%f\t; %s\n",    n5,                       "radius of nose section 5 (0 - 3 cm)");
        fprintf(fp, "%f\t; %s\n",    throatCutoff,             "throat lowpass frequency cutoff (50 - nyquist Hz)");
        fprintf(fp, "%f\t; %s\n",    throatVolume,             "throat volume (0 - 48 dB)");
        fprintf(fp, "%d\t\t; %s\n",  shouldUseNoiseModulation, "pulse modulation of noise (0 = off, 1 = on)");
        fprintf(fp, "%f\t; %s\n",    mixOffset,                "noise crossmix offset (30 - 60 db)");
    } else {
        fprintf(fp,"0\n%f\n250\n%f\n%ld\n%f\n%lu\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%d\n%f\n",
                sRate, masterVolume,
                outputChannels + 1, balance,
                glottalPulseShape, tp, tnMin,
                tnMax, breathiness,
                vocalTractLength, temperature,
                lossFactor, apertureScaling,
                mouthCoef, noseCoef,
                n1, n2, n3,
                n4, n5,
                throatCutoff, throatVolume,
                shouldUseNoiseModulation, mixOffset);
    }

    fclose(fp);
}

@end
