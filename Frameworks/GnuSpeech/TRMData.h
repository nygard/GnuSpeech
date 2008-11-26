#import "TRMData.h"

#import <Foundation/Foundation.h>
#import <math.h>


/*  LOCAL DEFINES  ***********************************************************/
#define CURRENT_FILE_VERSION  1

#define WAVEFORMTYPE_DEF      0
#define SHOWAMPLITUDE_DEF     1
#define HARMONICS_DEF         1
#define UNIT_DEF              0
#define PITCH_DEF             0
#define CENTS_MIN             (-50)
#define CENTS_MAX             50
#define CENTS_DEF             0
#define BREATHINESS_DEF       2.5
#define RISETIME_DEF          40.0
#define FALLTIMEMIN_DEF       12.0
#define FALLTIMEMAX_DEF       35.0

#define VOLUME_DEF            60.0

#define FRIC_VOLUME_DEF       0.0
#define ASP_VOLUME_DEF        0.0
#define POSITION_DEF          4.0
#define CENTER_FREQ_DEF       2000
#define BANDWIDTH_DEF         1000
#define RESPONSE_DEF          0
#define PULSE_MOD_DEF         1
#define CROSSMIX_DEF          60.0

#define THROAT_VOLUME_DEF     12.0
#define CUTOFF_DEF            1500.0

#define DIAMETER_MIN          0.0
#define DIAMETER_MAX          6.0
#define VELUM_DIAMETER_MAX    3.0
#define PHARYNX_SECTION1_DEF  1.6
#define PHARYNX_SECTION2_DEF  1.6
#define PHARYNX_SECTION3_DEF  1.6
#define VELUM_SECTION1_DEF    0.0
#define ORAL_SECTION1_DEF     1.6
#define ORAL_SECTION2_DEF     1.6
#define ORAL_SECTION3_DEF     1.6
#define ORAL_SECTION4_DEF     1.6
#define ORAL_SECTION5_DEF     1.6
#define NASAL_SECTION1_DEF    2.7
#define NASAL_SECTION2_DEF    3.4
#define NASAL_SECTION3_DEF    3.4
#define NASAL_SECTION4_DEF    2.6
#define NASAL_SECTION5_DEF    1.8
#define LOSS_FACTOR_DEF       2.0
#define APERTURE_SCALING_MIN  (DIAMETER_MAX + 0.1)
#define APERTURE_SCALING_MAX  (DIAMETER_MAX * 4.0)
#define APERTURE_SCALING_DEF  APERTURE_SCALING_MIN
#define FILTER_DEF            0.75
#define LENGTH_DEF            17.5
#define TEMPERATURE_DEF       32.0
#define CONTROL_PERIOD_DEF    160
#define SAMPLE_RATE_DEF       16000
#define ACTUAL_LENGTH_DEF     17.53

#define BALANCE_DEF           0.0
#define CHANNELS_DEF          2
#define CONTROL_RATE_DEF      500

#define NORMALIZE_INPUT_DEF   1
#define BIN_SIZE_DEF          256
#define WINDOW_TYPE_DEF       4
#define ALPHA_DEF             0.54
#define BETA_DEF              5.0
#define GRAY_LEVEL_DEF        0
#define MAGNITUDE_SCALE_DEF   1
#define UPPER_THRESH_LIN_DEF  0.15
#define LOWER_THRESH_LIN_DEF  0.0
#define UPPER_THRESH_LOG_DEF  (-18)
#define LOWER_THRESH_LOG_DEF  (-66)
#define SPECTROGRAPH_GRID_DEF 0
#define SPECTRUM_GRID_DEF     1

@implementation TRMData

