#import "MonetList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@class NamedList;

@protocol MSetGroupProtocol
- (void)setGroup:(NamedList *)newGroup;
@end

@interface NamedList : MonetList
{
    NSString *name;
    NSString *comment;
}

- (id)initWithCapacity:(unsigned)numSlots;
- (void)dealloc;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(unsigned)index;
- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)anObject;

@end
