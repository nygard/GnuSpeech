#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface Target : NSObject
{
    BOOL isDefault;
    double value;
}

- (id)init;
- (id)initWithValue:(double)newValue isDefault:(BOOL)shouldBeDefault;

- (double)value;
- (void)setValue:(double)newValue;

- (BOOL)isDefault;
- (void)setIsDefault:(BOOL)newFlag;

- (void)setValue:(double)newValue isDefault:(BOOL)shouldBeDefault;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)description;

@end
