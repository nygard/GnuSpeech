#import "MMObject.h"

@class CategoryList, MMCategory, MMTarget, ParameterList, TargetList, SymbolList;

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

		"TargetList.h":  for access to TargetList methods.
		"CategoryList.h": for access to CategoryList methods.

	NOTES:

	categoryList:  Of the objects in this list, only those which are
		"native" belong to the phone object.  When freeing, free
		only native objects using the "freeNativeCategories" method
		in the CategoryList Object.

	See "data_relationships" document for information about the
		parameterList, metaParameterList and symbolList variables.

===========================================================================*/

@interface MMPosture : MMObject
{
    NSString *phoneSymbol;
    NSString *comment;

    // TODO (2004-03-19): Rename categories, parameters, metaParameters, and symbols
    CategoryList *categoryList; // Of MMCategorys
    TargetList *parameterList; // Of Targets
    TargetList *metaParameterList; // Of Targets
    TargetList *symbolList; // Of Targets

    MMCategory *nativeCategory;
}

/* init and free methods */
#if 0
- (id)init;
- (id)initWithSymbol:(NSString *)newSymbol;
- (id)initWithSymbol:(NSString *)newSymbol parameters:(ParameterList *)parms metaParameters:(ParameterList *)metaparms symbols:(SymbolList *)symbols;
#endif

- (id)initWithModel:(MModel *)aModel;
- (void)_addDefaultValues;

- (void)dealloc;

/* Comment and Symbol methods */
- (NSString *)symbol;
- (void)setSymbol:(NSString *)newSymbol;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

/* Access to category List instance variable */
- (CategoryList *)categoryList;
- (void)addCategory:(MMCategory *)aCategory;
- (void)removeCategory:(MMCategory *)aCategory;
- (BOOL)isMemberOfCategory:(MMCategory *)aCategory;
- (BOOL)isMemberOfCategoryNamed:(NSString *)aCategoryName;

/* Access to target lists */
- (TargetList *)parameterTargets;
- (TargetList *)metaParameterTargets;
- (TargetList *)symbolList;

- (void)addParameterTarget:(MMTarget *)newTarget;
- (void)removeParameterTargetAtIndex:(unsigned int)index;

- (void)addMetaParameterTarget:(MMTarget *)newTarget;
- (void)removeMetaParameterTargetAtIndex:(unsigned int)index;

- (void)addSymbolTarget:(MMTarget *)newTarget;
- (void)removeSymbolTargetAtIndex:(unsigned int)index;

- (NSComparisonResult)compareByAscendingName:(MMPosture *)otherPosture;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForCategoriesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForParametersToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForMetaParametersToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForSymbolsToString:(NSMutableString *)resultString level:(int)level;

@end
