//
//  GnuTTSServer.m
//  GnuTTSServer
//
//  Created by Dalmazio on 03/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GnuSpeechServer.h"
#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	GnuSpeechServer * server = [[GnuSpeechServer alloc] init];
	if (server != nil)
		[[NSRunLoop currentRunLoop] run];
	[server release];
    [pool drain];
    return 0;
}
