//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMSymbol.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MModel.h"

#define DEFAULT_VALUE 100.0
#define DEFAULT_MIN 0.0
#define DEFAULT_MAX 500.0

@implementation MMSymbol
{
    double _minimumValue;
    double _maximumValue;
    double _defaultValue;
}

- (id)init;
{
    if ((self = [super init])) {
        _minimumValue = DEFAULT_MIN;
        _maximumValue = DEFAULT_MAX;
        _defaultValue = DEFAULT_VALUE;
    }

    return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"symbol" isEqualToString:element.name]);

    if ((self = [super initWithXMLElement:element error:error])) {
        id value;

        value = [[element attributeForName:@"minimum"] stringValue];
        _minimumValue = (value != nil) ? [value doubleValue] : DEFAULT_MIN;

        value = [[element attributeForName:@"maximum"] stringValue];
        _maximumValue = (value != nil) ? [value doubleValue] : DEFAULT_MAX;

        value = [[element attributeForName:@"default"] stringValue];
        _defaultValue = (value != nil) ? [value doubleValue] : DEFAULT_MIN;
    }
    
    return self;
}

- (void)setDefaultValue:(double)newDefault;
{
    if (newDefault != _defaultValue)
        [[self model] symbol:self willChangeDefaultValue:newDefault];

    _defaultValue = newDefault;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@, minimum: %g, maximum: %g, defaultValue: %g",
                     NSStringFromClass([self class]), self, self.name, self.comment, self.minimumValue, self.maximumValue, self.defaultValue];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<symbol name=\"%@\" minimum=\"%g\" maximum=\"%g\" default=\"%g\"",
                  GSXMLAttributeString(self.name, NO), self.minimumValue, self.maximumValue, self.defaultValue];

    if (self.comment == nil) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(self.comment)];

        [resultString indentToLevel:level];
        [resultString appendString:@"</symbol>\n"];
    }
}

@end
