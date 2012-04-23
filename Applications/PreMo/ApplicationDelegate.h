//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class GSPronunciationDictionary;
@class MMTextToPhone;

@interface ApplicationDelegate : NSObject

+ (void)initialize;

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (IBAction)parseText:(id)sender;
- (IBAction)lookupPronunication:(id)sender;

@end
