//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class MMGroup;
@class MMCategory, MMEquation, MMParameter, MMPosture, MMRule, MMSymbol, MMSynthesisParameters, MMTransition;

extern NSString *MCategoryInUseException;

@interface MModel : NSObject <NSXMLParserDelegate>

@property (readonly) NSMutableArray *categories;
@property (readonly) NSMutableArray *parameters;
@property (readonly) NSMutableArray *metaParameters;
@property (readonly) NSMutableArray *symbols;
@property (readonly) NSMutableArray *postures;

@property (readonly) NSMutableArray *equationGroups;
@property (readonly) NSMutableArray *transitionGroups;
@property (readonly) NSMutableArray *specialTransitionGroups;

@property (readonly) NSMutableArray *rules;

// Categories
- (void)addCategory:(MMCategory *)category;
- (BOOL)isCategoryUsed:(MMCategory *)category;
- (void)removeCategory:(MMCategory *)category;
- (MMCategory *)categoryWithName:(NSString *)name;

// Parameters
- (void)addParameter:(MMParameter *)parameter;
- (void)removeParameter:(MMParameter *)parameter;

// Meta Parameters
- (void)addMetaParameter:(MMParameter *)parameter;
- (void)removeMetaParameter:(MMParameter *)parameter;

// Symbols
- (void)addSymbol:(MMSymbol *)symbol;
- (void)removeSymbol:(MMSymbol *)symbol;
- (MMSymbol *)symbolWithName:(NSString *)name;

// Postures
- (void)addPosture:(MMPosture *)posture;
- (void)removePosture:(MMPosture *)posture;
- (void)sortPostures;
- (MMPosture *)postureWithName:(NSString *)name;

- (void)addEquationGroup:(MMGroup *)group;
- (void)addTransitionGroup:(MMGroup *)group;
- (void)addSpecialTransitionGroup:(MMGroup *)group;

- (MMEquation *)findEquationWithName:(NSString *)name;
- (MMTransition *)findTransitionWithName:(NSString *)name;
- (MMTransition *)findSpecialTransitionWithName:(NSString *)name;

- (MMEquation *)findEquationWithName:(NSString *)equationName inGroupWithName:(NSString *)groupName;
- (MMTransition *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;

- (NSArray *)usageOfEquation:(MMEquation *)equation;
- (NSArray *)usageOfTransition:(MMTransition *)transition;

// Rules
- (void)addRule:(MMRule *)rule;
- (MMRule *)findRuleMatchingCategories:(NSArray *)categoryLists ruleIndex:(NSInteger *)indexPtr;

// Archiving - XML
- (BOOL)writeXMLToFile:(NSString *)filename comment:(NSString *)comment;

- (int)nextCacheTag;
- (void)parameter:(MMParameter *)parameter willChangeDefaultValue:(double)newDefaultValue;
- (void)symbol:(MMSymbol *)symbol willChangeDefaultValue:(double)newDefaultValue;

// Other
@property (readonly) MMSynthesisParameters *synthesisParameters;

@end
