//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class Event, MMIntonationPoint, MModel, MMPosture, MMPostureRewriter, MMRule, MMDriftGenerator;

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

- (void)setUp;

// Rules
- (struct _rule *)getRuleAtIndex:(NSUInteger)ruleIndex;
- (NSString *)ruleDescriptionAtIndex:(NSUInteger)ruleIndex;
- (double)getBeatAtIndex:(NSUInteger)ruleIndex;
- (NSUInteger)ruleCount;
- (void)getRuleIndex:(NSUInteger *)ruleIndexPtr offsetTime:(double *)offsetTimePtr forAbsoluteTime:(double)absoluteTime;

// Postures
- (MMPosture *)getPhoneAtIndex:(NSUInteger)phoneIndex;
- (void)newPhoneWithObject:(MMPosture *)anObject;
- (void)replaceCurrentPhoneWith:(MMPosture *)anObject;

// Events
- (NSArray *)events;
- (Event *)insertEvent:(NSInteger)number atTimeOffset:(double)time withValue:(double)value;

// Other
- (void)parsePhoneString:(NSString *)str;
- (void)applyRhythm;
- (void)applyRules;
- (void)generateIntonationPoints;
- (void)generateOutput;

// Debugging
- (void)printDataStructures:(NSString *)comment;

// Intonation points
- (NSArray *)intonationPoints;
- (void)addIntonationPoint:(MMIntonationPoint *)newIntonationPoint;
- (void)removeIntonationPoint:(MMIntonationPoint *)anIntonationPoint;
- (void)removeIntonationPointsFromArray:(NSArray *)someIntonationPoints;
- (void)removeAllIntonationPoints;

// Intonation
- (void)applyIntonation;

- (void)clearIntonationEvents;

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
