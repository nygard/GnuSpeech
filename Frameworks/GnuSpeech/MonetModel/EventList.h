//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class Event, MMIntonationPoint, MModel, MMPosture, MMPostureRewriter, MMRule, PhoneList;

#define MAXPHONES	1500
#define MAXFEET		110
#define MAXTONEGROUPS	50

#define MAXRULES	MAXPHONES-1

#define STATEMENT	    0
#define EXCLAMATION	    1
#define QUESTION	    2
#define CONTINUATION	3
#define SEMICOLON	    4

NSString *NSStringFromToneGroupType(NSUInteger toneGroupType);

struct _intonationParameters {
    float notionalPitch;
    float pretonicRange;
    float pretonicLift;
    float tonicRange;
    float tonicMovement; // TODO (2004-03-30): Apparently not used.
};

struct _phone {
    MMPosture *phone;
    NSUInteger syllable; // TODO (2004-08-12): This isn't used for anything right now.
    double onset;
    float ruleTempo;
};

struct _foot {
    double onset1;
    double onset2;
    double tempo;
    NSUInteger start; // index into postures
    NSUInteger end;   // index into postures
    NSUInteger marked;
    NSUInteger last; // Is this the last foot of (the tone group?)
};

struct _toneGroup {
    NSUInteger startFoot;
    NSUInteger endFoot;
    NSUInteger type;
};

// This is used by EventListView, IntonationView
struct _rule {
    NSUInteger number;
    NSUInteger firstPhone;
    NSUInteger lastPhone;
    double duration;
    double beat; // absolute time of beat, in milliseconds
};

extern NSString *EventListDidChangeIntonationPoints;

@interface EventList : NSObject
{
    MModel *model;

    MMPostureRewriter *postureRewriter;

    NSString *phoneString;

    NSInteger zeroRef;
    NSInteger zeroIndex; // Event index derived from zeroRef.

    NSUInteger duration; // Move... somewhere else.
    NSUInteger timeQuantization; // in msecs.  By default it generates parameters every 4 msec

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
    NSUInteger postureCount;
    struct _phone phones[MAXPHONES];
    double phoneTempo[MAXPHONES];

    NSUInteger footCount;
    struct _foot feet[MAXFEET];

    NSUInteger toneGroupCount;
    struct _toneGroup toneGroups[MAXTONEGROUPS];

    NSUInteger currentRule;
    struct _rule rules[MAXRULES];

    double min[16]; // Min of each parameter value
    double max[16]; // Max of each parameter value

    NSMutableArray *events;
    NSMutableArray *intonationPoints; // Sorted by absolute time

    id delegate;

    // Hack for inflexible XML parsing.  I have plan to change how I parse XML.
    NSUInteger parseState;
}

- (id)init;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (NSString *)phoneString;
- (void)_setPhoneString:(NSString *)newPhoneString;

- (NSInteger)zeroRef;
- (void)setZeroRef:(NSInteger)newValue;

- (NSUInteger)duration;
- (void)setDuration:(NSUInteger)newValue;

- (NSUInteger)timeQuantization;
- (void)setTimeQuantization:(NSUInteger)newValue;

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
- (struct _rule *)getRuleAtIndex:(NSUInteger)ruleIndex;
- (NSString *)ruleDescriptionAtIndex:(NSUInteger)ruleIndex;
- (double)getBeatAtIndex:(NSUInteger)ruleIndex;
- (NSUInteger)ruleCount;
- (void)getRuleIndex:(NSUInteger *)ruleIndexPtr offsetTime:(double *)offsetTimePtr forAbsoluteTime:(double)absoluteTime;

// Tone groups
- (void)endCurrentToneGroup;
- (void)newToneGroup;
- (void)setCurrentToneGroupType:(NSUInteger)type;

// Feet
- (void)endCurrentFoot;
- (void)newFoot;
- (void)setCurrentFootMarked;
- (void)setCurrentFootLast;
- (void)setCurrentFootTempo:(double)tempo;

// Postures
- (MMPosture *)getPhoneAtIndex:(NSUInteger)phoneIndex;
- (void)newPhoneWithObject:(MMPosture *)anObject;
- (void)replaceCurrentPhoneWith:(MMPosture *)anObject;
- (void)setCurrentPhoneTempo:(double)tempo;
- (void)setCurrentPhoneRuleTempo:(float)tempo;
- (void)setCurrentPhoneSyllable;
- (NSUInteger)ruleIndexForPostureAtIndex:(NSUInteger)postureIndex;

// Events
- (NSArray *)events;
- (Event *)eventAtTimeOffset:(double)time;
- (Event *)insertEvent:(NSInteger)number atTimeOffset:(double)time withValue:(double)value;
- (void)finalEvent:(NSUInteger)number withValue:(double)value;

// Other
- (void)parsePhoneString:(NSString *)str;
- (void)applyRhythm;
- (void)applyRules;
- (void)generateIntonationPoints;
- (void)generateOutput;

- (void)_applyRule:(MMRule *)rule withPostures:(NSArray *)somePostures andTempos:(double *)tempos phoneIndex:(NSUInteger)phoneIndex;

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
- (void)clearEventNumber:(NSUInteger)number;
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
