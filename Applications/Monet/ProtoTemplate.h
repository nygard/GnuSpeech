
#import "MonetList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

#define DIPHONE 2
#define TRIPHONE 3
#define TETRAPHONE 4

@interface ProtoTemplate:NSObject
{
	char 	*name;
	char 	*comment;
	int	type;
	MonetList	*points;
}

- init;
- initWithName:(NSString *)newName;

- setName:(NSString *)newName;
- (NSString *)name;

- (void)setComment:(const char *)newComment;
- (const char *) comment;

- (void)setPoints:newList;
- points;

- insertPoint:aPoint;

- (void)setType:(int)type;
- (int) type;

- (void)dealloc;

- (BOOL) isEquationUsed: anEquation;
- findEquation: anEquation andPutIn: aList;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
