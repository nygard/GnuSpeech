//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class MMTextToPhone, PhoneToSpeech;

@interface TextToSpeech : NSObject

- (id)init;
- (void)dealloc;

- (void)speakText:(NSString *)text;

@end
