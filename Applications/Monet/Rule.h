
#import <Foundation/NSArray.h>
#import "BooleanParser.h"
#import "CategoryList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface Rule:NSObject
{
	MonetList *parameterProfiles;
	MonetList *metaParameterProfiles;
	MonetList *expressionSymbols;

	id specialProfiles[16];

	BooleanExpression *expressions[4];
	char *comment;

}

- init;
- (void)setDefaultsTo:(int)numPhones;
- (void)addDefaultParameter;
- (void)addDefaultMetaParameter;
- (void)removeParameter:(int)index;
- (void)removeMetaParameter:(int)index;
- (void)dealloc;

- setExpression: (BooleanExpression *) expression number:(int) index;
- getExpressionNumber:(int)index;
- (int) numberExpressions;
- (int) matchRule: (MonetList *) categories;

- getExpressionSymbol:(int)index;
- evaluateExpressionSymbols:(double *) buffer tempos: (double *) tempos phones: phones withCache: (int) cache;

- (void)setComment:(const char *)newComment;
- (const char *) comment;

- parameterList;
- metaParameterList;
- symbols;

- getSpecialProfile:(int)index;
- setSpecialProfile:(int) index to:special;

- (BOOL) isCategoryUsed: aCategory;
- (BOOL) isEquationUsed: anEquation;
- (BOOL) isTransitionUsed: aTransition;


- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
