//
// $Id: MModel.h,v 1.2 2004/03/18 23:43:54 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class CategoryList, MonetList, ParameterList, PhoneList, ProtoEquation, ProtoTemplate, RuleList, SymbolList;

@interface MModel : NSObject
{
    CategoryList *categories; // Keep this list sorted by name
    ParameterList *parameters;
    ParameterList *metaParameters;
    SymbolList *symbols;
    PhoneList *phones; // Keep this list sorted by name

    MonetList *equations; // Of NamedLists of ProtoEquations
    MonetList *transitions; // Of NamedLists of ProtoTemplates
    MonetList *specialTransitions; // Of NamedLists of ProtoTemplates

    RuleList *rules;
}

- (id)init;
- (void)dealloc;

- (CategoryList *)categories;
- (ParameterList *)parameters;
- (ParameterList *)metaParameters;
- (SymbolList *)symbols;
- (PhoneList *)phones;

- (MonetList *)equations;
- (MonetList *)transitions;
- (MonetList *)specialTransitions;

- (RuleList *)rules;

- (ProtoEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(ProtoEquation *)anEquation;
- (ProtoEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;

- (ProtoEquation *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(ProtoEquation *)aTransition;
- (ProtoEquation *)findTransition:(int)listIndex andIndex:(int)transitionIndex;

- (ProtoTemplate *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(ProtoTemplate *)aTransition;
- (ProtoTemplate *)findSpecial:(int)listIndex andIndex:(int)specialIndex;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)readPrototypes:(NSCoder *)aDecoder;

// Archiving - XML
- (void)generateXML:(NSString *)name;
- (void)_appendXMLForProtoEquationsToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForProtoTemplatesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(int)level;

@end
