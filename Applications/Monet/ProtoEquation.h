
#import <Foundation/NSObject.h>
#import "FormulaExpression.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface ProtoEquation:NSObject
{
	char 	*name;
	char 	*comment;
	id	expression;

	int     cacheTag;
	double  cacheValue;
}

- init;
- initWithName:(NSString *)newName;

- setName:(NSString *)newName;
- (NSString *)name;

- (void)setComment:(const char *)newComment;
- (const char *) comment;

- (void)setExpression:newExpression;
- expression;

- (double) evaluate: (double *) ruleSymbols phones: phones andCacheWith: (int) newCacheTag;
- (double) evaluate: (double *) ruleSymbols tempos: (double *) tempos phones: phones andCacheWith: (int) newCacheTag;
- (double) cacheValue;

- (void)dealloc;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
