#import "MMObject.h"

#import "MMFRuleSymbols.h"

@class MMBooleanNode, MMCategory, MonetList, PhoneList, MMEquation, MMTransition;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMRule : MMObject
{
    MonetList *parameterProfiles; // Of MMTransitions
    MonetList *metaParameterProfiles; // Of MMTransitions?
    NSMutableArray *expressionSymbols; // Of MMEquations

    MMTransition *specialProfiles[16]; // TODO (2004-05-16): We should be able to use an NSMutableDictionary here.

    MMBooleanNode *expressions[4];
    NSString *comment;
}

- (id)init;
- (void)dealloc;

- (void)setDefaultsTo:(int)numPhones;
- (void)addDefaultParameter;
- (void)addDefaultMetaParameter;
- (void)removeParameterAtIndex:(int)index;
- (void)removeMetaParameterAtIndex:(int)index;

- (void)addStoredParameterProfile:(MMTransition *)aTransition;
- (void)addParameterProfilesFromReferenceDictionary:(NSDictionary *)dict;

- (void)addStoredMetaParameterProfile:(MMTransition *)aTransition;
- (void)addMetaParameterProfilesFromReferenceDictionary:(NSDictionary *)dict;

- (void)addSpecialProfilesFromReferenceDictionary:(NSDictionary *)dict;

- (void)addStoredExpressionSymbol:(MMEquation *)anEquation;
- (void)addExpressionSymbolsFromReferenceDictionary:(NSDictionary *)dict;

- (void)setExpression:(MMBooleanNode *)newExpression number:(int)index;
- (int)numberExpressions;
- (MMBooleanNode *)getExpressionNumber:(int)index;

- (void)addBooleanExpression:(MMBooleanNode *)newExpression;
- (void)addBooleanExpressionString:(NSString *)aString;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (BOOL)matchRule:(NSArray *)categories;

- (MMEquation *)getExpressionSymbol:(int)index;
- (void)evaluateExpressionSymbols:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos phones:(NSArray *)phones withCache:(int)cache;

- (MonetList *)parameterList;
- (MonetList *)metaParameterList;
- (NSMutableArray *)symbols;

- (MMTransition *)getSpecialProfile:(int)index;
- (void)setSpecialProfile:(int)index to:(MMTransition *)special;

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (BOOL)isTransitionUsed:(MMTransition *)aTransition;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)ruleString;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForParameterProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForMetaParameterProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForSpecialProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForExpressionSymbolsToString:(NSMutableString *)resultString level:(int)level;

- (NSString *)expressionSymbolNameAtIndex:(int)index;
- (void)setRuleExpression1:(MMBooleanNode *)exp1 exp2:(MMBooleanNode *)exp2 exp3:(MMBooleanNode *)exp3 exp4:(MMBooleanNode *)exp4;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
