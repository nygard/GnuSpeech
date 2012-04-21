//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#define NaN (1.0/0.0)
#define MAX_EVENTS 36

@interface Event : NSObject

- (id)initWithTime:(NSUInteger)time;

@property (readonly) NSUInteger time;
@property (assign) BOOL flag;

- (double)getValueAtIndex:(NSUInteger)index;
- (void)setValue:(double)value ofIndex:(NSUInteger)index;

- (NSString *)description;

@end
