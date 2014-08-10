//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMParameter.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MModel.h"

#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"

#define DEFAULT_MIN 100.0
#define DEFAULT_MAX 1000.0

@implementation MMParameter
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
        _defaultValue = DEFAULT_MIN;
    }

    return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"parameter" isEqualToString:element.name]);

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

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p>: name: %@, comment: %@, minimum: %g, maximum: %g, defaultValue: %g",
            NSStringFromClass([self class]), self,
            self.name, self.comment, self.minimumValue, self.maximumValue, self.defaultValue];
}


- (void)setDefaultValue:(double)newDefault;
{
    if (newDefault != _defaultValue)
        [[self model] parameter:self willChangeDefaultValue:newDefault];

    _defaultValue = newDefault;
}


- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<parameter name=\"%@\" minimum=\"%g\" maximum=\"%g\" default=\"%g\"",
                  GSXMLAttributeString(self.name, NO), self.minimumValue, self.maximumValue, self.defaultValue];

    if ([self hasComment] == NO) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(self.comment)];

        [resultString indentToLevel:level];
        [resultString appendString:@"</parameter>\n"];
    }
}

#if 0
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    if ((self = [super initWithXMLAttributes:attributes context:context])) {
        id value;
        
        value = [attributes objectForKey:@"minimum"];
        if (value != nil)
            [self setMinimumValue:[value doubleValue]];
        
        value = [attributes objectForKey:@"maximum"];
        if (value != nil)
            [self setMaximumValue:[value doubleValue]];
        
        value = [attributes objectForKey:@"default"];
        if (value != nil)
            [self setDefaultValue:[value doubleValue]];
    }

    return self;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"parameter"])
        [(MXMLParser *)parser popDelegate];
    else
        [NSException raise:@"Unknown close tag" format:@"Unknown closing tag (%@) in %@", elementName, NSStringFromClass([self class])];
}
#endif

@end
