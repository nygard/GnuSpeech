//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMObject.h"

#import "MMFRuleSymbols.h"

@class MMBooleanNode, MMCategory, MonetList, PhoneList, MMEquation, MMTransition;

@interface MMRule : MMObject
{
    NSMutableArray *parameterTransitions; // Of MMTransitions
    NSMutableArray *metaParameterTransitions; // Of MMTransitions?
    NSMutableArray *symbolEquations; // Of MMEquations

    MMTransition *specialProfiles[16]; // TODO (2004-05-16): We should be able to use an NSMutableDictionary here.

    MMBooleanNode *expressions[4];
    NSString *comment;
}

- (id)init;
- (void)dealloc;

- (void)setDefaultsTo:(NSUInteger)numPhones;
- (void)addDefaultParameter;
- (void)addDefaultMetaParameter;
- (void)removeParameterAtIndex:(NSUInteger)index;
- (void)removeMetaParameterAtIndex:(NSUInteger)index;


- (void)addStoredParameterTransition:(MMTransition *)aTransition;
- (void)addParameterTransitionsFromReferenceDictionary:(NSDictionary *)dict;

- (void)addStoredMetaParameterTransition:(MMTransition *)aTransition;
- (void)addMetaParameterTransitionsFromReferenceDictionary:(NSDictionary *)dict;

- (void)addSpecialProfilesFromReferenceDictionary:(NSDictionary *)dict;

- (void)addStoredSymbolEquation:(MMEquation *)anEquation;
- (void)addSymbolEquationsFromReferenceDictionary:(NSDictionary *)dict;


- (void)setExpression:(MMBooleanNode *)newExpression number:(NSUInteger)index;
- (NSUInteger)numberExpressions;
- (MMBooleanNode *)getExpressionNumber:(NSUInteger)index;

- (void)addBooleanExpression:(MMBooleanNode *)newExpression;
- (void)addBooleanExpressionString:(NSString *)aString;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (BOOL)matchRule:(NSArray *)categories;

- (MMEquation *)getSymbolEquation:(int)index;
- (void)evaluateSymbolEquations:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures withCache:(NSUInteger)cache;

- (NSMutableArray *)parameterTransitions;
- (NSMutableArray *)metaParameterTransitions;
- (NSMutableArray *)symbolEquations;

- (MMTransition *)getSpecialProfile:(NSUInteger)index;
- (void)setSpecialProfile:(NSUInteger)index to:(MMTransition *)special;

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (BOOL)isTransitionUsed:(MMTransition *)aTransition;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)ruleString;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForParameterTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForMetaParameterTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForSpecialProfilesToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForSymbolEquationsToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (NSString *)symbolNameAtIndex:(NSUInteger)index;
- (void)setRuleExpression1:(MMBooleanNode *)exp1 exp2:(MMBooleanNode *)exp2 exp3:(MMBooleanNode *)exp3 exp4:(MMBooleanNode *)exp4;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
