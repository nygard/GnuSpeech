#import "ProtoEquation.h"

#import <Foundation/Foundation.h>
#import "FormulaExpression.h"

@implementation ProtoEquation

- (id)init;
{
    if ([super init] == nil)
        return nil;

    name = nil;
    comment = nil;
    expression = nil;

    return self;
}

- (id)initWithName:(NSString *)newName;
{
    if ([self init] == nil)
        return nil;

    [self setName:newName];

    return self;
}

- (void)dealloc;
{
    [name release];
    [comment release];
    [expression release];

    [super dealloc];
}

- (NSString *)name;
{
    return name;
}

- (void)setName:(NSString *)newName;
{
    if (newName == name)
        return;

    [name release];
    name = [newName retain];
}

- (NSString *)comment;
{
    return comment;
}

- (void)setComment:(NSString *)newComment;
{
    if (newComment == comment)
        return;

    [comment release];
    comment = [newComment retain];
}

- expression;
{
    return expression;
}

- (void)setExpression:newExpression;
{
    if (newExpression == expression)
        return;

    [expression release];
    expression = [newExpression retain];
}

- (double)evaluate:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag;
{
    if (newCacheTag != cacheTag) {
        cacheTag = newCacheTag;
        cacheValue = [expression evaluate:ruleSymbols tempos:tempos phones:phones];
    }

    return cacheValue;
}

- (double)evaluate:(double *)ruleSymbols phones:phones andCacheWith:(int)newCacheTag;
{
    if (newCacheTag != cacheTag) {
        cacheTag = newCacheTag;
        cacheValue = [expression evaluate:ruleSymbols phones:phones];
    }

    return cacheValue;
}

- (double)cacheValue;
{
    return cacheValue;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    cacheTag = 0;
    cacheValue = 0.0;

    [aDecoder decodeValuesOfObjCTypes:"**", &name, &comment];
    expression = [[aDecoder decodeObject] retain];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeValuesOfObjCTypes:"**", &name, &comment];
    [aCoder encodeObject:expression];
}

#ifdef NeXT
- read:(NXTypedStream *)stream;
{

    cacheTag = 0;
    cacheValue = 0.0;

    NXReadTypes(stream, "**", &name, &comment);
    expression = NXReadObject(stream);

    return self;
}
#endif

@end
