#import "CategoryNode.h"

#import <Foundation/Foundation.h>
//#import <stdio.h>
//#import <string.h>
//#import <stdlib.h>

@implementation CategoryNode

- (id)init;
{
    if ([super init] == nil)
        return nil;

    symbol = nil;
    comment = nil;
    isNative = NO;

    return self;
}

- (id)initWithSymbol:(NSString *)newSymbol;
{
    if ([self init] == nil)
        return nil;

    [self setSymbol:newSymbol];

    return self;
}

- (void)dealloc;
{
    [symbol release];
    [comment release];

    [super dealloc];
}

#ifdef PORTING
- (void)freeIfNative;
{
    if (isNative)
        [self release];
}
#endif

- (NSString *)symbol;
{
    return symbol;
}

- (void)setSymbol:(NSString *)newSymbol;
{
    if (newSymbol == symbol)
        return;

    [symbol release];
    symbol = [newSymbol retain];
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

- (BOOL)isNative;
{
    return isNative;
}

- (void)setIsNative:(BOOL)newFlag;
{
    isNative = newFlag;
}

#ifdef PORTING
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [aDecoder decodeValuesOfObjCTypes:"**i", &symbol, &comment, &native];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeValuesOfObjCTypes:"**i", &symbol, &comment, &native];
}
#endif

#ifdef NeXT
- read:(NXTypedStream *)stream;
{
        NXReadTypes(stream, "**i", &symbol, &comment, &native);
        return self;
}
#endif

@end
