#import "MMObject.h"

@class BooleanExpression, MMCategory, MonetList, PhoneList, MMEquation, MMTransition;

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
    MonetList *expressionSymbols; // Of MMEquations

    MMTransition *specialProfiles[16];

    BooleanExpression *expressions[4];
    NSString *comment;
}

- (id)init;
- (void)dealloc;

- (void)setDefaultsTo:(int)numPhones;
- (void)addDefaultParameter;
- (void)addDefaultMetaParameter;
- (void)removeParameter:(int)index;
- (void)removeMetaParameter:(int)index;

- (void)setExpression:(BooleanExpression *)newExpression number:(int)index;
- (int)numberExpressions;
- (BooleanExpression *)getExpressionNumber:(int)index;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;

- (int)matchRule:(MonetList *)categories;

- (MMEquation *)getExpressionSymbol:(int)index;
- (void)evaluateExpressionSymbols:(double *)buffer tempos:(double *)tempos phones:(PhoneList *)phones withCache:(int)cache;

- (MonetList *)parameterList;
- (MonetList *)metaParameterList;
- (MonetList *)symbols;

- (MMTransition *)getSpecialProfile:(int)index;
- (void)setSpecialProfile:(int)index to:(MMTransition *)special;

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (BOOL)isTransitionUsed:(MMTransition *)aTransition;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)ruleString;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level number:(int)aNumber;
- (void)_appendXMLForParameterProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForMetaParameterProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForSpecialProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForExpressionSymbolsToString:(NSMutableString *)resultString level:(int)level;

- (NSString *)expressionSymbolNameAtIndex:(int)index;

@end
