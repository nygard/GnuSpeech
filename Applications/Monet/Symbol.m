#import "Symbol.h"

#import <Foundation/Foundation.h>
#import "AppController.h"

@implementation Symbol

- (id)init;
{
    if ([super init] == nil)
        return nil;

    symbol = nil;
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
    [symbol release];
    [comment release];

    [super dealloc];
}

- (NSString *)symbol;
{
    return symbol;
}

- (void)setSymbol:(NSString *)newSymbol;
{
    if (newSymbol == symbol)
        return;

    [symbol release];
    symbol = [newSymbol retain];
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
    [aDecoder decodeValuesOfObjCTypes:"**ddd", &symbol, &comment, &minimum, &maximum, &defaultValue];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeValuesOfObjCTypes:"**ddd", &symbol, &comment, &minimum, &maximum, &defaultValue];
}

@end
