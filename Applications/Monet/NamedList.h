#import "MonetList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@class MModel, NamedList;

@protocol MSetGroupProtocol
- (void)setGroup:(NamedList *)newGroup;
@end

@interface NamedList : MonetList
{
    MModel *nonretained_model;

    NSString *name;
    NSString *comment;
}

- (id)initWithCapacity:(unsigned)numSlots;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;

// These set the group (if possible) on objects added to the list
- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(unsigned)index;
- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)anObject;

- (id)initWithXMLAttributes:(NSDictionary *)attributes;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
