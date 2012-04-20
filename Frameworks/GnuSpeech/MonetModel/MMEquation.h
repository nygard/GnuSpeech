//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>
#import "MMObject.h"
#import "MMFRuleSymbols.h"

@class MMFormulaNode, NamedList;

@interface MMEquation : MMObject

- (id)init;
- (id)initWithName:(NSString *)newName;
- (void)dealloc;

- (NamedList *)group;
- (void)setGroup:(NamedList *)newGroup;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (MMFormulaNode *)formula;
- (void)setFormula:(MMFormulaNode *)newFormula;

- (void)setFormulaString:(NSString *)formulaString;

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag;
- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag;
- (double)cacheValue;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (NSString *)equationPath;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
