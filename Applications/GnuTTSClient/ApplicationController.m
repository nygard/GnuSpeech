//
//  ApplicationController.m
//  TTSClient
//
//  Created by Dalmazio on 02/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApplicationController.h"
#import "GnuSpeechServerProtocol.h"

@implementation ApplicationController

- (id) init;
{
	[super init];
	ttsServerProxy = [[NSConnection rootProxyForConnectionWithRegisteredName:GNUSPEECH_SERVER_REGISTERED_NAME host:nil] retain];
	[ttsServerProxy setProtocolForProxy:@protocol(GnuSpeechServerProtocol)];
	return self;
}

- (void) speak:(id)sender;
{
	[ttsServerProxy speakText:[textView string]];	
}

- (void) dealloc;
{
	[ttsServerProxy release];
	[super dealloc];
}

@end
