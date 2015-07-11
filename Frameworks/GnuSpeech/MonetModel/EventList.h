//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "MMIntonationPoint.h" // For MMIntonationPointChanges protocol

@class MMIntonationPoint, MModel, MMPosture, MMDriftGenerator;

@class TRMSynthesizer;
@class MMIntonation;

@interface EventList : NSObject <MMIntonationPointChanges>

@property (nonatomic, strong) MModel *model;

@property (strong) MMIntonation *intonation;

- (void)resetWithIntonation:(MMIntonation *)intonation phoneString:(NSString *)phoneString;
- (void)resetWithIntonation:(MMIntonation *)intonation; // TODO (2012-04-26): See if we can't just do this when we apply intonation

// Rules
// TODO: (2015-07-09) Return an immutable copy of the array instead.
@property (readonly) NSMutableArray *appliedRules; // TODO: (2015-07-09) This needs a better name.

- (void)getRuleIndex:(NSUInteger *)ruleIndexPtr offsetTime:(double *)offsetTimePtr forAbsoluteTime:(double)absoluteTime;

// Postures
- (void)newPhoneWithObject:(MMPosture *)object;
- (void)replaceCurrentPhoneWith:(MMPosture *)object;

// Events
@property (nonatomic, readonly) NSArray *events;
- (double)valueAtTimeOffset:(double)time forEvent:(NSInteger)number;
- (void)insertEvent:(NSInteger)number atTimeOffset:(double)time withValue:(double)value;

// Other
- (void)parsePhoneString:(NSString *)str;
- (void)applyRhythm;
- (void)applyRules;
- (void)generateIntonationPoints;
- (void)generateOutputInTimeRange:(NSRange)timeRange forSynthesizer:(TRMSynthesizer *)synthesizer saveParametersToFilename:(NSString *)filename;
- (void)generateOutputInTimeRange:(NSRange)timeRange forSynthesizer:(TRMSynthesizer *)synthesizer;
- (void)generateOutputForSynthesizer:(TRMSynthesizer *)synthesizer;

// Debugging
- (void)printDataStructures:(NSString *)comment;

// Intonation points.  These are kept sorted by time.
- (NSArray *)intonationPoints;
- (void)addIntonationPoint:(MMIntonationPoint *)intonationPoint;
- (void)removeIntonationPoint:(MMIntonationPoint *)intonationPoint;
- (void)removeIntonationPointsFromArray:(NSArray *)array;
- (void)removeAllIntonationPoints;

// Intonation
- (void)applyIntonation;

- (void)clearIntonationEvents;

// Archiving - XML
- (BOOL)writeIntonationContourToXMLFile:(NSString *)filename comment:(NSString *)comment;

- (BOOL)loadIntonationContourFromXMLFile:(NSString *)filename;
- (void)loadStoredPhoneString:(NSString *)str;

@property (readonly) MMDriftGenerator *driftGenerator;

@end

#pragma mark -

extern NSString *EventListDidChangeIntonationPoints;
extern NSString *EventListDidGenerateIntonationPoints;
extern NSString *EventListNotification_DidGenerateOutput;

