//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "GSXMLFunctions.h" // For MMPhoneType
#import "MMFRuleSymbols.h"

@class EventList, MonetList, MMEquation;

@interface MMPoint : NSObject

- (id)init;
- (void)dealloc;

- (double)value;
- (void)setValue:(double)newValue;

- (double)multiplyValueByFactor:(double)factor;
- (double)addValue:(double)newValue;

- (MMEquation *)timeEquation;
- (void)setTimeEquation:(MMEquation *)newTimeEquation;

- (double)freeTime;
- (void)setFreeTime:(double)newTime;

- (double)cachedTime;

- (NSUInteger)type;
- (void)setType:(NSUInteger)newType;

- (BOOL)isPhantom;
- (void)setIsPhantom:(BOOL)newFlag;

- (void)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag toDisplay:(NSMutableArray *)displayList;

- (double)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag
                 baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
              toEventList:(EventList *)eventList atIndex:(NSUInteger)index;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

- (NSComparisonResult)compareByAscendingCachedTime:(MMPoint *)otherPoint;

@end
