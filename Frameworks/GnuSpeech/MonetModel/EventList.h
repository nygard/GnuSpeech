//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class Event, MMIntonationPoint, MModel, MMPosture, MMPostureRewriter, MMRule, MMDriftGenerator;

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

@class MMIntonationParameters;

@interface EventList : NSObject

@property (nonatomic, retain) MModel *model;
@property (retain) id delegate;

@property (retain) NSString *phoneString;


@property (assign) NSUInteger duration;
@property (assign) NSUInteger timeQuantization;

@property (assign) BOOL shouldStoreParameters;
@property (assign) BOOL shouldUseMacroIntonation;
@property (assign) BOOL shouldUseMicroIntonation;
@property (assign) BOOL shouldUseDrift;
@property (assign) BOOL shouldUseSmoothIntonation;

@property (assign) double radiusMultiply;
@property (assign) double pitchMean;
@property (assign) double globalTempo;
@property (assign) double multiplier;

@property (readonly) MMIntonationParameters *intonationParameters;

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

@property (readonly) MMDriftGenerator *driftGenerator;

@end
