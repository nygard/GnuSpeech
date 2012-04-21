//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "MMFRuleSymbols.h"
#import "EventList.h"

@class MonetList;
@class MMPoint, MMSlope;

@interface MMSlopeRatio : NSObject

- (NSMutableArray *)points;
- (void)setPoints:(NSMutableArray *)newList;
- (void)addPoint:(MMPoint *)newPoint;

@property (retain) NSMutableArray *slopes;
- (void)addSlope:(MMSlope *)newSlope;
- (void)updateSlopes;

- (double)startTime;
- (double)endTime;

- (void)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag
              toDisplay:(MonetList *)displayList;

- (double)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag
                 baseline:(double)baseline delta:(double)parameterDelta min:(double)min max:(double)max
              toEventList:(EventList *)eventList atIndex:(NSUInteger)index;

- (double)totalSlopeUnits;
- (void)displaySlopesInList:(NSMutableArray *)displaySlopes;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
