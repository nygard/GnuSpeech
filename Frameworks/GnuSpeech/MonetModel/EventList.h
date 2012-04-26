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


@class MMIntonationParameters;

@interface EventList : NSObject

@property (nonatomic, retain) MModel *model;
@property (weak) id <EventListDelegate> delegate;

@property (assign) NSUInteger duration;
@property (assign) NSUInteger timeQuantization;

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
- (void)newPhoneWithObject:(MMPosture *)object;
- (void)replaceCurrentPhoneWith:(MMPosture *)object;

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
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributes;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@property (readonly) MMDriftGenerator *driftGenerator;

@end

#pragma mark -

@protocol EventListDelegate <NSObject>
- (void)eventListWillGenerateOutput:(EventList *)eventList;
- (void)eventList:(EventList *)eventList generatedOutputValues:(float *)valPtr valueCount:(NSUInteger)count;
- (void)eventListDidGenerateOutput:(EventList *)eventList;
@end

extern NSString *EventListDidChangeIntonationPoints;

