
#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface IntonationPoint:NSObject
{
	double	semitone;	/* Value of the in semitones */
	double	offsetTime;	/* Points are timed wrt a beat + this offset */
	double	slope;		/* Slope of point */
	int	ruleIndex;	/* Index of phone which is the focus of this point */
	id	eventList;	/* Current EventList */
}

- init;
- initWithEventList: aList;

- (void)setEventList:aList;
- eventList;

- (void)setSemitone:(double)newValue;
- (double) semitone;

- (void)setOffsetTime:(double)newValue;
- (double) offsetTime;

- (void)setSlope:(double)newValue;
- (double) slope;

- (void)setRuleIndex:(int)newIndex;
- (int) ruleIndex;

- (double) absoluteTime;
- (double) beatTime;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
