
#import "DefaultMgr.h"
#import "MonetDefaults.h"
#import <Foundation/NSDictionary.h>
#import <string.h>
#import <stdlib.h>
#import <math.h>
	
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

+ (void)initialize
{
	NSDictionary *dict;
	dict = [NSDictionary dictionaryWithObjects: MonetDefVal
			     forKeys: MonetDefKeys
			     count: MonetDefCount];
	[[NSUserDefaults standardUserDefaults] registerDefaults: dict];
	return;
}

- (void)updateDefaults
{
	[[NSUserDefaults standardUserDefaults] synchronize]; 
}

- (void)writeDefaults
{
	int i;
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	for (i = 0; i < MonetDefCount; i++)
	  [def setObject: MonetDefVal[i] forKey: MonetDefKeys[i]];
}

- (void)setMasterVolume:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey: NXDEFAULT_MASTER_VOLUME]; 
}

- (double) masterVolume
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_MASTER_VOLUME] doubleValue]);
}

- (void)setVocalTractLength:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey: NXDEFAULT_VOCAL_TRACT_LENGTH]; 
}

- (double) vocalTractLength
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_VOCAL_TRACT_LENGTH] doubleValue]);
}

- (void)setTemperature:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey: NXDEFAULT_TEMPERATURE]; 
}

- (double) temperature
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_TEMPERATURE] doubleValue]);
}

- (void)setBalance:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey: NXDEFAULT_BALANCE]; 
}

- (double) balance
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_BALANCE] doubleValue]);
}

- (void)setBreathiness:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey: NXDEFAULT_BREATHINESS]; 
}

- (double) breathiness
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_BREATHINESS] doubleValue]);
}

- (void)setLossFactor:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_LOSS_FACTOR]; 
}

- (double) lossFactor
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_LOSS_FACTOR] doubleValue]);
}

- (void)setThroatCuttoff:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_THROAT_CUTTOFF]; 
}

- (double) throatCuttoff
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_THROAT_CUTTOFF] doubleValue]);
}

- (void)setThroatVolume:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_THROAT_VOLUME]; 
}

- (double) throatVolume
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_THROAT_VOLUME] doubleValue]);
}

- (void)setApertureScaling:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_APERTURE_SCALING]; 
}

- (double) apertureScaling
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_APERTURE_SCALING] doubleValue]);
}

- (void)setMouthCoef:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_MOUTH_COEF]; 
}

- (double) mouthCoef
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_MOUTH_COEF] doubleValue]);
}

- (void)setNoseCoef:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_NOSE_COEF]; 
}

- (double) noseCoef
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_NOSE_COEF] doubleValue]);
}

- (void)setMixOffset:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_MIX_OFFSET]; 
}

- (double) mixOffset
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_MIX_OFFSET] doubleValue]);
}

- (void)setn1:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_N1]; 
}

- (double) n1
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_N1] doubleValue]);
}

- (void)setn2:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_N2]; 
}

- (double) n2
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_N2] doubleValue]);
}

- (void)setn3:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_N3]; 
}

- (double) n3
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_N3] doubleValue]);
}

- (void)setn4:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_N4]; 
}

- (double) n4
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_N4] doubleValue]);
}

- (void)setn5:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_N5]; 
}

- (double) n5
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_N5] doubleValue]);
}

- (void)setTp:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_TP]; 
}

- (double) tp
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_TP] doubleValue]);
}

- (void)setTnMin:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_TN_MIN]; 
}

- (double) tnMin
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_TN_MIN] doubleValue]);
}

- (void)setTnMax:(double)value
{
char temp[15];

	sprintf(temp,"%f", value);
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:temp] forKey:NXDEFAULT_TN_MAX]; 
}

- (double) tnMax
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_TN_MAX] doubleValue]);
}

- (void)setGlottalPulseShape:(const char *)value
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:value] forKey:NXDEFAULT_GP_SHAPE]; 
}

- (const char *) glottalPulseShape
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_GP_SHAPE] cString]);
}

- (void)setNoiseModulation:(const char *)value
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:value] forKey:NXDEFAULT_NOISE_MODULATION]; 
}

- (const char *) noiseModulation
{
	return ([[[NSUserDefaults standardUserDefaults] 
		objectForKey: NXDEFAULT_NOISE_MODULATION] cString]);
}


@end
