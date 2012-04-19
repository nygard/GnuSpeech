//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMTarget.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MXMLParser.h"

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

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    NSUInteger defaultInt;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    /*NSInteger archivedVersion =*/ [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"id", &defaultInt, &value];
    isDefault = defaultInt;

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: isDefault: %d, value: %g", NSStringFromClass([self class]), self, isDefault, value];
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
    NSString *str;

    if ([self init] == nil)
        return nil;

    str = [attributes objectForKey:@"value"];
    if (str != nil)
        [self setValue:[str doubleValue]];

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
