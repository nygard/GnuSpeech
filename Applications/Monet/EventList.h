#import <Foundation/NSObject.h>

@class Event, MMIntonationPoint, MModel, MMPosture, MMPostureRewriter, MMRule, PhoneList;

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
#define EXCLAMATION	1
#define QUESTION	2
#define CONTINUATION	3
#define SEMICOLON	4

NSString *NSStringFromToneGroupType(int toneGroupType);

struct _intonationParameters {
    float notionalPitch;
    float pretonicRange;
    float pretonicLift;
    float tonicRange;
    float tonicMovement; // TODO (2004-03-30): Apparently not used.
};

struct _phone {
    MMPosture *phone;
    int syllable; // TODO (2004-08-12): This isn't used for anything right now.
    double onset;
    float ruleTempo;
};

struct _foot {
    double onset1;
    double onset2;
    double tempo;
    int start; // index into postures
    int end;   // index into postures
    int marked;
    int last; // Is this the last foot of (the tone group?)
};

struct _toneGroup {
    int startFoot;
    int endFoot;
    int type;
};

// This is used by EventListView, IntonationView
struct _rule {
    int number;
    int firstPhone;
    int lastPhone;
    double duration;
    double beat; // absolute time of beat, in milliseconds
};

extern NSString *EventListDidChangeIntonationPoints;

@interface EventList : NSObject
{
    MModel *model;

    MMPostureRewriter *postureRewriter;

    NSString *phoneString;

    int zeroRef;
    int zeroIndex; // Event index derived from zeroRef.

    int duration; // Move... somewhere else.
    int timeQuantization; // in msecs.  By default it generates parameters every 4 msec

    struct {
        unsigned int shouldStoreParameters:1; // YES -> -generateOutput writes to /tmp/Monet.parameters
        unsigned int shouldUseMacroIntonation:1;
        unsigned int shouldUseMicroIntonation:1;
        unsigned int shouldUseDrift:1;
        unsigned int shouldUseSmoothIntonation:1;
        unsigned int intonationPointsNeedSorting:1;
    } flags;

    double radiusMultiply; // Affects hard coded parameters, in this case r1 and r2.
    double pitchMean;
    double globalTempo;
    double multiplier; // Move... somewhere else.
    struct _intonationParameters intonationParameters;

    /* NOTE phones and phoneTempo are separate for Optimization reasons */
    int postureCount;
    struct _phone phones[MAXPHONES];
    double phoneTempo[MAXPHONES];

    int footCount;
    struct _foot feet[MAXFEET];

    int toneGroupCount;
    struct _toneGroup toneGroups[MAXTONEGROUPS];

    int currentRule;
    struct _rule rules[MAXRULES];

    double min[16]; // Min of each parameter value
    double max[16]; // Max of each parameter value

    NSMutableArray *events;
    NSMutableArray *intonationPoints; // Sorted by absolute time

    id delegate;

    // Hack for inflexible XML parsing.  I have plan to change how I parse XML.
    int parseState;
}

- (id)init;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (NSString *)phoneString;
- (void)_setPhoneString:(NSString *)newPhoneString;

- (int)zeroRef;
- (void)setZeroRef:(int)newValue;

- (int)duration;
- (void)setDuration:(int)newValue;

- (int)timeQuantization;
- (void)setTimeQuantization:(int)newValue;

- (BOOL)shouldStoreParameters;
- (void)setShouldStoreParameters:(BOOL)newFlag;

- (BOOL)shouldUseMacroIntonation;
- (void)setShouldUseMacroIntonation:(BOOL)newFlag;

- (BOOL)shouldUseMicroIntonation;
- (void)setShouldUseMicroIntonation:(BOOL)newFlag;

- (BOOL)shouldUseDrift;
- (void)setShouldUseDrift:(BOOL)newFlag;

- (BOOL)shouldUseSmoothIntonation;
- (void)setShouldUseSmoothIntonation:(BOOL)newValue;

- (double)radiusMultiply;
- (void)setRadiusMultiply:(double)newValue;

- (double)pitchMean;
- (void)setPitchMean:(double)newMean;

- (double)globalTempo;
- (void)setGlobalTempo:(double)newTempo;

- (double)multiplier;
- (void)setMultiplier:(double)newValue;

- (struct _intonationParameters)intonationParameters;
- (void)setIntonationParameters:(struct _intonationParameters)newIntonationParameters;


//
- (void)setUp;
- (void)setFullTimeScale;

// Rules
- (struct _rule *)getRuleAtIndex:(int)ruleIndex;
- (NSString *)ruleDescriptionAtIndex:(int)ruleIndex;
- (double)getBeatAtIndex:(int)ruleIndex;
- (int)ruleCount;
- (void)getRuleIndex:(int *)ruleIndexPtr offsetTime:(double *)offsetTimePtr forAbsoluteTime:(double)absoluteTime;

// Tone groups
- (void)endCurrentToneGroup;
- (void)newToneGroup;
- (void)setCurrentToneGroupType:(int)type;

// Feet
- (void)endCurrentFoot;
- (void)newFoot;
- (void)setCurrentFootMarked;
- (void)setCurrentFootLast;
- (void)setCurrentFootTempo:(double)tempo;

// Postures
- (MMPosture *)getPhoneAtIndex:(int)phoneIndex;
- (void)newPhoneWithObject:(MMPosture *)anObject;
- (void)replaceCurrentPhoneWith:(MMPosture *)anObject;
- (void)setCurrentPhoneTempo:(double)tempo;
- (void)setCurrentPhoneRuleTempo:(float)tempo;
- (void)setCurrentPhoneSyllable;
- (int)ruleIndexForPostureAtIndex:(int)postureIndex;

// Events
- (NSArray *)events;
- (Event *)eventAtTimeOffset:(double)time;
- (Event *)insertEvent:(int)number atTimeOffset:(double)time withValue:(double)value;
- (void)finalEvent:(int)number withValue:(double)value;

// Other
- (void)parsePhoneString:(NSString *)str;
- (void)applyRhythm;
- (void)applyRules;
- (void)generateIntonationPoints;
- (void)generateOutput;

- (void)_applyRule:(MMRule *)rule withPostures:(NSArray *)somePostures andTempos:(double *)tempos phoneIndex:(int)phoneIndex;

// Debugging
- (NSString *)description;
- (void)printDataStructures:(NSString *)comment;

// Intonation points
- (NSArray *)intonationPoints;
- (void)addIntonationPoint:(MMIntonationPoint *)newIntonationPoint;
- (void)removeIntonationPoint:(MMIntonationPoint *)anIntonationPoint;
- (void)removeIntonationPointsFromArray:(NSArray *)someIntonationPoints;
- (void)removeAllIntonationPoints;

// Intonation
- (void)applyIntonation;
- (void)_applyFlatIntonation;
- (void)_applySmoothIntonation;

- (void)clearIntonationEvents;
- (void)clearEventNumber:(int)number;
- (void)removeEmptyEvents;

- (void)intonationPointTimeDidChange:(MMIntonationPoint *)anIntonationPoint;
- (void)intonationPointDidChange:(MMIntonationPoint *)anIntonationPoint;

// Archiving - XML
- (BOOL)writeXMLToFile:(NSString *)aFilename comment:(NSString *)aComment;

- (BOOL)loadIntonationContourFromXMLFile:(NSString *)filename;
- (void)loadStoredPhoneString:(NSString *)aPhoneString;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
