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
    MonetList *points; // Of GSMPoints
    MonetList *slopes; // Of Slopes
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

- (void)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
              toDisplay:(MonetList *)displayList;

- (double)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)parameterDelta min:(double)min max:(double)max
              toEventList:eventList atIndex:(int)index;

- (double)totalSlopeUnits;
- (void)displaySlopesInList:(MonetList *)displaySlopes;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

@end
