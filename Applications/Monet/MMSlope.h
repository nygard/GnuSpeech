#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMSlope : NSObject
{
    double slope;
    double displayTime;
}

- (id)init;

- (double)slope;
- (void)setSlope:(double)newSlope;

- (double)displayTime;
- (void)setDisplayTime:(double)newTime;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;

@end
