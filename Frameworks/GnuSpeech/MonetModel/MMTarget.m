//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMTarget.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MXMLParser.h"

@implementation MMTarget
{
    BOOL isDefault;
    double value;
}

- (id)init;
{
    if ((self = [super init])) {
        isDefault = YES;
        value = 0.0;
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

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> isDefault: %d, value: %g", NSStringFromClass([self class]), self, isDefault, value];
}

#pragma mark -

@synthesize value, isDefault;

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

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<target ptr=\"%p\" value=\"%g\"/>", self, value];
    if (isDefault)
        [resultString appendString:@"<!-- default -->"];
    [resultString appendString:@"\n"];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    if ((self = [self init])) {
        NSString *str = [attributes objectForKey:@"value"];
        if (str != nil)
            [self setValue:[str doubleValue]];
    }

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    NSLog(@"%@: skipping element: %@", NSStringFromClass([self class]), anElementName);
    [(MXMLParser *)parser skipTree];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

@end
