#import "DefaultMgr.h"

#import <Foundation/Foundation.h>
#import "NSUserDefaults-Extensions.h"
#import "MonetDefaults.h"

/*
	Revision Information
	_Author: fedor $
	_Date: 2002/12/15 05:05:09 $
	_Revision: 1.2 $
	_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/DefaultMgr.m,v $
	_State: Exp $
*/

/*===========================================================================

	File: DefaultMgr.m

	Purpose: All defaults database access/storage is handled in this
		file.

		This object provides two methods for each default database
		item.  One method sets the item and the other returns the
		current value of the item.

	NOTE: All default "#defines" are in file "MonetDefaults.h"

===========================================================================*/

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

@implementation DefaultMgr

+ (void)initialize;
{
#if 0
    NSDictionary *dict;

    dict = [NSDictionary dictionaryWithObjects:MonetDefVal forKeys:MonetDefKeys count:MonetDefCount];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
#endif
}

- (void)updateDefaults;
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)writeDefaults;
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    int index;

    for (index = 0; index < MonetDefCount; index++)
        [def setObject:MonetDefVal[index] forKey:MonetDefKeys[index]];
}

- (double)masterVolume;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_MASTER_VOLUME];
}

- (void)setMasterVolume:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_MASTER_VOLUME];
}

- (double)vocalTractLength;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_VOCAL_TRACT_LENGTH];
}

- (void)setVocalTractLength:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_VOCAL_TRACT_LENGTH];
}

- (double)temperature;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_TEMPERATURE];
}

- (void)setTemperature:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_TEMPERATURE];
}

- (double)balance;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_BALANCE];
}

- (void)setBalance:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_BALANCE];
}

- (double)breathiness;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_BREATHINESS];
}

- (void)setBreathiness:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_BREATHINESS];
}

- (double)lossFactor;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_LOSS_FACTOR];
}

- (void)setLossFactor:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_LOSS_FACTOR];
}

- (double)throatCuttoff;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_THROAT_CUTTOFF];
}

- (void)setThroatCuttoff:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_THROAT_CUTTOFF];
}

- (double)throatVolume;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_THROAT_VOLUME];
}

- (void)setThroatVolume:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_THROAT_VOLUME];
}

- (double)apertureScaling;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_APERTURE_SCALING];
}

- (void)setApertureScaling:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_APERTURE_SCALING];
}

- (double)mouthCoef;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_MOUTH_COEF];
}

- (void)setMouthCoef:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_MOUTH_COEF];
}

- (double)noseCoef;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_NOSE_COEF];
}

- (void)setNoseCoef:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_NOSE_COEF];
}

- (double)mixOffset;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_MIX_OFFSET];
}

- (void)setMixOffset:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_MIX_OFFSET];
}

- (double)n1;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_N1];
}

- (void)setn1:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_N1];
}

- (double)n2;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_N2];
}

- (void)setn2:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_N2];
}

- (double)n3;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_N3];
}

- (void)setn3:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_N3];
}

- (double)n4;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_N4];
}

- (void)setn4:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_N4];
}

- (double)n5;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_N5];
}

- (void)setn5:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_N5];
}

- (double)tp;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_TP];
}

- (void)setTp:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_TP];
}

- (double)tnMin;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_TN_MIN];
}

- (void)setTnMin:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_TN_MIN];
}

- (double)tnMax;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:MDK_TN_MAX];
}

- (void)setTnMax:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:MDK_TN_MAX];
}

- (NSString *)glottalPulseShape;
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:MDK_GP_SHAPE];
}

- (void)setGlottalPulseShape:(NSString *)value;
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:MDK_GP_SHAPE];
}

- (NSString *)noiseModulation;
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:MDK_NOISE_MODULATION];
}

- (void)setNoiseModulation:(NSString *)value;
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:MDK_NOISE_MODULATION];
}

@end
