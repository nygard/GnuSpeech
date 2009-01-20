//
//  main.m
//  GnuSpeechService
//
//  Created by Dalmazio on 03/01/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

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
