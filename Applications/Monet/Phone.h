#import <Foundation/NSObject.h>

@class CategoryNode, CategoryList, ParameterList, TargetList, SymbolList;

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

@interface Phone : NSObject
{
    NSString *phoneSymbol;
    NSString *comment;

    CategoryList *categoryList;
    TargetList *parameterList;
    TargetList *metaParameterList;
    TargetList *symbolList;
}

/* init and free methods */
- (id)init;
- (id)initWithSymbol:(NSString *)newSymbol;
- (id)initWithSymbol:(NSString *)newSymbol parmeters:(ParameterList *)parms metaParameters:(ParameterList *)metaparms symbols:(SymbolList *)symbols;
- (void)dealloc;

/* Comment and Symbol methods */
- (NSString *)symbol;
- (void)setSymbol:(NSString *)newSymbol;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;

/* Access to category List instance variable */
- (CategoryList *)categoryList;
- (void)addToCategoryList:(CategoryNode *)aCategory;

/* Access to target lists */
- (TargetList *)parameterList;
- (TargetList *)metaParameterList;
- (TargetList *)symbolList;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForParametersToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForMetaParametersToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForSymbolsToString:(NSMutableString *)resultString level:(int)level;

@end
