/* MonetList - Base list class for all MONET list classes
 *
 * Written: Adam Fedor <fedor@gnu.org>
 * Date: Dec, 2002
 */

#import "MonetList.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

@protocol AlternateXMLMethod
- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level number:(int)number;
@end


#import "MMTarget.h" // Hack, just to get -appendXMLToString:level:

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

- (NSArray *)allObjects;
{
    return ilist;
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

- (void)_warning;
{
    //NSLog(@"%s", _cmd);
}

- (id)objectAtIndex:(unsigned)index;
{
    if (index >= [ilist count]) {
        //NSLog(@"Warning: index out of range in %s, returning nil for compatibility with List from NS3.3", _cmd);
        [self _warning];
        return nil;
    }
    return [ilist objectAtIndex:index];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector;
{
    [ilist makeObjectsPerformSelector:aSelector];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument;
{
    [ilist makeObjectsPerformSelector:aSelector withObject:argument];
}

- (void)sortUsingSelector:(SEL)comparator;
{
    [ilist sortUsingSelector:comparator];
}

- (void)_addNilWarning;
{
    NSLog(@"Tried to add nil.");
}

- (void)addObject:(id)anObject;
{
    if (anObject == nil) {
        NSLog(@"Warning: trying to insert nil into MonetList.  Ignoring, for compatibility with List from NS3.3");
        [self _addNilWarning];
        return;
    }
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

- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)anObject;
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

- (BOOL)containsObject:(id)anObject;
{
    return [ilist containsObject:anObject];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int count;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    // TODO (2004-03-05): On second thought I don't think these should call init -- also doing so in subclasses may cause problems, multiple-initialization
    ilist = [[NSMutableArray alloc] init];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);
    //NSLog(@"aDecoder version for class %@ is: %u", @"List", archivedVersion);

    count = 0;
    [aDecoder decodeValueOfObjCType:@encode(int) at:&count];
    //NSLog(@"count: %d", count);

    if (count > 0) {
        id *array;

        array = malloc(count * sizeof(id *));
        if (array == NULL) {
            NSLog(@"malloc()'ing %d id *'s failed.", count);
        } else {
            int index;

            [aDecoder decodeArrayOfObjCType:@encode(id) count:count at:array];

            for (index = 0; index < count; index++)
                [self addObject:array[index]];

            free(array);
        }
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [ilist description];
}

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
{
    [self appendXMLToString:resultString elementName:elementName level:level numberItems:NO];
}

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level numberItems:(BOOL)shouldNumberItems;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", elementName];

    for (index = 0; index < count; index++) {
        id anObject;

        anObject = [self objectAtIndex:index];
        if (shouldNumberItems == YES && [anObject respondsToSelector:@selector(appendXMLToString:level:number:)] == YES)
            [anObject appendXMLToString:resultString level:level+1 number:index+1];
        else
            [anObject appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

- (void)appendXMLForObjectPointersToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", elementName];

    for (index = 0; index < count; index++) {
        id anObject;

        anObject = [self objectAtIndex:index];
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<object ptr=\"%p\" class=\"%@\"/>\n", anObject, NSStringFromClass([anObject class])];
    }

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

@end
