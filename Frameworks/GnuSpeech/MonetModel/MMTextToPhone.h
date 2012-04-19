//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class GSPronunciationDictionary;

@interface MMTextToPhone : NSObject {
}

+ (void)initialize;
+ (void)_createDBMFileIfNecessary;

- (id)init;
- (void)dealloc;

- (NSString *)phoneForText:(NSString *)text;

- (void)loadMainDictionary;

@end
