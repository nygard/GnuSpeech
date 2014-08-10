//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMTarget.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"

@implementation MMTarget
{
    BOOL _isDefault;
    double _value;
}

- (id)init;
{
    if ((self = [super init])) {
        _isDefault = YES;
        _value = 0.0;
    }

    return self;
}

- (id)initWithValue:(double)newValue isDefault:(BOOL)shouldBeDefault;
{
    if ((self = [self init])) {
        [self setValue:newValue];
        [self setIsDefault:shouldBeDefault];
    }

    return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    if ((self = [super init])) {
        _isDefault = NO;

        NSString *str = [[element attributeForName:@"value"] stringValue];
        _value = (str != nil) ? [str doubleValue] : 0;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> isDefault: %d, value: %g", NSStringFromClass([self class]), self, _isDefault, _value];
}

#pragma mark -

- (void)setValue:(double)newValue isDefault:(BOOL)shouldBeDefault;
{
    [self setValue:newValue];
    [self setIsDefault:shouldBeDefault];
}

- (void)changeDefaultValueFrom:(double)oldDefault to:(double)newDefault;
{
    if (_value == oldDefault) {
        _value = newDefault;
        _isDefault = YES;
    }
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<target ptr=\"%p\" value=\"%g\"/>", self, _value];
    if (_isDefault)
        [resultString appendString:@"<!-- default -->"];
    [resultString appendString:@"\n"];
}

@end
