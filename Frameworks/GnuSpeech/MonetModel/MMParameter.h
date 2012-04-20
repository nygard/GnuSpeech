//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

@interface MMParameter : MMNamedObject

- (id)init;

- (double)minimumValue;
- (void)setMinimumValue:(double)newMinimum;

- (double)maximumValue;
- (void)setMaximumValue:(double)newMaximum;

- (double)defaultValue;
- (void)setDefaultValue:(double)newDefault;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
