
#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface Symbol:NSObject
{
	char *symbol;
	char *comment;
	double minimum;
	double maximum;
	double defaultValue;
}

- init;
- initWithSymbol:(const char *) newSymbol;

- (void)setSymbol:(const char *)newSymbol;
- (const char *)symbol;

- (void)setComment:(const char *)newComment;
- (const char *) comment;

- (void)setMinimumValue:(double)newMinimum;
- (double) minimumValue;

- (void)setMaximumValue:(double)newMaximum;
- (double) maximumValue;

- (void)setDefaultValue:(double)newDefault;
- (double) defaultValue;

- (void)dealloc;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
