#import <Foundation/NSObject.h>

@class MonetList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface SlopeRatio : NSObject
{
    MonetList *points;
    MonetList *slopes;
}

- (id)init;
- (void)dealloc;

- (MonetList *)points;
- (void)setPoints:(MonetList *)newList;

- (MonetList *)slopes;
- (void)setSlopes:(MonetList *)newList;
- (void)updateSlopes;

- (double)startTime;
- (double)endTime;


- calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
        toDisplay:displayList ;

- (double)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)parameterDelta min:(double)min max:(double)max
              toEventList:eventList atIndex:(int)index;

- (double)totalSlopeUnits;
- (void)displaySlopesInList:(MonetList *)displaySlopes;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)description;

@end
