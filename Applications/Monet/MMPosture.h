#import "MMNamedObject.h"

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
- (void)removeParameterTargetAtIndex:(unsigned int)index;

- (void)addMetaParameterTarget:(MMTarget *)newTarget;
- (void)removeMetaParameterTargetAtIndex:(unsigned int)index;

- (void)addSymbolTarget:(MMTarget *)newTarget;
- (void)removeSymbolTargetAtIndex:(unsigned int)index;

- (MMTarget *)targetForSymbol:(MMSymbol *)aSymbol;

- (NSComparisonResult)compareByAscendingName:(MMPosture *)otherPosture;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForCategoriesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForParametersToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForMetaParametersToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForSymbolsToString:(NSMutableString *)resultString level:(int)level;

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
- (void)_loadCategoriesFromXMLElement:(NSXMLElement *)element context:(id)context;
- (void)_loadParameterTargetsFromXMLElement:(NSXMLElement *)element context:(id)context;
- (void)_loadMetaParameterTargetsFromXMLElement:(NSXMLElement *)element context:(id)context;
- (void)_loadSymbolTargetsFromXMLElement:(NSXMLElement *)element context:(id)context;

@end
