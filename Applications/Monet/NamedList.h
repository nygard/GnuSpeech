
#import "MonetList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface NamedList:MonetList
{
	char *name;
	char *comment;
}

- (void)setComment:(const char *)newComment;
- (const char *) comment;

- setName:(NSString *)newName;
- (NSString *)name;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
