
#import <Foundation/NSArray.h>
#import "TargetList.h"
#import "CategoryList.h"

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

@interface Phone:NSObject
{
	char 	*phoneSymbol;
	char	*comment;

	CategoryList	*categoryList;
	TargetList	*parameterList;
	TargetList	*metaParameterList;
	TargetList	*symbolList;

}

/* init and free methods */
- init;
- initWithSymbol:(const char *) newSymbol;
- initWithSymbol:(const char *) newSymbol parmeters:parms metaParameters: metaparms symbols:symbols;
- (void)dealloc;

/* Comment and Symbol methods */
- (void)setSymbol:(const char *)newSymbol;
- (const char *)symbol;
- (void)setComment:(const char *)newComment;
- (const char *) comment;

/* Access to category List instance variable */
- (void)addToCategoryList:(CategoryNode *)aCategory;
- categoryList;

/* Access to target lists */
- parameterList;
- metaParameterList;
- symbolList;

/* Archiving methods */
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
