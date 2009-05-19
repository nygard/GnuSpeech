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
//  MModel.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSObject.h>
#include <stdio.h>

@class CategoryList, MonetList, NamedList, PhoneList;
@class MMCategory, MMEquation, MMParameter, MMPosture, MMRule, MMSymbol, MMSynthesisParameters, MMTransition;
@class NSArray, NSDictionary, NSMutableArray, NSMutableString, NSXMLParser;

extern NSString *MCategoryInUseException;

@interface MModel : NSObject
{
    CategoryList *categories; // Keep this list sorted by name
    NSMutableArray *parameters;
    NSMutableArray *metaParameters;
    NSMutableArray *symbols;
    NSMutableArray *postures; // Keep this list sorted by name

    NSMutableArray *equations; // Of NamedLists of MMEquations
    NSMutableArray *transitions; // Of NamedLists of MMTransitions
    NSMutableArray *specialTransitions; // Of NamedLists of MMTransitions

    NSMutableArray *rules;
    int cacheTag;

    // This doesn't really belong here, but I'll put it here for now.
    MMSynthesisParameters *synthesisParameters;
}

- (id)init;
- (void)dealloc;

- (void)_addDefaultRule;

- (CategoryList *)categories;
- (NSMutableArray *)parameters;
- (NSMutableArray *)metaParameters;
- (NSMutableArray *)symbols;
- (NSMutableArray *)postures;

- (NSMutableArray *)equations;
- (NSMutableArray *)transitions;
- (NSMutableArray *)specialTransitions;

- (NSMutableArray *)rules;

// Categories
- (void)addCategory:(MMCategory *)newCategory;
- (void)_uniqueNameForCategory:(MMCategory *)newCategory;
- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
- (void)removeCategory:(MMCategory *)aCategory;
- (MMCategory *)categoryWithName:(NSString *)aName;

// Parameters
- (void)addParameter:(MMParameter *)newParameter;
- (void)_uniqueNameForParameter:(MMParameter *)newParameter inList:(NSMutableArray *)aParameterList;
- (void)_addDefaultPostureTargetsForParameter:(MMParameter *)newParameter;
- (void)removeParameter:(MMParameter *)aParameter;

// Meta Parameters
- (void)addMetaParameter:(MMParameter *)newParameter;
- (void)_addDefaultPostureTargetsForMetaParameter:(MMParameter *)newParameter;
- (void)removeMetaParameter:(MMParameter *)aParameter;

// Symbols
- (void)addSymbol:(MMSymbol *)newSymbol;
- (void)_uniqueNameForSymbol:(MMSymbol *)newSymbol;
- (void)_addDefaultPostureTargetsForSymbol:(MMSymbol *)newSymbol;
- (void)removeSymbol:(MMSymbol *)aSymbol;
- (MMSymbol *)symbolWithName:(NSString *)aName;

// Postures
- (void)addPosture:(MMPosture *)newPosture;
- (void)_uniqueNameForPosture:(MMPosture *)newPosture;
- (void)removePosture:(MMPosture *)aPosture;
- (void)sortPostures;
- (MMPosture *)postureWithName:(NSString *)aName;

- (void)addEquationGroup:(NamedList *)newGroup;
- (void)addTransitionGroup:(NamedList *)newGroup;
- (void)addSpecialTransitionGroup:(NamedList *)newGroup;

- (MMEquation *)findEquationWithName:(NSString *)anEquationName;
- (MMTransition *)findTransitionWithName:(NSString *)aTransitionName;
- (MMTransition *)findSpecialTransitionWithName:(NSString *)aTransitionName;

- (MMEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(MMEquation *)anEquation;
- (MMEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;

- (MMTransition *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(MMTransition *)aTransition;
- (MMTransition *)findTransition:(int)listIndex andIndex:(int)transitionIndex;

- (MMTransition *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(MMTransition *)aTransition;
- (MMTransition *)findSpecial:(int)listIndex andIndex:(int)specialIndex;

- (NSArray *)usageOfEquation:(MMEquation *)anEquation;
- (NSArray *)usageOfTransition:(MMTransition *)aTransition;

// Rules
- (void)addRule:(MMRule *)newRule;
- (void)_addStoredRule:(MMRule *)newRule;
- (MMRule *)findRuleMatchingCategories:(NSArray *)categoryLists ruleIndex:(int *)indexPtr;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)readPrototypes:(NSCoder *)aDecoder;
- (BOOL)importPostureNamed:(NSString *)postureName fromTRMData:(NSCoder *)aDecoder;

// Archiving - XML
- (BOOL)writeXMLToFile:(NSString *)aFilename comment:(NSString *)aComment;
- (void)_appendXMLForEquationsToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForTransitionsToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(int)level;

// Archiving - Degas support
- (void)readDegasFileFormat:(FILE *)fp;
- (void)readParametersFromDegasFile:(FILE *)fp;
- (void)readCategoriesFromDegasFile:(FILE *)fp;
- (void)readPosturesFromDegasFile:(FILE *)fp;
- (void)readRulesFromDegasFile:(FILE *)fp;

- (void)writeDataToFile:(FILE *)fp;
- (void)_writeCategoriesToFile:(FILE *)fp;
- (void)_writeParametersToFile:(FILE *)fp;
- (void)_writeSymbolsToFile:(FILE *)fp;
- (void)_writePosturesToFile:(FILE *)fp;

- (int)nextCacheTag;
- (void)parameter:(MMParameter *)aParameter willChangeDefaultValue:(double)newDefaultValue;
- (void)symbol:(MMSymbol *)aSymbol willChangeDefaultValue:(double)newDefaultValue;

// Other
- (MMSynthesisParameters *)synthesisParameters;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
