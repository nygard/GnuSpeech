
#import <Foundation/NSObject.h>
#import <Foundation/NSUserDefaults.h>

@interface DefaultMgr:NSObject
{

}

+ (void)initialize;
- (void)updateDefaults;
- (void)writeDefaults;

- (void)setMasterVolume:(double)value;
- (double) masterVolume;
- (void)setVocalTractLength:(double)value;
- (double) vocalTractLength;
- (void)setTemperature:(double)value;
- (double) temperature;
- (void)setBalance:(double)value;
- (double) balance;
- (void)setBreathiness:(double)value;
- (double) breathiness;
- (void)setLossFactor:(double)value;
- (double) lossFactor;
- (void)setThroatCuttoff:(double)value;
- (double) throatCuttoff;
- (void)setThroatVolume:(double)value;
- (double) throatVolume;
- (void)setApertureScaling:(double)value;
- (double) apertureScaling;
- (void)setMouthCoef:(double)value;
- (double) mouthCoef;
- (void)setNoseCoef:(double)value;
- (double) noseCoef;
- (void)setMixOffset:(double)value;
- (double) mixOffset;
- (void)setn1:(double)value;
- (double) n1;
- (void)setn2:(double)value;
- (double) n2;
- (void)setn3:(double)value;
- (double) n3;
- (void)setn4:(double)value;
- (double) n4;
- (void)setn5:(double)value;
- (double) n5;
- (void)setTp:(double)value;
- (double) tp;
- (void)setTnMin:(double)value;
- (double) tnMin;
- (void)setTnMax:(double)value;
- (double) tnMax;
- (void)setGlottalPulseShape:(const char *)value;
- (const char *) glottalPulseShape;
- (void)setNoiseModulation:(const char *)value;
- (const char *) noiseModulation;

@end
