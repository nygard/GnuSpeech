#import <Foundation/NSObject.h>

@class EventList, MonetList, MMEquation;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMPoint : NSObject
{
    double value;  /* Value of the point */
    double freeTime; /* Free Floating time */
    MMEquation *expression; /* Time of the point */
    int type;  /* Which phone it is targeting */
    BOOL isPhantom; /* Phantom point for place marking purposes only */
}

- (id)init;
- (void)dealloc;

- (double)value;
- (void)setValue:(double)newValue;

- (double)multiplyValueByFactor:(double)factor;
- (double)addValue:(double)newValue;

- (MMEquation *)expression;
- (void)setExpression:(MMEquation *)newExpression;

- (double)freeTime;
- (void)setFreeTime:(double)newTime;

- (double)getTime;

- (int)type;
- (void)setType:(int)newType;

- (BOOL)isPhantom;
- (void)setIsPhantom:(BOOL)newFlag;

- (void)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag toDisplay:(MonetList *)displayList;

- (double)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
              toEventList:(EventList *)eventList atIndex:(int)index;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

@end
