
#import "Event.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <math.h>

@implementation Event

- init
{
	time = 0;
	flag = 0;
	events[0] = NaN;
	events[1] = NaN;
	events[2] = NaN;
	events[3] = NaN;
	events[4] = NaN;
	events[5] = NaN;
	events[6] = NaN;
	events[7] = NaN;
	events[8] = NaN;
	events[9] = NaN;
	events[10] = NaN;
	events[11] = NaN;
	events[12] = NaN;
	events[13] = NaN;
	events[14] = NaN;
	events[15] = NaN;
	events[16] = NaN;
	events[17] = NaN;
	events[18] = NaN;
	events[19] = NaN;
	events[20] = NaN;
	events[21] = NaN;
	events[22] = NaN;
	events[23] = NaN;
	events[24] = NaN;
	events[25] = NaN;
	events[26] = NaN;
	events[27] = NaN;
	events[28] = NaN;
	events[29] = NaN;
	events[30] = NaN;
	events[31] = NaN;
	events[32] = NaN;
	events[33] = NaN;
	events[34] = NaN;
	events[35] = NaN;

	return self;
}

- (void)setTime:(int)newTime
{
	time = newTime; 
}

- (int) time
{
	return time;
}

- (void)setFlag:(int)newFlag
{
	flag = newFlag; 
}

- (int) flag
{
	return flag;
}

- setValue: (double) newValue ofIndex: (int) index
{
	if (index<0)
		return self;
	events[index] = newValue;
	return self;
}

- (double) getValueAtIndex:(int) index
{
	return events[index];
}

@end
