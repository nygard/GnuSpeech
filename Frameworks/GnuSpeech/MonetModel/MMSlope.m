//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMSlope.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MXMLParser.h"

@implementation MMSlope

- (id)init;
{
    if ([super init] == nil)
        return nil;

    slope = 0.0;
    displayTime = 0;

    return self;
}

- (double)slope;
{
    return slope;
}

- (void)setSlope:(double)newSlope;
{
    slope = newSlope;
}

- (double)displayTime;
{
    return displayTime;
}

- (void)setDisplayTime:(double)newTime;
{
    displayTime = newTime;
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    /*NSInteger archivedVersion =*/ [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValueOfObjCType:@encode(double) at:&slope];
    //NSLog(@"slope: %g", slope);
    displayTime = 0;

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: slope: %g, displayTime: %g",
                     NSStringFromClass([self class]), self, slope, displayTime];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<slope slope=\"%g\" display-time=\"%g\"/>\n", slope, displayTime];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    NSString *str;

    if ([self init] == nil)
        return nil;

    str = [attributes objectForKey:@"slope"];
    if (str != nil)
        [self setSlope:[str doubleValue]];

    str = [attributes objectForKey:@"display-time"];
    if (str == nil)
        [self setDisplayTime:[str doubleValue]];

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
