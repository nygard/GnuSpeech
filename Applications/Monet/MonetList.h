/* MonetList - Base list class for all MONET list classes
 *
 * Written: Adam Fedor <fedor@gnu.org>
 * Date: Dec, 2002
 */

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

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
- (void)appendXMLForObjectPointersToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;

@end