- (id)init;
{
    if ([super init] == nil)
        return nil;
	
    /*  INITIALIZE INSTANCE VARIABLES TO REASONABLE DEFAULTS  */
    /*  GLOTTAL SOURCE PARAMETERS  */
    waveform = WAVEFORMTYPE_DEF;
    showAmplitude = SHOWAMPLITUDE_DEF;
    harmonicsScale = HARMONICS_DEF;
    unit = UNIT_DEF;
    pitch = PITCH_DEF;
    cents = CENTS_DEF;
    breathiness = BREATHINESS_DEF;
    glotVol = VOLUME_DEF;
    tp = RISETIME_DEF;
    tnMin = FALLTIMEMIN_DEF;
    tnMax = FALLTIMEMAX_DEF;
	
    /*  NOISE SOURCE PARAMETERS  */
    fricVol = FRIC_VOLUME_DEF;
    fricPos = POSITION_DEF;
    fricCF = CENTER_FREQ_DEF;
    fricBW = BANDWIDTH_DEF;
    NoiseSourceResponseScale = RESPONSE_DEF;
    aspVol = ASP_VOLUME_DEF;
    modulation = PULSE_MOD_DEF;
    mixOffset = CROSSMIX_DEF;
	
    /*  THROAT PARAMETERS  */
    throatVol = THROAT_VOLUME_DEF;
    throatCutoff = CUTOFF_DEF;
    throatResponseScale = RESPONSE_DEF;
	
    /*  RESONANT SYSTEM PARAMETERS  */
    pharynxDiameter[0] = PHARYNX_SECTION1_DEF;
    pharynxDiameter[1] = PHARYNX_SECTION2_DEF;
    pharynxDiameter[2] = PHARYNX_SECTION3_DEF;
    velumDiameter[0] = VELUM_SECTION1_DEF;
    oralDiameter[0] = ORAL_SECTION1_DEF;
    oralDiameter[1] = ORAL_SECTION2_DEF;
    oralDiameter[2] = ORAL_SECTION3_DEF;
    oralDiameter[3] = ORAL_SECTION4_DEF;
    oralDiameter[4] = ORAL_SECTION5_DEF;
    nasalDiameter[0] = NASAL_SECTION1_DEF;
    nasalDiameter[1] = NASAL_SECTION2_DEF;
    nasalDiameter[2] = NASAL_SECTION3_DEF;
    nasalDiameter[3] = NASAL_SECTION4_DEF;
    nasalDiameter[4] = NASAL_SECTION5_DEF;
    lossFactor = LOSS_FACTOR_DEF / 100.0;
    apScale = APERTURE_SCALING_DEF;
    mouthCoef = noseCoef = FILTER_DEF;
    mouthResponseScale = noseResponseScale = RESPONSE_DEF;
    length = LENGTH_DEF;
    temperature = TEMPERATURE_DEF;
    controlPeriod = CONTROL_PERIOD_DEF;
    sampleRate = SAMPLE_RATE_DEF;
    actualLength = ACTUAL_LENGTH_DEF;
	
    /*  CONTROLLER PARAMETERS  */
    volume = VOLUME_DEF;
    balance = BALANCE_DEF;
    channels = CHANNELS_DEF;
    controlRate = CONTROL_RATE_DEF;
	
    /*  ANALYSIS PARAMETERS  */
    normalizeInput = NORMALIZE_INPUT_DEF;
    binSize = BIN_SIZE_DEF;
    windowType = WINDOW_TYPE_DEF;
    alpha = ALPHA_DEF;
    beta = BETA_DEF;
    grayLevel = GRAY_LEVEL_DEF;
    magnitudeScale = MAGNITUDE_SCALE_DEF;
    linearUpperThreshold = UPPER_THRESH_LIN_DEF;
    linearLowerThreshold = LOWER_THRESH_LIN_DEF;
    logUpperThreshold = UPPER_THRESH_LOG_DEF;
    logLowerThreshold = LOWER_THRESH_LOG_DEF;
    spectrographGrid = SPECTROGRAPH_GRID_DEF;
    spectrumGrid = SPECTRUM_GRID_DEF;
	
    return self;
}

//
// Archiving
//

