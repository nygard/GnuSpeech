#import "DefaultMgr.h"

#import <Foundation/Foundation.h>
#import "NSUserDefaults-Extensions.h"
#import "MonetDefaults.h"
#import <math.h>
#ifdef PORTING
#import <Foundation/NSDictionary.h>
#endif

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

@implementation DefaultMgr

+ (void)initialize;
{
    NSDictionary *dict;

    dict = [NSDictionary dictionaryWithObjects:MonetDefVal
                         forKeys:MonetDefKeys
                         count:MonetDefCount];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
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
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_MASTER_VOLUME];
}

- (void)setMasterVolume:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_MASTER_VOLUME];
}

- (double)vocalTractLength;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_VOCAL_TRACT_LENGTH];
}

- (void)setVocalTractLength:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_VOCAL_TRACT_LENGTH];
}

- (double)temperature;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_TEMPERATURE];
}

- (void)setTemperature:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_TEMPERATURE];
}

- (double)balance;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_BALANCE];
}

- (void)setBalance:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_BALANCE];
}

- (double)breathiness;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_BREATHINESS];
}

- (void)setBreathiness:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_BREATHINESS];
}

- (double)lossFactor;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_LOSS_FACTOR];
}

- (void)setLossFactor:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_LOSS_FACTOR];
}

- (double)throatCuttoff;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_THROAT_CUTTOFF];
}

- (void)setThroatCuttoff:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_THROAT_CUTTOFF];
}

- (double)throatVolume;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_THROAT_VOLUME];
}

- (void)setThroatVolume:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_THROAT_VOLUME];
}

- (double)apertureScaling;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_APERTURE_SCALING];
}

- (void)setApertureScaling:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_APERTURE_SCALING];
}

- (double)mouthCoef;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_MOUTH_COEF];
}

- (void)setMouthCoef:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_MOUTH_COEF];
}

- (double)noseCoef;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_NOSE_COEF];
}

- (void)setNoseCoef:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_NOSE_COEF];
}

- (double)mixOffset;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_MIX_OFFSET];
}

- (void)setMixOffset:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_MIX_OFFSET];
}

- (double)n1;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_N1];
}

- (void)setn1:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_N1];
}

- (double)n2;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_N2];
}

- (void)setn2:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_N2];
}

- (double)n3;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_N3];
}

- (void)setn3:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_N3];
}

- (double)n4;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_N4];
}

- (void)setn4:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_N4];
}

- (double)n5;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_N5];
}

- (void)setn5:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_N5];
}

- (double)tp;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_TP];
}

- (void)setTp:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_TP];
}

- (double)tnMin;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_TN_MIN];
}

- (void)setTnMin:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_TN_MIN];
}

- (double)tnMax;
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:NXDEFAULT_TN_MAX];
}

- (void)setTnMax:(double)value;
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:NXDEFAULT_TN_MAX];
}

- (NSString *)glottalPulseShape;
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:NXDEFAULT_GP_SHAPE];
}

- (void)setGlottalPulseShape:(NSString *)value;
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:NXDEFAULT_GP_SHAPE];
}

- (NSString *)noiseModulation;
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:NXDEFAULT_NOISE_MODULATION];
}

- (void)setNoiseModulation:(NSString *)value;
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:NXDEFAULT_NOISE_MODULATION];
}

@end
