
#import <Foundation/NSObject.h>
#import "TargetList.h"
#import "CategoryList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface Parameter:NSObject
{
	char 	*parameterSymbol;
	char	*comment;
	double	minimum;
	double	maximum;
	double	defaultValue;

}

- init;
- initWithSymbol:(const char *) newSymbol;
- (void)dealloc;

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

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
