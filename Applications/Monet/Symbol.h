#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface Symbol : NSObject
{
    NSString *symbol;
    NSString *comment;
    double minimum;
    double maximum;
    double defaultValue;
}

- (id)init;
- (id)initWithSymbol:(NSString *)newSymbol;
- (void)dealloc;

- (NSString *)symbol;
- (void)setSymbol:(NSString *)newSymbol;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;

- (double)minimumValue;
- (void)setMinimumValue:(double)newMinimum;

- (double)maximumValue;
- (void)setMaximumValue:(double)newMaximum;

- (double)defaultValue;
- (void)setDefaultValue:(double)newDefault;

//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
