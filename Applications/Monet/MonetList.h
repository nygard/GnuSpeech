/* MonetList - Base list class for all MONET list classes
 *
 * Written: Adam Fedor <fedor@gnu.org>
 * Date: Dec, 2002
 */

#ifndef NeXT
#define DEFINE_MONET_LIST
#endif

#ifdef DEFINE_MONET_LIST
#import <Foundation/NSArray.h>

@class NSString;

@interface MonetList : NSObject <NSCoding>
{
    NSMutableArray *ilist;
}

- (id)init;
- (id)initWithCapacity:(unsigned)numItems;
- (void)dealloc;

- (unsigned)count;
- (unsigned)indexOfObject:(id)anObject;
- (id)lastObject;
- (id)objectAtIndex:(unsigned)index;

- (void)makeObjectsPerform:(SEL)aSelector;


- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(unsigned)index;
- (void)removeObjectAtIndex:(unsigned)index;
- (void)removeObject:(id)anObject;
- (void)replaceObjectAtIndex:(unsigned)index
                  withObject:(id)anObject;

- (void)removeAllObjects;
- (void)removeLastObject;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

#else
/* On Next, all the *List subclasses inherit from the obsolete List class
   so that we can read in old data files */
#import <objc/List.h>
#import <objc/typedstream.h>
#define MonetList List
#endif

#ifdef NeXT
#import <objc/List.h>
#import <objc/typedstream.h>
#import <Foundation/NSCompatibility.h>

@interface List (NSArrayCompatibility)
- (id) initWithCapacity: (unsigned)numItems;
- (unsigned) indexOfObject: (id)anObject;
- (id) objectAtIndex: (unsigned)index;


- (void) insertObject: (id)anObject atIndex: (unsigned)index;
- (void) removeObjectAtIndex: (unsigned)index;
- (void) replaceObjectAtIndex: (unsigned)index
                   withObject: (id)anObject;

- (void) removeAllObjects;
- (void) removeLastObject;

@end
#endif
