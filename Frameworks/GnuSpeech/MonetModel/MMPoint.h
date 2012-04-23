//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "GSXMLFunctions.h" // For MMPhoneType
#import "MMFRuleSymbols.h"

@class EventList, MMEquation;

@interface MMPoint : NSObject

@property (assign) double value;

- (double)multiplyValueByFactor:(double)factor;
- (double)addValue:(double)newValue;

@property (retain) MMEquation *timeEquation;
@property (assign) double freeTime;

- (double)cachedTime;

@property (assign) NSUInteger type;
@property (assign) BOOL isPhantom;

- (void)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag toDisplay:(NSMutableArray *)displayList;

- (double)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag
                 baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
              toEventList:(EventList *)eventList atIndex:(NSUInteger)index;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

- (NSComparisonResult)compareByAscendingCachedTime:(MMPoint *)otherPoint;

@end
