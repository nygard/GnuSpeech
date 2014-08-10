//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

#import "MMFRuleSymbols.h"

@class MMBooleanNode, MMCategory, MMEquation, MMTransition;

@interface MMRule : MMNamedObject

- (void)setDefaultsTo:(NSUInteger)numPhones;
- (void)addDefaultTransitionForLastParameter;
- (void)addDefaultTransitionForLastMetaParameter;
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

- (BOOL)matchRule:(NSArray *)categories;

- (MMEquation *)getSymbolEquation:(int)index;
- (void)evaluateSymbolEquationsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols withCacheTag:(NSUInteger)cache;

- (NSMutableArray *)parameterTransitions;
- (NSMutableArray *)metaParameterTransitions;
- (NSMutableArray *)symbolEquations;

- (MMTransition *)getSpecialProfile:(NSUInteger)index;
- (void)setSpecialProfile:(NSUInteger)index to:(MMTransition *)special;

- (BOOL)usesCategory:(MMCategory *)aCategory;
- (BOOL)usesEquation:(MMEquation *)anEquation;
- (BOOL)usesTransition:(MMTransition *)aTransition;

- (NSString *)ruleString;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForParameterTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForMetaParameterTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForSpecialProfilesToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForSymbolEquationsToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (NSString *)symbolNameAtIndex:(NSUInteger)index;
- (void)setRuleExpression1:(MMBooleanNode *)exp1 exp2:(MMBooleanNode *)exp2 exp3:(MMBooleanNode *)exp3 exp4:(MMBooleanNode *)exp4;

@end
