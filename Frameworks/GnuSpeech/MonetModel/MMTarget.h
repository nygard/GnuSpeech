//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSObject.h>

@class NSDictionary, NSMutableString, NSXMLParser;

@interface MMTarget : NSObject
{
    BOOL isDefault;
    double value;
}

- (id)init;
- (id)initWithValue:(double)newValue isDefault:(BOOL)shouldBeDefault;

- (double)value;
- (void)setValue:(double)newValue;

- (BOOL)isDefault;
- (void)setIsDefault:(BOOL)newFlag;

- (void)setValue:(double)newValue isDefault:(BOOL)shouldBeDefault;
- (void)changeDefaultValueFrom:(double)oldDefault to:(double)newDefault;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
