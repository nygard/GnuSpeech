#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

#define NaN (1.0/0.0)
#define MAX_EVENTS 36

@interface Event : NSObject
{
    int time;
    BOOL flag;
    double events[MAX_EVENTS];
}

- (id)init;

- (int)time;
- (void)setTime:(int)newTime;

- (BOOL)flag;
- (void)setFlag:(BOOL)newFlag;

- (double)getValueAtIndex:(int)index;
- (void)setValue:(double)newValue ofIndex:(int)index;

@end
