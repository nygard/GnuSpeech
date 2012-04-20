//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "GnuSpeechServerProtocol.h"

@class TextToSpeech;

@interface GnuSpeechServer : NSObject <GnuSpeechServerProtocol>
{
	NSConnection *connection;
	TextToSpeech *textToSpeech;
}

/* Internal methods. */
- (int)restartServer;

- (id)init;
- (void)dealloc;

@end
