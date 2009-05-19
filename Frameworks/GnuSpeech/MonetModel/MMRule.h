////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MMRule.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import "MMObject.h"

#import "MMFRuleSymbols.h"

@class MMBooleanNode, MMCategory, MonetList, PhoneList, MMEquation, MMTransition;
@class NSDictionary, NSMutableArray, NSMutableString, NSXMLParser;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

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

- (void)setDefaultsTo:(int)numPhones;
- (void)addDefaultParameter;
- (void)addDefaultMetaParameter;
- (void)removeParameterAtIndex:(int)index;
- (void)removeMetaParameterAtIndex:(int)index;


- (void)addStoredParameterTransition:(MMTransition *)aTransition;
- (void)addParameterTransitionsFromReferenceDictionary:(NSDictionary *)dict;

- (void)addStoredMetaParameterTransition:(MMTransition *)aTransition;
- (void)addMetaParameterTransitionsFromReferenceDictionary:(NSDictionary *)dict;

- (void)addSpecialProfilesFromReferenceDictionary:(NSDictionary *)dict;

- (void)addStoredSymbolEquation:(MMEquation *)anEquation;
- (void)addSymbolEquationsFromReferenceDictionary:(NSDictionary *)dict;


- (void)setExpression:(MMBooleanNode *)newExpression number:(int)index;
- (int)numberExpressions;
- (MMBooleanNode *)getExpressionNumber:(int)index;

- (void)addBooleanExpression:(MMBooleanNode *)newExpression;
- (void)addBooleanExpressionString:(NSString *)aString;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (BOOL)matchRule:(NSArray *)categories;

- (MMEquation *)getSymbolEquation:(int)index;
- (void)evaluateSymbolEquations:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures withCache:(int)cache;

- (NSMutableArray *)parameterTransitions;
- (NSMutableArray *)metaParameterTransitions;
- (NSMutableArray *)symbolEquations;

- (MMTransition *)getSpecialProfile:(int)index;
- (void)setSpecialProfile:(int)index to:(MMTransition *)special;

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (BOOL)isTransitionUsed:(MMTransition *)aTransition;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)ruleString;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForParameterTransitionsToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForMetaParameterTransitionsToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForSpecialProfilesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForSymbolEquationsToString:(NSMutableString *)resultString level:(int)level;

- (NSString *)symbolNameAtIndex:(int)index;
- (void)setRuleExpression1:(MMBooleanNode *)exp1 exp2:(MMBooleanNode *)exp2 exp3:(MMBooleanNode *)exp3 exp4:(MMBooleanNode *)exp4;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
