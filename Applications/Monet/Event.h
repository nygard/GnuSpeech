
#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

#define NaN 1.0/0.0

@interface Event:NSObject
{
	int time;
	int flag;
	double events[36];

}

- init;
- (void)setTime:(int)newTime;
- (int) time;
- (void)setFlag:(int)newFlag;
- (int) flag;
- setValue: (double) newValue ofIndex: (int) index;
- (double) getValueAtIndex:(int) index;

@end
