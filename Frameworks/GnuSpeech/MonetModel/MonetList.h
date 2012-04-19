//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

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
