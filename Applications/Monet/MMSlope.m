#import "MMSlope.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@implementation MMSlope

- (id)init;
{
    if ([super init] == nil)
        return nil;

    slope = 0.0;
    displayTime = 0;

    return self;
}

- (double)slope;
{
    return slope;
}

- (void)setSlope:(double)newSlope;
{
    slope = newSlope;
}

- (double)displayTime;
{
    return displayTime;
}

- (void)setDisplayTime:(double)newTime;
{
    displayTime = newTime;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: slope: %g, displayTime: %g",
                     NSStringFromClass([self class]), self, slope, displayTime];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<slope slope=\"%g\" display-time=\"%g\"/>\n", slope, displayTime];
}

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
{
    NSString *str;

    str = [[element attributeForName:@"slope"] stringValue];
    if (str != nil)
        [self setSlope:[str doubleValue]];

    str = [[element attributeForName:@"display-time"] stringValue];
    if (str = nil)
        [self setDisplayTime:[str doubleValue]];
}


@end
