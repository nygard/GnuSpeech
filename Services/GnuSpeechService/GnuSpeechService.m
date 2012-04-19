//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GnuSpeechService.h"
#import "GnuSpeechServerProtocol.h"

@implementation GnuSpeechService

//**********************************************************************************************************************
// Service initialization methods.
//**********************************************************************************************************************

- (id) init;
{
	[super init];
	ttsServerProxy = [[NSConnection rootProxyForConnectionWithRegisteredName:GNUSPEECH_SERVER_REGISTERED_NAME host:nil] retain];
	[[ttsServerProxy connectionForProxy] enableMultipleThreads];  // required for 10.4 support
	[ttsServerProxy setProtocolForProxy:@protocol(GnuSpeechServerProtocol)];
	return self;
	
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification;
{
}

//**********************************************************************************************************************
// Service provider methods.
//**********************************************************************************************************************

- (void) speakText:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;
{	
	NSString * pboardString;
    NSArray * types = [pboard types];
		
    if (![types containsObject:NSStringPboardType]) {
        *error = NSLocalizedString(@"Error: couldn't speak text.",
								   @"pboard couldn't give string.");
        return;
    }
	
    pboardString = [pboard stringForType:NSStringPboardType];
    if (!pboardString) {
        *error = NSLocalizedString(@"Error: couldn't speak text.",
								   @"pboard couldn't give string.");
        return;
    }
		
	int response = [ttsServerProxy speakText:pboardString];
	if (response != 0) {
		*error = NSLocalizedString(@"Error: couldn't speak text.",
								   @"Server couldn't speak text.");
		NSLog(@"%s Could not speak text.", _cmd);		
		return;
	}	
}

//**********************************************************************************************************************
// Deallocate memory.
//**********************************************************************************************************************

- (void) dealloc;
{
	[ttsServerProxy release];
	[super dealloc];
}

@end
