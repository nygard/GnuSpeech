#import <Foundation/NSObject.h>

#import "MMFRuleSymbols.h"

@class MonetList;
@class MMPoint, MMSlope;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMSlopeRatio : NSObject
{
    NSMutableArray *points; // Of MMPoints
    NSMutableArray *slopes; // Of MMSlopes
}

- (id)init;
- (void)dealloc;

- (NSMutableArray *)points;
- (void)setPoints:(NSMutableArray *)newList;
- (void)addPoint:(MMPoint *)newPoint;

- (NSMutableArray *)slopes;
- (void)setSlopes:(NSMutableArray *)newList;
- (void)addSlope:(MMSlope *)newSlope;
- (void)updateSlopes;

- (double)startTime;
- (double)endTime;

- (void)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(int)newCacheTag
              toDisplay:(MonetList *)displayList;

- (double)calculatePoints:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)parameterDelta min:(double)min max:(double)max
              toEventList:eventList atIndex:(int)index;

- (double)totalSlopeUnits;
- (void)displaySlopesInList:(NSMutableArray *)displaySlopes;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
- (void)_loadPointsFromXMLElement:(NSXMLElement *)element context:(id)context;
- (void)_loadSlopesFromXMLElement:(NSXMLElement *)element context:(id)context;

@end
