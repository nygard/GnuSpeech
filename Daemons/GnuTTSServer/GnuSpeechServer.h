//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GnuSpeechServerProtocol.h"
#import <Foundation/Foundation.h>

@class TextToSpeech;

@interface GnuSpeechServer : NSObject <GnuSpeechServerProtocol> {
	NSConnection * connection;
	TextToSpeech * textToSpeech;
}

/* Internal methods. */
- (int) restartServer;

/* Creating and freeing the object. */
- (id) init;
- (void) dealloc;

@end
