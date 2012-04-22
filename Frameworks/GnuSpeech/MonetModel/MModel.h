//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>
#include <stdio.h>

@class NamedList;
@class MMCategory, MMEquation, MMParameter, MMPosture, MMRule, MMSymbol, MMSynthesisParameters, MMTransition;

extern NSString *MCategoryInUseException;

@interface MModel : NSObject <NSXMLParserDelegate>

@property (readonly) NSMutableArray *categories;
@property (readonly) NSMutableArray *parameters;
@property (readonly) NSMutableArray *metaParameters;
@property (readonly) NSMutableArray *symbols;
@property (readonly) NSMutableArray *postures;

@property (readonly) NSMutableArray *equations;
@property (readonly) NSMutableArray *transitions;
@property (readonly) NSMutableArray *specialTransitions;

@property (readonly) NSMutableArray *rules;

// Categories
- (void)addCategory:(MMCategory *)newCategory;
- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
- (void)removeCategory:(MMCategory *)aCategory;
- (MMCategory *)categoryWithName:(NSString *)aName;

// Parameters
- (void)addParameter:(MMParameter *)newParameter;
- (void)removeParameter:(MMParameter *)aParameter;

// Meta Parameters
- (void)addMetaParameter:(MMParameter *)newParameter;
- (void)removeMetaParameter:(MMParameter *)aParameter;

// Symbols
- (void)addSymbol:(MMSymbol *)newSymbol;
- (void)removeSymbol:(MMSymbol *)aSymbol;
- (MMSymbol *)symbolWithName:(NSString *)aName;

// Postures
- (void)addPosture:(MMPosture *)newPosture;
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
- (MMRule *)findRuleMatchingCategories:(NSArray *)categoryLists ruleIndex:(NSInteger *)indexPtr;

// Archiving - XML
- (BOOL)writeXMLToFile:(NSString *)aFilename comment:(NSString *)aComment;

// Archiving - Degas support
- (void)readDegasFileFormat:(FILE *)fp;
- (void)readParametersFromDegasFile:(FILE *)fp;
- (void)readCategoriesFromDegasFile:(FILE *)fp;
- (void)readPosturesFromDegasFile:(FILE *)fp;
- (void)readRulesFromDegasFile:(FILE *)fp;

- (void)writeDataToFile:(FILE *)fp;

- (int)nextCacheTag;
- (void)parameter:(MMParameter *)aParameter willChangeDefaultValue:(double)newDefaultValue;
- (void)symbol:(MMSymbol *)aSymbol willChangeDefaultValue:(double)newDefaultValue;

// Other
- (MMSynthesisParameters *)synthesisParameters;

@end
