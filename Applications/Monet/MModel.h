//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class CategoryList, MonetList, NamedList, PhoneList;
@class MMCategory, MMEquation, MMParameter, MMPosture, MMRule, MMSymbol, MMSynthesisParameters, MMTransition;

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
- (void)addCategoriesFromArray:(NSArray *)array;

// Parameters
- (void)addParameter:(MMParameter *)newParameter;
- (void)_uniqueNameForParameter:(MMParameter *)newParameter inList:(NSMutableArray *)aParameterList;
- (void)_addDefaultPostureTargetsForParameter:(MMParameter *)newParameter;
- (void)removeParameter:(MMParameter *)aParameter;
- (void)addParametersFromArray:(NSArray *)array;

// Meta Parameters
- (void)addMetaParameter:(MMParameter *)newParameter;
- (void)_addDefaultPostureTargetsForMetaParameter:(MMParameter *)newParameter;
- (void)removeMetaParameter:(MMParameter *)aParameter;
- (void)addMetaParametersFromArray:(NSArray *)array;

// Symbols
- (void)addSymbol:(MMSymbol *)newSymbol;
- (void)_uniqueNameForSymbol:(MMSymbol *)newSymbol;
- (void)_addDefaultPostureTargetsForSymbol:(MMSymbol *)newSymbol;
- (void)removeSymbol:(MMSymbol *)aSymbol;
- (MMSymbol *)symbolWithName:(NSString *)aName;
- (void)addSymbolsFromArray:(NSArray *)array;

// Postures
- (void)addPosture:(MMPosture *)newPosture;
- (void)_uniqueNameForPosture:(MMPosture *)newPosture;
- (void)removePosture:(MMPosture *)aPosture;
- (void)sortPostures;
- (MMPosture *)postureWithName:(NSString *)aName;
- (void)addPosturesFromArray:(NSArray *)array;

- (void)addEquationGroup:(NamedList *)newGroup;
- (void)addTransitionGroup:(NamedList *)newGroup;
- (void)addSpecialTransitionGroup:(NamedList *)newGroup;

- (void)addEquationGroupsFromArray:(NSArray *)newEquationGroups;
- (void)addTransitionGroupsFromArray:(NSArray *)newTransitionGroups;
- (void)addSpecialTransitionGroupsFromArray:(NSArray *)newSpecialTransitionGroups;

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
- (void)_addRulesFromArray:(NSArray *)newRules;

// Archiving
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

- (void)loadFromRootElement:(NSXMLElement *)element;

@end