- (BOOL)readFromCoder:(NSCoder *)aDecoder;
{
    int fileVersion;
	
    NS_DURING {
        /*  READ FILE VERSION FROM STREAM  */
        [aDecoder decodeValuesOfObjCTypes:"i", &fileVersion];
		
        /*  READ PARAMETERS FROM STREAM  */
        /*  GLOTTAL SOURCE PARAMETERS  */
        [aDecoder decodeValuesOfObjCTypes:"iiiiiififff", &waveform, &showAmplitude,
		 &harmonicsScale, &unit, &pitch, &cents, &breathiness,
		 &glotVol, &tp, &tnMin, &tnMax];
		
        /*  NOISE SOURCE PARAMETERS  */
        [aDecoder decodeValuesOfObjCTypes:"ifiiiiii", &fricVol, &fricPos,
		 &aspVol, &fricCF, &NoiseSourceResponseScale,
		 &fricBW, &modulation, &mixOffset];
		
        /*  THROAT PARAMETERS  */
        [aDecoder decodeValuesOfObjCTypes:"iii", &throatVol, &throatCutoff,
		 &throatResponseScale];
		
        /*  RESONANT SYSTEM PARAMETERS  */
        [aDecoder decodeArrayOfObjCType:"d" count:PHARYNX_SECTIONS at:pharynxDiameter];
        [aDecoder decodeArrayOfObjCType:"d" count:VELUM_SECTIONS at:velumDiameter];
        [aDecoder decodeArrayOfObjCType:"d" count:ORAL_SECTIONS at:oralDiameter];
        [aDecoder decodeArrayOfObjCType:"d" count:NASAL_SECTIONS at:nasalDiameter];
        [aDecoder decodeValuesOfObjCTypes:"ddddiiddddi", &lossFactor, &apScale,
		 &mouthCoef, &noseCoef, &mouthResponseScale,
		 &noseResponseScale, &temperature, &length, &sampleRate,
		 &actualLength, &controlPeriod];
		
        /*  CONTROLLER PARAMETERS  */
        [aDecoder decodeValuesOfObjCTypes:"idii", &volume, &balance,
		 &channels, &controlRate];
		
        /*  ANALYSIS PARAMETERS  */
        [aDecoder decodeValuesOfObjCTypes:"ciiffiiffiicc", &normalizeInput, &binSize,
		 &windowType, &alpha, &beta, &grayLevel, &magnitudeScale,
		 &linearUpperThreshold, &linearLowerThreshold,
		 &logUpperThreshold, &logLowerThreshold,
		 &spectrographGrid, &spectrumGrid];
    } NS_HANDLER {
        NSLog(@"Caught exception while reading TRM data: %@", localException);
        return NO;
    } NS_ENDHANDLER;
	
    return YES;
}

- (float)glotPitch
{
    return (float)pitch + (float)cents / 100.0;
}

- (void)setGlotPitch:(float)value
{
    /*  GET THE PITCH AND CENTS VALUES  */
    pitch = (int)value;
    cents = (int)rint((value - (int)value) * 100);
	
    /*  ADJUST PITCH AND CENTS IF CENTS ARE OUT OF RANGE  */
    if (cents > CENTS_MAX) {
		pitch += 1;
		cents -= 100;
    }
    if (cents < CENTS_MIN) {
		pitch -= 1;
		cents += 100;
    }
}



- (float)glotVol;
{
    return (float)glotVol;
}

- (void)setGlotVol:(float)value;
{
    glotVol = (int)rint(value);
}



- (float)aspVol;
{
    return (float)aspVol;
}

- (void)setAspVol:(float)value;
{
    aspVol = (int)rint(value);
}



- (float)fricVol;
{
    return (float)fricVol;
}

- (void)setFricVol:(float)value;
{
    fricVol = (int)rint(value);
}



- (float)fricPos;
{
    return fricPos;
}

- (void)setFricPos:(float)value;
{
    fricPos = value;
}



- (float)fricCF;
{
    return (float)fricCF;
}

- (void)setFricCF:(float)value;
{
    fricCF = (int)rint(value);
}



- (float)fricBW;
{
    return (float)fricBW;
}

- (void)setFricBW:(float)value;
{
    fricBW = (int)rint(value);
}



- (float)r1;
{
    return pharynxDiameter[0] / 2.0;
}

- (void)setR1:(float)value;
{
    pharynxDiameter[0] = value * 2.0;
}



- (float)r2;
{
    return pharynxDiameter[1] / 2.0;
}

- (void)setR2:(float)value;
{
    pharynxDiameter[1] = value * 2.0;
}



- (float)r3;
{
    return pharynxDiameter[2] / 2.0;
}

- (void)setR3:(float)value;
{
    pharynxDiameter[2] = value * 2.0;
}



- (float)r4;
{
    return oralDiameter[0] / 2.0;
}

- (void)setR4:(float)value;
{
    oralDiameter[0] = value * 2.0;
}



