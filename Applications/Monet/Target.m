#import "Target.h"

#import <Foundation/Foundation.h>

#ifdef NeXT
#import <objc/typedstream.h>
#endif

@implementation Target

- (id)init;
{
    if ([super init] == nil)
        return nil;

    isDefault = YES;
    value = 0.0;

    return self;
}

- (id)initWithValue:(double)newValue isDefault:(BOOL)shouldBeDefault;
{
    if ([self init] == nil)
        return nil;

    [self setValue:newValue];
    [self setIsDefault:shouldBeDefault];

    return self;
}

- (double)value;
{
    return value;
}

- (void)setValue:(double)newValue;
{
    value = newValue;
}

- (BOOL)isDefault;
{
    return isDefault;
}

- (void)setIsDefault:(BOOL)newFlag;
{
    isDefault = newFlag;
}

- (void)setValue:(double)newValue isDefault:(BOOL)shouldBeDefault;
{
    [self setValue:newValue];
    [self setIsDefault:shouldBeDefault];
}

#ifdef PORTING
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [aDecoder decodeValuesOfObjCTypes:"id", &is_default, &value];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeValuesOfObjCTypes:"id", &is_default, &value];
}
#endif
#ifdef NeXT
- read:(NXTypedStream *)stream
{
        NXReadTypes(stream, "id", &is_default, &value);
        return self;
}
#endif

@end
