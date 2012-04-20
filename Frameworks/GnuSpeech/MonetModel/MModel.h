//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>
#include <stdio.h>

@class CategoryList, MonetList, NamedList, PhoneList;
@class MMCategory, MMEquation, MMParameter, MMPosture, MMRule, MMSymbol, MMSynthesisParameters, MMTransition;

extern NSString *MCategoryInUseException;

@interface MModel : NSObject

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
- (void)findList:(NSUInteger *)listIndex andIndex:(NSUInteger *)equationIndex ofEquation:(MMEquation *)anEquation;
- (MMEquation *)findEquation:(NSUInteger)listIndex andIndex:(NSUInteger)equationIndex;

- (MMTransition *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
- (void)findList:(NSUInteger *)listIndex andIndex:(NSUInteger *)transitionIndex ofTransition:(MMTransition *)aTransition;
- (MMTransition *)findTransition:(NSUInteger)listIndex andIndex:(NSUInteger)transitionIndex;

- (MMTransition *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
- (void)findList:(NSUInteger *)listIndex andIndex:(NSUInteger *)specialIndex ofSpecial:(MMTransition *)aTransition;
- (MMTransition *)findSpecial:(NSUInteger)listIndex andIndex:(NSUInteger)specialIndex;

- (NSArray *)usageOfEquation:(MMEquation *)anEquation;
- (NSArray *)usageOfTransition:(MMTransition *)aTransition;

// Rules
- (void)addRule:(MMRule *)newRule;
- (void)_addStoredRule:(MMRule *)newRule;
- (MMRule *)findRuleMatchingCategories:(NSArray *)categoryLists ruleIndex:(NSInteger *)indexPtr;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)readPrototypes:(NSCoder *)aDecoder;
- (BOOL)importPostureNamed:(NSString *)postureName fromTRMData:(NSCoder *)aDecoder;

// Archiving - XML
- (BOOL)writeXMLToFile:(NSString *)aFilename comment:(NSString *)aComment;
- (void)_appendXMLForEquationsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForTransitionsToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(NSUInteger)level;

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
