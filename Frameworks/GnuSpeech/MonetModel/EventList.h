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

@protocol EventListDelegate;


@class MMIntonation;

@interface EventList : NSObject

@property (nonatomic, strong) MModel *model;
@property (weak) id <EventListDelegate> delegate;

@property (strong) MMIntonation *intonation;

- (void)resetWithIntonation:(MMIntonation *)intonation; // TODO (2012-04-26): See if we can't just do this when we apply intonation

// Rules
- (struct _rule *)getRuleAtIndex:(NSUInteger)ruleIndex;
- (NSString *)ruleDescriptionAtIndex:(NSUInteger)ruleIndex;
- (double)getBeatAtIndex:(NSUInteger)ruleIndex;
- (NSUInteger)ruleCount;
- (void)getRuleIndex:(NSUInteger *)ruleIndexPtr offsetTime:(double *)offsetTimePtr forAbsoluteTime:(double)absoluteTime;

// Postures
- (MMPosture *)getPhoneAtIndex:(NSUInteger)phoneIndex;
- (void)newPhoneWithObject:(MMPosture *)object;
- (void)replaceCurrentPhoneWith:(MMPosture *)object;

// Events
- (NSArray *)events;
- (void)insertEvent:(NSInteger)number atTimeOffset:(double)time withValue:(double)value;

// Other
- (void)parsePhoneString:(NSString *)str;
- (void)applyRhythm;
- (void)applyRules;
- (void)generateIntonationPoints;
- (void)generateOutput;

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

- (void)intonationPointTimeDidChange:(MMIntonationPoint *)intonationPoint;
- (void)intonationPointDidChange:(MMIntonationPoint *)intonationPoint;

// Archiving - XML
- (BOOL)writeXMLToFile:(NSString *)filename comment:(NSString *)comment;

- (BOOL)loadIntonationContourFromXMLFile:(NSString *)filename;
- (void)loadStoredPhoneString:(NSString *)str;

@property (readonly) MMDriftGenerator *driftGenerator;

@end

#pragma mark -

@protocol EventListDelegate <NSObject>
- (void)eventListWillGenerateOutput:(EventList *)eventList;
- (void)eventList:(EventList *)eventList generatedOutputValues:(float *)valPtr valueCount:(NSUInteger)count;
- (void)eventListDidGenerateOutput:(EventList *)eventList;
@end

extern NSString *EventListDidChangeIntonationPoints;
extern NSString *EventListDidGenerateIntonationPoints;

