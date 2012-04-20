//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>
#import "GnuSpeechService.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	GnuSpeechService * gnuSpeechService = [[GnuSpeechService alloc] init];
	NSRegisterServicesProvider(gnuSpeechService, @"GnuSpeechService");
	[[NSRunLoop currentRunLoop] run];
	[gnuSpeechService release];
	
    [pool drain];
    return 0;
}
