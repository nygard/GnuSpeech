//
// $Id: MModel.h,v 1.1 2004/03/18 22:15:18 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class CategoryList, MonetList, ParameterList, PhoneList, RuleList, SymbolList;

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

- (id)initWithCoder:(NSCoder *)aDecoder;

@end
