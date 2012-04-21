//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMSlope.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MXMLParser.h"

@implementation MMSlope
{
    double slope;
    double displayTime;
}

- (id)init;
{
    if ((self = [super init])) {
        slope = 0.0;
        displayTime = 0;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> slope: %g, displayTime: %g",
                     NSStringFromClass([self class]), self, slope, displayTime];
}

#pragma mark -

@synthesize slope, displayTime;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<slope slope=\"%g\" display-time=\"%g\"/>\n", slope, displayTime];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    if ((self = [self init])) {
        NSString *str = [attributes objectForKey:@"slope"];
        if (str != nil)
            [self setSlope:[str doubleValue]];
        
        str = [attributes objectForKey:@"display-time"];
        if (str == nil)
            [self setDisplayTime:[str doubleValue]];
    }

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
    [(MXMLParser *)parser skipTree];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

@end
