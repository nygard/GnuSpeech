//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"
#import "MMFRuleSymbols.h"

@class MMFormulaNode, NamedList;

@interface MMEquation : MMNamedObject

@property (weak) NamedList *group;

@property (retain) MMFormulaNode *formula;

- (void)setFormulaString:(NSString *)formulaString;

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag;
- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag;
- (double)cacheValue;

- (NSString *)equationPath;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
