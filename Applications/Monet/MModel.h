//
// $Id: MModel.h,v 1.7 2004/03/19 18:46:53 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class CategoryList, MonetList, ParameterList, PhoneList, RuleList, SymbolList;
@class MMCategory, MMEquation, MMTransition;

extern NSString *MCategoryInUseException;

@interface MModel : NSObject
{
    CategoryList *categories; // Keep this list sorted by name
    ParameterList *parameters;
    ParameterList *metaParameters;
    SymbolList *symbols;
    PhoneList *postures; // Keep this list sorted by name

    MonetList *equations; // Of NamedLists of MMEquations
    MonetList *transitions; // Of NamedLists of MMTransitions
    MonetList *specialTransitions; // Of NamedLists of MMTransitions

    RuleList *rules;
}

- (id)init;
- (void)dealloc;

- (CategoryList *)categories;
- (ParameterList *)parameters;
- (ParameterList *)metaParameters;
- (SymbolList *)symbols;
- (PhoneList *)postures;

- (MonetList *)equations;
- (MonetList *)transitions;
- (MonetList *)specialTransitions;

- (RuleList *)rules;


// Categories
- (void)addCategory:(MMCategory *)newCategory;
- (void)uniqueNameForCategory:(MMCategory *)newCategory;
- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
- (void)removeCategory:(MMCategory *)aCategory;


- (MMEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(MMEquation *)anEquation;
- (MMEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;

- (MMEquation *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(MMEquation *)aTransition;
- (MMEquation *)findTransition:(int)listIndex andIndex:(int)transitionIndex;

- (MMTransition *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(MMTransition *)aTransition;
- (MMTransition *)findSpecial:(int)listIndex andIndex:(int)specialIndex;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)readPrototypes:(NSCoder *)aDecoder;

// Archiving - XML
- (void)generateXML:(NSString *)name;
- (void)_appendXMLForMMEquationsToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForMMTransitionsToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(int)level;

@end
