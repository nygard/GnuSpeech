
#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface Target:NSObject
{
	int is_default;
	double value;
}

- init;
- initWithValue:(double) newValue isDefault:(int) isDefault;
- (void)setValue:(double)newValue;
- (double) value;
- (void)setDefault:(int)isDefault;
- (int)isDefault;
- setValue:(double) newValue isDefault:(int) isDefault;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
