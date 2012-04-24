//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "ApplicationController.h"
#import <GnuSpeech/GnuSpeechServerProtocol.h>
//#import <GnuSpeech/GnuSpeech.h>

@implementation ApplicationController
{
	IBOutlet NSTextView *textView;
	id ttsServerProxy;
}

- (id)init;
{
	[super init];
	ttsServerProxy = [[NSConnection rootProxyForConnectionWithRegisteredName:GNUSPEECH_SERVER_REGISTERED_NAME host:nil] retain];
	[[ttsServerProxy connectionForProxy] enableMultipleThreads];  // required for 10.4 support	
	[ttsServerProxy setProtocolForProxy:@protocol(GnuSpeechServerProtocol)];
	return self;
}

- (IBAction)speak:(id)sender;
{
	[ttsServerProxy speakText:[textView string]];	
}

- (void)dealloc;
{
	[ttsServerProxy release];
	[super dealloc];
}

@end
