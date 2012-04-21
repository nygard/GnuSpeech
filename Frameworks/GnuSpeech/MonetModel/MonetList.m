//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MonetList.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

@implementation MonetList
{
    NSMutableArray *ilist;
}

- (id)init;
{
    return [self initWithCapacity:2];
}

- (id)initWithCapacity:(NSUInteger)numItems;
{
    if ((self = [super init])) {
        ilist = [[NSMutableArray alloc] initWithCapacity:numItems];
    }

    return self;
}

- (void)dealloc;
{
    [ilist release];

    [super dealloc];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [ilist description];
}

#pragma mark -

@synthesize ilist;

- (NSArray *)allObjects;
{
    return ilist;
}

- (NSUInteger)indexOfObject:(id)anObject;
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

- (id)objectAtIndex:(NSUInteger)index;
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

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
{
    [ilist insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index;
{
    [ilist removeObjectAtIndex:index];
}

- (void)removeObject:(id)anObject;
{
    [ilist removeObject:anObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
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

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;
{
    NSUInteger count, index;

    count = [self.ilist count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", elementName];

    for (index = 0; index < count; index++)
        [[self objectAtIndex:index] appendXMLToString:resultString level:level+1];

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

- (void)appendXMLForObjectPointersToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;
{
    NSUInteger count, index;

    count = [self.ilist count];
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
