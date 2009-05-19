////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Dalmazio Brisinda
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  GnuSpeechService.m
//  GnuSpeechService
//
//  Created by Dalmazio on 03/01/09.
//
//  Version: 0.5.1
//
////////////////////////////////////////////////////////////////////////////////

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
