#import "MMNamedObject.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMParameter : MMNamedObject
{
    double minimum;
    double maximum;
    double defaultValue;
}

- (id)init;

- (double)minimumValue;
- (void)setMinimumValue:(double)newMinimum;

- (double)maximumValue;
- (void)setMaximumValue:(double)newMaximum;

- (double)defaultValue;
- (void)setDefaultValue:(double)newDefault;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;

@end
