#import <Foundation/NSObject.h>

@class MonetList, ProtoEquation;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

#define DIPHONE 2
#define TRIPHONE 3
#define TETRAPHONE 4

@interface ProtoTemplate : NSObject
{
    NSString *name;
    NSString *comment;
    int type;
    MonetList *points; // Of SlopeRatios (or maybe something else - MMPoints?)
}

- (id)init;
- (id)initWithName:(NSString *)newName;
- (void)dealloc;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;

- (MonetList *)points;
- (void)setPoints:(MonetList *)newList;
- insertPoint:aPoint;

- (int)type;
- (void)setType:(int)type;

- (BOOL)isEquationUsed:(ProtoEquation *)anEquation;
- findEquation:anEquation andPutIn:(MonetList *)aList;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

@end
