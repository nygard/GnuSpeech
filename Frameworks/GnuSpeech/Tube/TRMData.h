#import <Foundation/NSObject.h>

/*  GLOBAL DEFINES  **********************************************************/
#define PHARYNX_SECTIONS     3
#define VELUM_SECTIONS       1
#define ORAL_SECTIONS        5
#define NASAL_SECTIONS       5

@interface TRMData : NSObject
{
    /*  GLOTTAL SOURCE PARAMETERS  */
    int waveform;
    int showAmplitude;
    int harmonicsScale;
    int unit;
    int pitch;
    int cents;
    float breathiness;
    int glotVol;
    float tp;
    float tnMin;
    float tnMax;
	
    /*  NOISE SOURCE PARAMETERS  */
    int fricVol;
    float fricPos;
    int fricCF;
    int fricBW;
    int NoiseSourceResponseScale;
    int aspVol;
    int modulation;
    int mixOffset;
	
    /*  THROAT PARAMETERS  */
    int throatVol;
    int throatCutoff;
    int throatResponseScale;
	
    /*  RESONANT SYSTEM PARAMETERS  */
    double pharynxDiameter[PHARYNX_SECTIONS];
    double velumDiameter[VELUM_SECTIONS];
    double oralDiameter[ORAL_SECTIONS];
    double nasalDiameter[NASAL_SECTIONS];
    double lossFactor;
    double apScale;
    double mouthCoef;
    double noseCoef;
    int mouthResponseScale;
    int noseResponseScale;
    double temperature;
    double length;
    double sampleRate;
    double actualLength;
    int controlPeriod;
	
    /*  CONTROLLER PARAMETERS  */
    int volume;
    double balance;
    int channels;
    int controlRate;
	
    /*  ANALYSIS PARAMETERS  */
    BOOL normalizeInput;
    int binSize;
    int windowType;
    float alpha;
    float beta;
    int grayLevel;
    int magnitudeScale;
    float linearUpperThreshold;
    float linearLowerThreshold;
    int logUpperThreshold;
    int logLowerThreshold;
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


- (int)controlRate;
- (void)setControlRate:(int)value;

- (float)volume;
- (void)setVolume:(float)value;
- (int)channels;
- (void)setChannels:(int)value;
- (float)balance;
- (void)setBalance:(float)value;

- (int)waveform;
- (void)setWaveform:(int)value;
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

- (int)modulation;
- (void)setModulation:(int)value;
- (float)mixOffset;
- (void)setMixOffset:(float)value;

@end
