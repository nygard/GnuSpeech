//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <AppKit/AppKit.h>

@interface GnuSpeechService : NSObject

// Service initialization methods.
- (id)init;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

// Service provider methods.
- (void)speakText:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;

@end
