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
//  MonetList.h
//  GnuSpeech
//
//  Created by Adam Fedor in December, 2002.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

/* MonetList - Base list class for all MONET list classes
 *
 * Written: Adam Fedor <fedor@gnu.org>
 * Date: Dec, 2002
 */

#import <Foundation/NSArray.h>

@class NSMutableString, NSString;

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

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
- (void)appendXMLForObjectPointersToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;

@end
