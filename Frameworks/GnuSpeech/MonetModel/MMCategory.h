//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

@interface MMCategory : MMNamedObject

@property (assign) BOOL isNative;

- (NSComparisonResult)compareByAscendingName:(MMCategory *)other;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
