#import <Foundation/NSObject.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface ProtoEquation : NSObject
{
    NSString *name;
    NSString *comment;
    id expression;

    int cacheTag;
    double cacheValue;
}

- (id)init;
- (id)initWithName:(NSString *)newName;
- (void)dealloc;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;

- expression;
- (void)setExpression:newExpression;

- (double)evaluate:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag;
- (double)evaluate:(double *)ruleSymbols phones:phones andCacheWith:(int)newCacheTag;
- (double)cacheValue;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
