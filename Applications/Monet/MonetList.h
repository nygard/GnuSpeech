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
- (void)replaceObjectAtIndex:(unsigned)index
                  withObject:(id)anObject;

- (void)removeAllObjects;
- (void)removeLastObject;
- (BOOL)containsObject:(id)anObject;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level numberItems:(BOOL)shouldNumberItems;
- (void)appendXMLForObjectPointersToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;

@end
