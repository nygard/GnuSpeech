//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

// This contains mostly cover methods for NSMutableArray, but adds the following functionality:
// - don't crash when index out of range in -objectAtIndex:
// - don't crash when trying to add a nil object in -addObject:
// - generates XML

@interface MonetList : NSObject

- (id)initWithCapacity:(NSUInteger)numItems;

@property (readonly) NSMutableArray *ilist;

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;
- (void)appendXMLForObjectPointersToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;

@end
