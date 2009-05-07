////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Adam Fedor
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MonetList.m
//  GnuSpeech
//
//  Created by Adam Fedor in December, 2002.
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

/* MonetList - Base list class for all MONET list classes
 *
 * Written: Adam Fedor <fedor@gnu.org>
 * Date: Dec, 2002
 */

#import "MonetList.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

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
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", elementName];

    for (index = 0; index < count; index++)
        [[self objectAtIndex:index] appendXMLToString:resultString level:level+1];

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
