//
//  GnuSpeechService.m
//  GnuSpeechService
//
//  Created by Dalmazio on 03/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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
	[ttsServerProxy setProtocolForProxy:@protocol(GnuSpeechServerProtocol)];
	return self;
	
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
								   @"self couldn't speak text.");
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
