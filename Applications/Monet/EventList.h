#import "MonetList.h"

@class Event, MMPosture;

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
    MMPosture *phone;
    int syllable;
    double onset;
    float ruleTempo;
};

struct _foot {
    double onset1;
    double onset2;
    double tempo;
    int start;
    int end;
    int marked;
    int last;
};

struct _toneGroup {
    int startFoot;
    int endFoot;
    int type;
};

struct _rule {
    int number;
    int firstPhone;
    int lastPhone;
    double duration;
    double beat;
};


@interface EventList : MonetList
{
    int zeroRef;
    int zeroIndex;
    int duration;
    int timeQuantization;
    int parameterStore;
    int softwareSynthesis;
    int macroFlag;
    int microFlag;
    int driftFlag;
    int smoothIntonation;

    double radiusMultiply;
    double pitchMean;
    double globalTempo;
    double multiplier;
    float *intonParms;

    /* NOTE phones and phoneTempo are separate for Optimization reasons */
    struct _phone phones[MAXPHONES];
    double phoneTempo[MAXPHONES];

    struct _foot feet[MAXFEET];
    struct _toneGroup toneGroups[MAXTONEGROUPS];

    struct _rule rules[MAXRULES];

    int currentPhone;
    int currentFoot;
    int currentToneGroup;

    int currentRule;

    int cache;
    double min[16];
    double max[16];
}

- (id)initWithCapacity:(unsigned int)numSlots;
- (void)dealloc;

- (void)setUp;

- (int)zeroRef;
- (void)setZeroRef:(int)newValue;

- (int)duration;
- (void)setDuration:(int)newValue;

- (double)radiusMultiply;
- (void)setRadiusMultiply:(double)newValue;

- (void)setFullTimeScale;

- (int)timeQuantization;
- (void)setTimeQuantization:(int)newValue;

- (int)parameterStore;
- (void)setParameterStore:(int)newValue;

- (int)softwareSynthesis;
- (void)setSoftwareSynthesis:(int)newValue;

- (double)pitchMean;
- (void)setPitchMean:(double)newMean;

- (double)globalTempo;
- (void)setGlobalTempo:(double)newTempo;

- (double)multiplier;
- (void)setMultiplier:(double)newValue;

- (int)macroIntonation;
- (void)setMacroIntonation:(int)newValue;

- (int)microIntonation;
- (void)setMicroIntonation:(int)newValue;

- (int)drift;
- (void)setDrift:(int)newValue;

- (int)smoothIntonation;
- (void)setSmoothIntonation:(int)newValue;

- (float *)intonParms;
- (void)setIntonParms:(float *)newValue;

- getPhoneAtIndex:(int)phoneIndex;
- (struct _rule *)getRuleAtIndex:(int)ruleIndex;
- (double)getBeatAtIndex:(int)ruleIndex;
- (int)numberOfRules;

/* Data structure maintenance stuff */
- (void)newToneGroup;
- (void)setCurrentToneGroupType:(int)type;

- (void)newFoot;
- (void)setCurrentFootMarked;
- (void)setCurrentFootLast;
- (void)setCurrentFootTempo:(double)tempo;

- (void)newPhone;
- (void)newPhoneWithObject:(id)anObject;
- (void)replaceCurrentPhoneWith:(id)anObject;
- (void)setCurrentPhoneTempo:(double)tempo;
- (void)setCurrentPhoneRuleTempo:(float)tempo;
- (void)setCurrentPhoneSyllable;


- (Event *)insertEvent:(int)number atTime:(double)time withValue:(double)value;
- (void)finalEvent:(int)number withValue:(double)value;
- (Event *)lastEvent;

- (void)generateOutput;
- (void)printDataStructures;
- (void)generateEventList;

- (void)applyRule:rule withPhones:phoneList andTempos:(double *)tempos phoneIndex:(int)phoneIndex;
- (void)synthesizeToFile:(NSString *)filename;

- (void)applyIntonation;

- (NSString *)description;

@end
