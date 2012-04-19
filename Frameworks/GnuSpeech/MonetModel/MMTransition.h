//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSObject.h>
#import "GSXMLFunctions.h" // To get MMPhoneType

@class MonetList, MMEquation, MMPoint, NamedList;

@interface MMTransition : NSObject
{
    NamedList *nonretained_group;

    NSString *name;
    NSString *comment;
    MMPhoneType type;
    NSMutableArray *points; // Of MMSlopeRatios and/or MMPoints
}

- (id)init;
- (id)initWithName:(NSString *)newName;
- (void)dealloc;

- (void)addInitialPoint;

- (NamedList *)group;
- (void)setGroup:(NamedList *)newGroup;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (NSMutableArray *)points;
- (void)setPoints:(NSMutableArray *)newList;
- (void)addPoint:(id)newPoint;

- (BOOL)isTimeInSlopeRatio:(double)aTime;
- (void)insertPoint:(MMPoint *)aPoint;

- (int)type;
- (void)setType:(int)type;

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (NSString *)transitionPath;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
