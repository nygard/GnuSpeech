//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#define NaN (1.0/0.0)
#define MAX_EVENTS 36

@interface Event : NSObject

- (id)init;
- (id)initWithTime:(NSUInteger)aTime;

- (NSUInteger)time;

- (BOOL)flag;
- (void)setFlag:(BOOL)newFlag;

- (double)getValueAtIndex:(NSUInteger)index;
- (void)setValue:(double)newValue ofIndex:(NSUInteger)index;

- (NSString *)description;

@end
