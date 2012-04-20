//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GnuSpeechServer.h"
#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GnuSpeechServer *server = [[GnuSpeechServer alloc] init];
	if (server != nil)
		[[NSRunLoop currentRunLoop] run];
	[server release];
    [pool drain];
    return 0;
}
