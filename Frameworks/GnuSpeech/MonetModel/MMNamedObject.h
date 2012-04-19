//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import "MMObject.h"
#import <Foundation/NSXMLParser.h>

@interface MMNamedObject : MMObject
{
    NSString *name;
    NSString *comment;
}

- (void)dealloc;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;

@end
