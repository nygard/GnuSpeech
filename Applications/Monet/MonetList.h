/* MonetList - Base list class for all MONET list classes
 *
 * Written: Adam Fedor <fedor@gnu.org>
 * Date: Dec, 2002
 */

#import <Foundation/NSArray.h>

@class NSString;

// This contains mostly cover methods for NSMutableArray, but adds the following functionality:
// - don't crash when index out of range in -objectAtIndex:
// - don't crash when trying to add a nil object in -addObject:
// - deocodes old List objects with -initWithCoder:
// - generates XML

@interface MonetList : NSObject
{
    NSMutableArray *ilist;
}

- (id)init;
- (id)initWithCapacity:(unsigned)numItems;
- (void)dealloc;

- (NSArray *)allObjects;

- (unsigned)count;
- (unsigned)indexOfObject:(id)anObject;
- (id)lastObject;
- (void)_warning;
- (id)objectAtIndex:(unsigned)index;

- (void)makeObjectsPerformSelector:(SEL)aSelector;
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument;
- (void)sortUsingSelector:(SEL)comparator;


- (void)_addNilWarning;
- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(unsigned)index;
- (void)removeObjectAtIndex:(unsigned)index;
- (void)removeObject:(id)anObject;
- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)anObject;

- (void)removeAllObjects;
- (void)removeLastObject;
- (BOOL)containsObject:(id)anObject;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
- (void)appendXMLForObjectPointersToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;

@end
