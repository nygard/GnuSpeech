#import "Parameter.h"

#import <Foundation/Foundation.h>

@implementation Parameter

- (id)init;
{
    if ([super init] == nil)
        return nil;

    parameterSymbol = nil;
    comment = nil;

    minimum = 0.0;
    maximum = 0.0;
    defaultValue = 0.0;

    return self;
}

- (id)initWithSymbol:(NSString *)newSymbol;
{
    if ([self init] == nil)
        return nil;

    [self setSymbol:newSymbol];

    return self;
}

- (void)dealloc;
{
    [parameterSymbol release];
    [comment release];

    [super dealloc];
}

- (NSString *)symbol;
{
    return parameterSymbol;
}

- (void)setSymbol:(NSString *)newSymbol;
{
    if (newSymbol == parameterSymbol)
        return;

    [parameterSymbol release];
    parameterSymbol = [newSymbol retain];
}

- (NSString *)comment;
{
    return comment;
}

- (void)setComment:(NSString *)newComment;
{
    if (newComment == comment)
        return;

    [comment release];
    comment = [newComment retain];
}

- (double)minimumValue;
{
    return minimum;
}

- (void)setMinimumValue:(double)newMinimum;
{
    minimum = newMinimum;
}

- (double)maximumValue;
{
    return maximum;
}

- (void)setMaximumValue:(double)newMaximum;
{
    maximum = newMaximum;
}

- (double)defaultValue;
{
    return defaultValue;
}

- (void)setDefaultValue:(double)newDefault;
{
    defaultValue = newDefault;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [aDecoder decodeValuesOfObjCTypes:"**ddd", &parameterSymbol, &comment, &minimum, &maximum, &defaultValue];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeValuesOfObjCTypes:"**ddd", &parameterSymbol, &comment, &minimum, &maximum, &defaultValue];
}

@end
