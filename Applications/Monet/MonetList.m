/* MonetList - Base list class for all MONET list classes
 *
 * Written: Adam Fedor <fedor@gnu.org>
 * Date: Dec, 2002
 */

#define DEFINE_MONET_LIST
#import "MonetList.h"
#import <Foundation/Foundation.h>
#include <stdio.h>

@implementation MonetList

- (id)init;
{
    return [self initWithCapacity:2];
}

- (id)initWithCapacity:(unsigned)numItems;
{
    if ([super init] == nil)
        return nil;

    ilist = [[NSMutableArray alloc] initWithCapacity:numItems];

    return self;
}

- (void)dealloc;
{
    [ilist release];
    [super dealloc];
}

- (unsigned)count;
{
    return [ilist count];
}

- (unsigned)indexOfObject:(id)anObject;
{
    return [ilist indexOfObject:anObject];
}

- (id)lastObject;
{
    return [ilist lastObject];
}

- (id)objectAtIndex:(unsigned)index;
{
    return [ilist objectAtIndex:index];
}

- (void)makeObjectsPerform:(SEL)aSelector;
{
    [ilist makeObjectsPerformSelector:aSelector];
}


- (void)addObject:(id)anObject;
{
    [ilist addObject:anObject];
}

- (void)insertObject:(id)anObject atIndex:(unsigned)index;
{
    [ilist insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(unsigned)index;
{
    [ilist removeObjectAtIndex:index];
}

- (void)removeObject:(id)anObject;
{
    [ilist removeObject:anObject];
}

- (void)replaceObjectAtIndex:(unsigned)index
                  withObject:(id)anObject;
{
    [ilist replaceObjectAtIndex:index withObject:anObject];
}


- (void)removeAllObjects;
{
    [ilist removeAllObjects];
}

- (void)removeLastObject;
{
    [ilist removeLastObject];
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:ilist];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    ilist = [[aDecoder decodeObject] retain];
    return self;
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
    printf("Reading typedstream in MonetList\n");
    return self;
}
#endif

@end

#ifdef NeXT
@implementation List (NSArrayCompatibility)

- (id) initWithCapacity: (unsigned)numItems
{
    return [self initCount: numItems];
}

- (void) deallic
{
    /* Don't cause any trouble... */
    [super dealloc];
}

- (unsigned) indexOfObject: (id)anObject
{
    return [self indexOf: anObject];
}

- (id) objectAtIndex: (unsigned)index
{
    return [self objectAt: index];
}

- (void) insertObject: (id)anObject atIndex: (unsigned)index
{
    [self insertObject: anObject at: index];
}

- (void) removeObjectAtIndex: (unsigned)index
{
    [self removeObjectAt: index];
}

- (void) replaceObjectAtIndex: (unsigned)index
                   withObject: (id)anObject
{
    [self replaceObjectAt: index with: anObject];
}


- (void) removeAllObjects
{
    [self empty];
}

- removeLastObject
{
    [self removeObjectAt: [self count] - 1];
    return self;
}

- (id) replacementObjectForCoder: (NSCoder*)anEncoder
{
    /* We're being told to encode ourselves, substitute instead the MonetList
       class */
    int i, count;
    MonetList *mlist;
    count = [self count];
    mlist = [[MonetList alloc] initWithCapacity: count];
    for (i = 0; i < count; i++)
        [mlist addObject: [self objectAt: i]];
    return mlist;
}

- (void) encodeWithCoder: (NSCoder*)aCoder
{
    /* We're encoding a subclass, but now the superclass should be MonetList */
    NSArray *alist;
    alist = [NSArray arrayWithObjects: dataPtr count: [self count]];
    [aCoder encodeObject: alist];
}

- (id) initWithCoder: (NSCoder*)aDecoder
{
    NSLog(@"In List:initWithCoder - shouldn't be here");
    return self;
}

@end
#endif /* NeXT */
