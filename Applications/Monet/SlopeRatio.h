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
	MonetList	*points;
	MonetList	*slopes;
}

- init;

- (void)setPoints:newList;
- points;
- (void)setSlopes:newList;
- slopes;
- (void)updateSlopes;

- (double) startTime;
- (double) endTime;


- calculatePoints: (double *) ruleSymbols tempos: (double *) tempos phones: phones andCacheWith: (int) newCacheTag
        toDisplay: displayList ;

- (double) calculatePoints: (double *) ruleSymbols tempos: (double *) tempos phones: phones andCacheWith: (int) newCacheTag
	baseline: (double) baseline delta: (double) delta min: (double) min max:(double) max
	toEventList: eventList atIndex: (int) index;

- (double)totalSlopeUnits;
- (void)displaySlopesInList:(MonetList *)displaySlopes;


- (void)dealloc;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
