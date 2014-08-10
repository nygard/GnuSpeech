//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMSlope.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"

@implementation MMSlope
{
    double _slope;
    double _displayTime;
}

- (id)init;
{
    if ((self = [super init])) {
        _slope = 0.0;
        _displayTime = 0;
    }

    return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"slope" isEqualToString:element.name]);
    
    if ((self = [super init])) {
        _slope = 0.0;
        _displayTime = 0;

        NSString *str;
        str = [[element attributeForName:@"slope"] stringValue];
        if (str != nil)
            [self setSlope:[str doubleValue]];

        str = [[element attributeForName:@"display-time"] stringValue];
        if (str == nil)
            [self setDisplayTime:[str doubleValue]];
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> slope: %g, displayTime: %g",
                     NSStringFromClass([self class]), self, _slope, _displayTime];
}

#pragma mark -

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<slope slope=\"%g\" display-time=\"%g\"/>\n", _slope, _displayTime];
}

@end
