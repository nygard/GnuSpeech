//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>
#import "GSXMLFunctions.h" // To get MMPhoneType

@class MonetList, MMEquation, MMPoint, NamedList;

@interface MMTransition : NSObject

- (id)initWithName:(NSString *)newName;

- (void)addInitialPoint;

@property (weak) NamedList *group;

@property (retain) NSString *name;
@property (retain) NSString *comment;
- (BOOL)hasComment;

@property (retain) NSMutableArray *points;
- (void)addPoint:(id)newPoint;

- (BOOL)isTimeInSlopeRatio:(double)aTime;
- (void)insertPoint:(MMPoint *)aPoint;

@property (assign) MMPhoneType type;

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (NSString *)transitionPath;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