- (float)r5;
{
    return oralDiameter[1] / 2.0;
}

- (void)setR5:(float)value;
{
    oralDiameter[1] = value * 2.0;
}



- (float)r6;
{
    return oralDiameter[2] / 2.0;
}

- (void)setR6:(float)value;
{
    oralDiameter[2] = value * 2.0;
}



- (float)r7;
{
    return oralDiameter[3] / 2.0;
}

- (void)setR7:(float)value;
{
    oralDiameter[3] = value * 2.0;
}



- (float)r8;
{
    return oralDiameter[4] / 2.0;
}

- (void)setR8:(float)value;
{
    oralDiameter[4] = value * 2.0;
}



- (float)velum;
{
    return velumDiameter[0] / 2.0;
}

- (void)setVelum:(float)value;
{
    velumDiameter[0] = value * 2.0;
}



- (int)controlRate;
{
    return controlRate;
}

- (void)setControlRate:(int)value;
{
    controlRate = value;
}



- (float)volume;
{
    return (float)volume;
}

- (void)setVolume:(float)value;
{
    volume = (int)rint(value);
}



- (int)channels;
{
    return channels;
}

- (void)setChannels:(int)value;
{
    channels = value;
}



- (float)balance;
{
    return balance;
}

- (void)setBalance:(float)value;
{
    balance = value;
}



- (int)waveform;
{
    return waveform;
}

- (void)setWaveform:(int)value;
{
    waveform = value;
}



- (float)tp;
{
    return tp;
}

- (void)setTp:(float)value;
{
    tp = value;
}



- (float)tnMin;
{
    return tnMin;
}

- (void)setTnMin:(float)value;
{
    tnMin = value;
}



- (float)tnMax;
{
    return tnMax;
}

- (void)setTnMax:(float)value;
{
    tnMax = value;
}



- (float)breathiness;
{
    return breathiness;
}

- (void)setBreathiness:(float)value;
{
    breathiness = value;
}



- (float)length;
{
    return length;
}

- (void)setLength:(float)value;
{
    length = value;
}



- (float)temperature;
{
    return temperature;
}

- (void)setTemperature:(float)value;
{
    temperature = value;
}



- (float)lossFactor;
{
    return lossFactor * 100.0;
}

- (void)setLossFactor:(float)value;
{
    lossFactor = value / 100.0;
}



- (float)apScale;
{
    return apScale / 2.0;
}

- (void)setApScale:(float)value;
{
    apScale = value * 2.0;
}



- (float)mouthCoef;
{
    return mouthCoef;
}

- (void)setMouthCoef:(float)value;
{
    mouthCoef = value;
}



- (float)noseCoef;
{
    return noseCoef;
}

- (void)setNoseCoef:(float)value;
{
    noseCoef = value;
}



- (float)n1;
{
    return nasalDiameter[0] / 2.0;
}

- (void)setN1:(float)value;
{
    nasalDiameter[0] = value * 2.0;
}



- (float)n2;
{
    return nasalDiameter[1] / 2.0;
}

- (void)setN2:(float)value;
{
    nasalDiameter[1] = value * 2.0;
}



- (float)n3;
{
    return nasalDiameter[2] / 2.0;
}

- (void)setN3:(float)value;
{
    nasalDiameter[2] = value * 2.0;
}



- (float)n4;
{
    return nasalDiameter[3] / 2.0;
}

- (void)setN4:(float)value;
{
    nasalDiameter[3] = value * 2.0;
}



- (float)n5;
{
    return nasalDiameter[4] / 2.0;
}

- (void)setN5:(float)value;
{
    nasalDiameter[4] = value * 2.0;
}



- (float)throatCutoff;
{
    return (float)throatCutoff;
}

- (void)setThroatCutoff:(float)value;
{
    throatCutoff = (int)rint(value);
}



- (float)throatVol;
{
    return (float)throatVol;
}

- (void)setThroatVol:(float)value;
{
    throatVol = (int)rint(value);
}



- (int)modulation;
{
    return modulation;
}

- (void)setModulation:(int)value;
{
    modulation = value;
}



- (float)mixOffset;
{
    return (float)mixOffset;
}

- (void)setMixOffset:(float)value;
{
    mixOffset = (int)rint(value);
}

@end
