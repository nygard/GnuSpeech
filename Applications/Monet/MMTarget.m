#import "MMTarget.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"

@implementation MMTarget

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

- (void)changeDefaultValueFrom:(double)oldDefault to:(double)newDefault;
{
    if (value == oldDefault) {
        value = newDefault;
        isDefault = YES;
    }
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: isDefault: %d, value: %g", NSStringFromClass([self class]), self, isDefault, value];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<target ptr=\"%p\" value=\"%g\"/>", self, value];
    if (isDefault)
        [resultString appendString:@"<!-- default -->"];
    [resultString appendString:@"\n"];
}

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
{
    NSString *str;

    str = [[element attributeForName:@"value"] stringValue];
    if (str != nil)
        [self setValue:[str doubleValue]];
}

@end
