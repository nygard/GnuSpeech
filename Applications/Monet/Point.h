#import <Foundation/NSObject.h>

@class EventList, ProtoEquation;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface GSMPoint : NSObject
{
    double value;  /* Value of the point */
    double freeTime; /* Free Floating time */
    ProtoEquation *expression; /* Time of the point */
    int type;  /* Which phone it is targeting */
    int phantom; /* Phantom point for place marking purposes only */
}

- (id)init;
- (void)dealloc;

- (double)value;
- (void)setValue:(double)newValue;

- (double)multiplyValueByFactor:(double)factor;
- (double)addValue:(double)newValue;

- (ProtoEquation *)expression;
- (void)setExpression:(ProtoEquation *)newExpression;

- (double)freeTime;
- (void)setFreeTime:(double)newTime;

- (double)getTime;

- (int)type;
- (void)setType:(int)newType;

- (int)phantom;
- (void)setPhantom:(int)phantomFlag;

- calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag toDisplay:displayList;

- (double)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
              toEventList:(EventList *)eventList atIndex:(int)index;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

@end
