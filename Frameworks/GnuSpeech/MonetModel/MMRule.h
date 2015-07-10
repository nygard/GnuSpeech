//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

#import "NSObject-Extensions.h"

@class MMBooleanNode, MMCategory, MMEquation, MMTransition, MMFRuleSymbols;

@interface MMRule : MMNamedObject <GSXMLArchiving>

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;

- (void)setDefaults;
- (void)addDefaultTransitionForLastParameter;
- (void)addDefaultTransitionForLastMetaParameter;
- (void)removeParameterAtIndex:(NSUInteger)index;
- (void)removeMetaParameterAtIndex:(NSUInteger)index;


- (void)addStoredParameterTransition:(MMTransition *)transition;
- (void)addParameterTransitionsFromReferenceDictionary:(NSDictionary *)dict;

- (void)addStoredMetaParameterTransition:(MMTransition *)transition;
- (void)addMetaParameterTransitionsFromReferenceDictionary:(NSDictionary *)dict;

- (void)addSpecialProfilesFromReferenceDictionary:(NSDictionary *)dict;

- (void)addStoredSymbolEquation:(MMEquation *)equation;
- (void)addSymbolEquationsFromReferenceDictionary:(NSDictionary *)dict;


- (void)setExpression:(MMBooleanNode *)newExpression number:(NSUInteger)index;
- (NSUInteger)expressionCount;
- (MMBooleanNode *)getExpressionNumber:(NSUInteger)index;

- (void)addBooleanExpression:(MMBooleanNode *)newExpression;
- (void)addBooleanExpressionString:(NSString *)string;

- (BOOL)matchRule:(NSArray *)categories;

- (MMEquation *)getSymbolEquation:(int)index;
- (void)evaluateSymbolEquationsWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols withCacheTag:(NSUInteger)cache;

- (NSMutableArray *)parameterTransitions;
- (NSMutableArray *)metaParameterTransitions;
- (NSMutableArray *)symbolEquations;

- (MMTransition *)getSpecialProfile:(NSUInteger)index;
- (void)setSpecialProfile:(NSUInteger)index to:(MMTransition *)special;

- (BOOL)usesCategory:(MMCategory *)aCategory;
- (BOOL)usesEquation:(MMEquation *)equation;
- (BOOL)usesTransition:(MMTransition *)transition;

- (NSString *)ruleString;

- (NSString *)symbolNameAtIndex:(NSUInteger)index;
- (void)setRuleExpression1:(MMBooleanNode *)exp1 exp2:(MMBooleanNode *)exp2 exp3:(MMBooleanNode *)exp3 exp4:(MMBooleanNode *)exp4;

@end
