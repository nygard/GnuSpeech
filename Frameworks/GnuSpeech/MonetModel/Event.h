//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#define NaN (1.0/0.0)

@interface Event : NSObject

@property (assign) NSUInteger time;
@property (assign) BOOL flag;

- (double)getValueAtIndex:(NSUInteger)index;
- (void)setValue:(double)value ofIndex:(NSUInteger)index;

@end
