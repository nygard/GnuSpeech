//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSObject.h>

#define NaN (1.0/0.0)
#define MAX_EVENTS 36

@interface Event : NSObject
{
    int time;
    BOOL flag;
    double events[MAX_EVENTS];
}

- (id)init;
- (id)initWithTime:(int)aTime;

- (int)time;

- (BOOL)flag;
- (void)setFlag:(BOOL)newFlag;

- (double)getValueAtIndex:(int)index;
- (void)setValue:(double)newValue ofIndex:(int)index;

- (NSString *)description;

@end
