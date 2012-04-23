//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface MMDriftGenerator : NSObject
{
}

- (void)configureWithDeviation:(float)deviation sampleRate:(float)sampleRate lowpassCutoff:(float)lowpassCutoff;

- (void)resetMemory;
- (float)generateDrift;

@end
