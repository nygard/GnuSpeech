//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

@class NSMutableArray, NSMutableString;
@class CategoryList, MMCategory, MMSymbol, MMTarget;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: Phone.
	Purpose: This object stores the information pertinent to one phone or
		"posture".

	Instance Variables:
		phoneSymbol: (char *) String which holds the symbol
			representing this phone.
		comment: (char *) string which holds any user comment made
			regarding this phone.

		categoryList: List of categories which this phone is a member
			of.
		parameterList: List of parameter target values for this phone.
		metaParameterList: List of meta-parameter target values for
			this phone.
		symbolList: List of symbol definitions for this phone.

	Import Files:

		"CategoryList.h": for access to CategoryList methods.

	NOTES:

	categoryList:  Of the objects in this list, only those which are
		"native" belong to the phone object.  When freeing, free
		only native objects using the "freeNativeCategories" method
		in the CategoryList Object.

	See "data_relationships" document for information about the
		parameterList, metaParameterList and symbolList variables.

===========================================================================*/

@interface MMPosture : MMNamedObject
{
    CategoryList *categories; // Of MMCategorys
    NSMutableArray *parameterTargets; // Of Targets
    NSMutableArray *metaParameterTargets; // Of Targets
    NSMutableArray *symbolTargets; // Of Targets

    MMCategory *nativeCategory;
}

- (id)init;
- (id)initWithModel:(MModel *)aModel;
- (void)_addDefaultValues;

- (void)dealloc;

// Categories
- (MMCategory *)nativeCategory;
- (CategoryList *)categories;
- (void)addCategory:(MMCategory *)aCategory;
- (void)removeCategory:(MMCategory *)aCategory;
- (BOOL)isMemberOfCategory:(MMCategory *)aCategory;
- (BOOL)isMemberOfCategoryNamed:(NSString *)aCategoryName;
- (void)addCategoryWithName:(NSString *)aCategoryName;

/* Access to target lists */
- (NSMutableArray *)parameterTargets;
- (NSMutableArray *)metaParameterTargets;
- (NSMutableArray *)symbolTargets;

- (void)addParameterTarget:(MMTarget *)newTarget;
- (void)removeParameterTargetAtIndex:(NSUInteger)index;
- (void)addParameterTargetsFromDictionary:(NSDictionary *)aDictionary;

- (void)addMetaParameterTarget:(MMTarget *)newTarget;
- (void)removeMetaParameterTargetAtIndex:(NSUInteger)index;
- (void)addMetaParameterTargetsFromDictionary:(NSDictionary *)aDictionary;

- (void)addSymbolTarget:(MMTarget *)newTarget;
- (void)removeSymbolTargetAtIndex:(NSUInteger)index;
- (void)addSymbolTargetsFromDictionary:(NSDictionary *)aDictionary;

- (MMTarget *)targetForSymbol:(MMSymbol *)aSymbol;

- (NSComparisonResult)compareByAscendingName:(MMPosture *)otherPosture;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForCategoriesToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForParametersToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForMetaParametersToString:(NSMutableString *)resultString level:(NSUInteger)level;
- (void)_appendXMLForSymbolsToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
