//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "MMFRuleSymbols.h"
#import "EventList.h"

@class MMPoint, MMSlope;

@interface MMSlopeRatio : NSObject

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;

- (NSMutableArray *)points;
- (void)setPoints:(NSMutableArray *)newList;
- (void)addPoint:(MMPoint *)newPoint;

@property (strong) NSMutableArray *slopes;
- (void)addSlope:(MMSlope *)newSlope;
- (void)updateSlopes;

- (double)startTime;
- (double)endTime;

// Used by TransitionView
- (void)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag andAddToDisplay:(NSMutableArray *)displayList;

// Used by ???
- (double)calculatePointsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag
                                  baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
                         andAddToEventList:(EventList *)eventList atIndex:(NSUInteger)index;

- (double)totalSlopeUnits;
- (void)displaySlopesInList:(NSMutableArray *)displaySlopes;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

@end
