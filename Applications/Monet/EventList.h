
#import "MonetList.h"
#import "Event.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

#define MAXPHONES	1500
#define MAXFEET		110
#define MAXTONEGROUPS	50

#define MAXRULES	MAXPHONES-1

#define STATEMENT	0
#define EXCLAIMATION	1
#define QUESTION	2
#define CONTINUATION	3
#define SEMICOLON	4

struct _phone {
	id	phone;
	int	syllable;
	double	onset;
	float	ruleTempo;
};

struct _foot {
	double	onset1;
	double	onset2;
	double	tempo;
	int	start;
	int	end;
	int	marked;
	int	last;
};

struct _toneGroup {
	int	startFoot;
	int	endFoot;
	int	type;
};

struct _rule {
	int 	number;
	int	firstPhone;
	int	lastPhone;
	double	duration;
	double	beat;
};


@interface EventList:MonetList
{
	int	zeroRef;
	int	zeroIndex;
	int	duration;
	int	timeQuantization;
	int	parameterStore;
	int	softwareSynthesis;
	int	macroFlag;
	int	microFlag;
	int	driftFlag;
	int	smoothIntonation;

	double	radiusMultiply;
	double 	pitchMean;
	double	globalTempo;
	double	multiplier;
	float	*intonParms;

	/* NOTE phones and phoneTempo are separate for Optimization reasons */
	struct _phone phones[MAXPHONES];
	double phoneTempo[MAXPHONES];

	struct _foot feet[MAXFEET];
	struct _toneGroup toneGroups[MAXTONEGROUPS];

	struct _rule rules[MAXRULES];

	int	currentPhone;
	int	currentFoot;
	int	currentToneGroup;

	int	currentRule;

	int	cache;
	double min[16], max[16];
}

- (void)setUp;

- (void)setZeroRef:(int)newValue;
-(int) zeroRef;

- (void)setRadiusMultiply:(double)newValue;
- (double) radiusMultiply;

- (void)setDuration:(int)newValue;
-(int) duration;

- (void)setFullTimeScale;

- (void)setTimeQuantization:(int)newValue;
-(int) timeQuantization;

- (void)setParameterStore:(int)newValue;
-(int) parameterStore;

- (void)setSoftwareSynthesis:(int)newValue;
- (int) softwareSynthesis;

- (void)setPitchMean:(double)newMean;
-(double) pitchMean;

- (void)setGlobalTempo:(double)newTempo;
-(double) globalTempo;
- (void)setMultiplier:(double)newValue;
-(double) multiplier;

- (void)setMacroIntonation:(int)newValue;
-(int) macroIntonation;

- (void)setMicroIntonation:(int)newValue;
-(int) microIntonation;

- (void)setDrift:(int)newValue;
-(int) drift;

- (void)setSmoothIntonation:(int)newValue;
-(int) smoothIntonation;

- (void)setIntonParms:(float *)newValue;
-(float *) intonParms;

- getPhoneAtIndex:(int)phoneIndex;
- (struct _rule *) getRuleAtIndex: (int) ruleIndex;
- (double) getBeatAtIndex:(int) ruleIndex;
- (int) numberOfRules;

/* Data structure maintenance stuff */
- (void)newToneGroup;
- (void)setCurrentToneGroupType:(int)type;

- (void)newFoot;
- (void)setCurrentFootMarked;
- (void)setCurrentFootLast;
- (void)setCurrentFootTempo:(double)tempo;

- (void)newPhone;
- (void)newPhoneWithObject:anObject;
- (void)replaceCurrentPhoneWith:anObject;
- (void)setCurrentPhoneTempo:(double)tempo;
- (void)setCurrentPhoneRuleTempo:(float)tempo;
- (void)setCurrentPhoneSyllable;

- (void)printDataStructures;

- insertEvent:(int) number atTime: (double) time withValue: (double) value;
- finalEvent:(int) number withValue: (double) value;
- lastEvent;

- (void)generateEventList;
- (void)generateOutput;
- (void)synthesizeToFile:(const char *)filename;

- applyRule: rule withPhones: phoneList andTempos: (double *) tempos phoneIndex: (int) phoneIndex ;

- (void)applyIntonation;

@end
