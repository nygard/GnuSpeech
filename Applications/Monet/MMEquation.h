#import "MMObject.h"

#import "MMFRuleSymbols.h"

@class MMFormulaNode, NamedList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMEquation : MMObject
{
    NamedList *nonretained_group;

    NSString *name;
    NSString *comment;
    MMFormulaNode *formula;

    int cacheTag;
    double cacheValue;
}

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

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(int)newCacheTag;
- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures andCacheWith:(int)newCacheTag;
- (double)cacheValue;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (NSString *)equationPath;

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;

@end
