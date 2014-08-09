//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMGroupedObject.h"

#import "MMFRuleSymbols.h"

@class MMFormulaNode;

@interface MMEquation : MMGroupedObject

@property (strong) MMFormulaNode *formula;

- (void)setFormulaString:(NSString *)formulaString;

- (double)evaluateWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag;
- (double)cacheValue;

- (NSString *)equationPath;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
