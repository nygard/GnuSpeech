#import <Foundation/NSObject.h>

@interface DefaultMgr : NSObject
{
}

+ (void)initialize;
- (void)updateDefaults;
- (void)writeDefaults;

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

- (double)throatCuttoff;
- (void)setThroatCuttoff:(double)value;

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
- (void)setn1:(double)value;

- (double)n2;
- (void)setn2:(double)value;

- (double)n3;
- (void)setn3:(double)value;

- (double)n4;
- (void)setn4:(double)value;

- (double)n5;
- (void)setn5:(double)value;

- (double)tp;
- (void)setTp:(double)value;

- (double)tnMin;
- (void)setTnMin:(double)value;

- (double)tnMax;
- (void)setTnMax:(double)value;

- (NSString *)glottalPulseShape;
- (void)setGlottalPulseShape:(NSString *)value;

- (NSString *)noiseModulation;
- (void)setNoiseModulation:(NSString *)value;

@end
