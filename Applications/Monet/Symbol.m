#import "Symbol.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

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

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_symbol, *c_comment;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**ddd", &c_symbol, &c_comment, &minimum, &maximum, &defaultValue];

    symbol = [[NSString stringWithASCIICString:c_symbol] retain];
    comment = [[NSString stringWithASCIICString:c_comment] retain];

    NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
#ifdef PORTING
    [aCoder encodeValuesOfObjCTypes:"**ddd", &symbol, &comment, &minimum, &maximum, &defaultValue];
#endif
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: symbol: %@, comment: %@, minimum: %g, maximum: %g, defaultValue: %g",
                     NSStringFromClass([self class]), self, symbol, comment, minimum, maximum, defaultValue];
}

@end
