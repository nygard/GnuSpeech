#import <Foundation/NSObject.h>

@class BooleanExpression, CategoryNode, MonetList, PhoneList, ProtoEquation, ProtoTemplate;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface Rule : NSObject
{
    MonetList *parameterProfiles; // Of ProtoTemplates
    MonetList *metaParameterProfiles; // Of ProtoTemplates?
    MonetList *expressionSymbols; // Of ProtoEquations

    ProtoTemplate *specialProfiles[16];

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

- (ProtoEquation *)getExpressionSymbol:(int)index;
- (void)evaluateExpressionSymbols:(double *)buffer tempos:(double *)tempos phones:(PhoneList *)phones withCache:(int)cache;

- (MonetList *)parameterList;
- (MonetList *)metaParameterList;
- (MonetList *)symbols;

- (ProtoTemplate *)getSpecialProfile:(int)index;
- (void)setSpecialProfile:(int)index to:(ProtoTemplate *)special;

- (BOOL)isCategoryUsed:(CategoryNode *)aCategory;
- (BOOL)isEquationUsed:(ProtoEquation *)anEquation;
- (BOOL)isTransitionUsed:(ProtoTemplate *)aTransition;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)ruleString;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForParameterProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForMetaParameterProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForSpecialProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForExpressionSymbolsToString:(NSMutableString *)resultString level:(int)level;

- (NSString *)expressionSymbolNameAtIndex:(int)index;

@end
