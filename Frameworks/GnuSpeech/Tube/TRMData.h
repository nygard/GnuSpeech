//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSObject.h>

/*  GLOBAL DEFINES  **********************************************************/
#define PHARYNX_SECTIONS     3
#define VELUM_SECTIONS       1
#define ORAL_SECTIONS        5
#define NASAL_SECTIONS       5

@interface TRMData : NSObject
{
    /*  GLOTTAL SOURCE PARAMETERS  */
    int32_t waveform;
    int32_t showAmplitude;
    int32_t harmonicsScale;
    int32_t unit;
    int32_t pitch;
    int32_t cents;
    float breathiness;
    int32_t glotVol;
    float tp;
    float tnMin;
    float tnMax;
	
    /*  NOISE SOURCE PARAMETERS  */
    int32_t fricVol;
    float fricPos;
    int32_t fricCF;
    int32_t fricBW;
    int32_t NoiseSourceResponseScale;
    int32_t aspVol;
    int32_t modulation;
    int32_t mixOffset;
	
    /*  THROAT PARAMETERS  */
    int32_t throatVol;
    int32_t throatCutoff;
    int32_t throatResponseScale;
	
    /*  RESONANT SYSTEM PARAMETERS  */
    double pharynxDiameter[PHARYNX_SECTIONS];
    double velumDiameter[VELUM_SECTIONS];
    double oralDiameter[ORAL_SECTIONS];
    double nasalDiameter[NASAL_SECTIONS];
    double lossFactor;
    double apScale;
    double mouthCoef;
    double noseCoef;
    int32_t mouthResponseScale;
    int32_t noseResponseScale;
    double temperature;
    double length;
    double sampleRate;
    double actualLength;
    int32_t controlPeriod;
	
    /*  CONTROLLER PARAMETERS  */
    int32_t volume;
    double balance;
    int32_t channels;
    int32_t controlRate;
	
    /*  ANALYSIS PARAMETERS  */
    BOOL normalizeInput;
    int32_t binSize;
    int32_t windowType;
    float alpha;
    float beta;
    int32_t grayLevel;
    int32_t magnitudeScale;
    float linearUpperThreshold;
    float linearLowerThreshold;
    int32_t logUpperThreshold;
    int32_t logLowerThreshold;
    BOOL spectrographGrid;
    BOOL spectrumGrid;
}

- (id)init;

// Archiving
- (BOOL)readFromCoder:(NSCoder *)aDecoder;

- (float)glotPitch;
- (void)setGlotPitch:(float)value;
- (float)glotVol;
- (void)setGlotVol:(float)value;

- (float)aspVol;
- (void)setAspVol:(float)value;

- (float)fricVol;
- (void)setFricVol:(float)value;
- (float)fricPos;
- (void)setFricPos:(float)value;
- (float)fricCF;
- (void)setFricCF:(float)value;
- (float)fricBW;
- (void)setFricBW:(float)value;

- (float)r1;
- (void)setR1:(float)value;
- (float)r2;
- (void)setR2:(float)value;
- (float)r3;
- (void)setR3:(float)value;
- (float)r4;
- (void)setR4:(float)value;
- (float)r5;
- (void)setR5:(float)value;
- (float)r6;
- (void)setR6:(float)value;
- (float)r7;
- (void)setR7:(float)value;
- (float)r8;
- (void)setR8:(float)value;

- (float)velum;
- (void)setVelum:(float)value;


- (int32_t)controlRate;
- (void)setControlRate:(int32_t)value;

- (float)volume;
- (void)setVolume:(float)value;
- (int32_t)channels;
- (void)setChannels:(int32_t)value;
- (float)balance;
- (void)setBalance:(float)value;

- (int32_t)waveform;
- (void)setWaveform:(int32_t)value;
- (float)tp;
- (void)setTp:(float)value;
- (float)tnMin;
- (void)setTnMin:(float)value;
- (float)tnMax;
- (void)setTnMax:(float)value;
- (float)breathiness;
- (void)setBreathiness:(float)value;

- (float)length;
- (void)setLength:(float)value;
- (float)temperature;
- (void)setTemperature:(float)value;
- (float)lossFactor;
- (void)setLossFactor:(float)value;

- (float)apScale;
- (void)setApScale:(float)value;
- (float)mouthCoef;
- (void)setMouthCoef:(float)value;
- (float)noseCoef;
- (void)setNoseCoef:(float)value;

- (float)n1;
- (void)setN1:(float)value;
- (float)n2;
- (void)setN2:(float)value;
- (float)n3;
- (void)setN3:(float)value;
- (float)n4;
- (void)setN4:(float)value;
- (float)n5;
- (void)setN5:(float)value;

- (float)throatCutoff;
- (void)setThroatCutoff:(float)value;
- (float)throatVol;
- (void)setThroatVol:(float)value;

- (int32_t)modulation;
- (void)setModulation:(int32_t)value;
- (float)mixOffset;
- (void)setMixOffset:(float)value;

@end
