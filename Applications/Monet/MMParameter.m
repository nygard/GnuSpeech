#import "MMParameter.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MModel.h"

#define DEFAULT_MIN 100.0
#define DEFAULT_MAX 1000.0

@implementation MMParameter

- (id)init;
{
    if ([super init] == nil)
        return nil;

    minimum = DEFAULT_MIN;
    maximum = DEFAULT_MAX;
    defaultValue = DEFAULT_MIN;

    return self;
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
    if (newDefault != defaultValue)
        [[self model] parameter:self willChangeDefaultValue:newDefault];

    defaultValue = newDefault;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@, minimum: %g, maximum: %g, defaultValue: %g",
                     NSStringFromClass([self class]), self, name, comment, minimum, maximum, defaultValue];
}


- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<parameter name=\"%@\" minimum=\"%g\" maximum=\"%g\" default=\"%g\"",
                  GSXMLAttributeString(name, NO), minimum, maximum, defaultValue];

    if ([self hasComment] == NO) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];

        [resultString indentToLevel:level];
        [resultString appendString:@"</parameter>\n"];
    }
}

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
{
    id value;

    [super loadFromXMLElement:element context:context];

    value = [[element attributeForName:@"minimum"] stringValue];
    if (value != nil)
        [self setMinimumValue:[value doubleValue]];

    value = [[element attributeForName:@"maximum"] stringValue];
    if (value != nil)
        [self setMaximumValue:[value doubleValue]];

    value = [[element attributeForName:@"default"] stringValue];
    if (value != nil)
        [self setDefaultValue:[value doubleValue]];
}

@end
