//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

@class MMCategory, MMSymbol, MMTarget;

// Contains informaion for one phone or "posture"
@interface MMPosture : MMNamedObject

- (id)initWithModel:(MModel *)model;
- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;

- (NSString *)shortDescription;

// Categories
@property (readonly) MMCategory *nativeCategory;
@property (readonly) NSMutableArray *categories;

- (void)addCategory:(MMCategory *)category;
- (void)removeCategory:(MMCategory *)category;
- (BOOL)isMemberOfCategory:(MMCategory *)category;
- (BOOL)isMemberOfCategoryNamed:(NSString *)name;
- (void)addCategoryWithName:(NSString *)name;

@property (readonly) NSMutableArray *parameterTargets;
- (void)addParameterTarget:(MMTarget *)target;
- (void)removeParameterTargetAtIndex:(NSUInteger)index;

@property (readonly) NSMutableArray *metaParameterTargets;
- (void)addMetaParameterTarget:(MMTarget *)target;
- (void)removeMetaParameterTargetAtIndex:(NSUInteger)index;

@property (readonly) NSMutableArray *symbolTargets;
- (void)addSymbolTarget:(MMTarget *)target;
- (void)removeSymbolTargetAtIndex:(NSUInteger)index;

- (MMTarget *)targetForSymbol:(MMSymbol *)symbol;

- (NSComparisonResult)compareByAscendingName:(MMPosture *)other;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

@end
