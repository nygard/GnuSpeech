#import "Target.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"

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

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"id", &isDefault, &value];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
#ifdef PORTING
    [aCoder encodeValuesOfObjCTypes:"id", &isDefault, &value];
#endif
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: isDefault: %d, value: %g", NSStringFromClass([self class]), self, isDefault, value];
}

@end
