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
//  GnuSpeechServer.m
//  GnuTTSServer
//
//  Created by Dalmazio on 03/01/09.
//
//	Version: 0.1.1
//
////////////////////////////////////////////////////////////////////////////////

#import "GnuSpeechServer.h"
#import "TextToSpeech.h"

@implementation GnuSpeechServer

//**********************************************************************************************************************
// Internal methods.
//**********************************************************************************************************************

- (int) restartServer;
{
	return 0;
}

//**********************************************************************************************************************
// Creating and deallocating the object.
//**********************************************************************************************************************

- (id) init;
{
	[super init];
	
	connection = [NSConnection defaultConnection];
	[connection setRootObject:self];
	if (![connection registerName:GNUSPEECH_SERVER_REGISTERED_NAME]) {
		NSLog([NSString stringWithFormat:@"GnuTTSServer: Unable to register name \"%@\" as it is already registered.", GNUSPEECH_SERVER_REGISTERED_NAME]);
		return nil;
	}

	textToSpeech = [[TextToSpeech alloc] init];
	
	return self;
}

- (void) dealloc;
{
	NSLog(@"GnuTTSServer: Deallocating server...");
	[connection invalidate];
	[textToSpeech release];
	[super dealloc];
}

//**********************************************************************************************************************
// Voice quality methods.
//********************************************************************************************************************** 

- (int) setSpeed:(float)speedValue;
{
	return 0;
}

- (float) speed;
{
	return 0;
}

- (int) setElasticity:(int)elasticityType;
{
	return 0;	
}

- (int) elasticity;
{
	return 0;
}

- (int) setIntonation:(int)intonationMask;
{
	return 0;
}

- (int) intonation;
{
	return 0;
}

- (int) setVoiceType:(int)voiceType;
{
	return 0;
}

- (int) voiceType;
{
	return 0;
}

- (int) setPitchOffset:(float)offsetValue;
{
	return 0;
}


- (float) pitchOffset;
{
	return 0;
}

- (int) setVolume:(float)volumeLevel;
{
	return 0;
}

- (float) volume;
{
	return 0;
}

- (int) setBalance:(float)balanceValue;
{
	return 0;
}

- (float) balance;
{
	return 0;
}

//**********************************************************************************************************************
// Dictionary control methods.
//**********************************************************************************************************************

- (int) setDictionaryOrder:(const short *)order;
{
	return 0;
}

- (const short *) dictionaryOrder;
{
	return NULL;
}

- (int) setAppDictPath:(const char *)path;
{
	return 0;
}

- (const char *) appDictPath;
{
	return NULL;
}

- (int) setUserDictPath:(const char *)path;
{
	return 0;
}

- (const char *) userDictPath;
{
	return NULL;
}

//**********************************************************************************************************************
// Text input methods.
//**********************************************************************************************************************

- (int) speakText:(in NSString *)text;
{
	NSLog(@"GnuTTSServer: Text: %@", text);	
	[textToSpeech speakText:text];
	
	return 0;
}

- (int) speakStream:(in NSStream *)stream;
{
	return 0;
}

- (int) setEscapeCharacter:(char)character;
{
	return 0;
}

- (char) escapeCharacter;
{
	return 0;
}

- (int) setBlock:(BOOL)flag;
{
	return 0;
}

- (BOOL) block;
{
	return TRUE;
}

//**********************************************************************************************************************
// Real-time methods.
//**********************************************************************************************************************

- (int) pauseImmediately;
{
	return 0;
}

- (int) pauseAfterCurrentWord;
{
	return 0;
}

- (int) pauseAfterCurrentUtterance;
{
	return 0;
}

- (int) continueImmediately;
{
	return 0;
}

- (int) eraseAllSound;
{
	return 0;
}

- (int) eraseAllWords;
{
	return 0;
}

- (int) eraseCurrentUtterance;
{
	return 0;
}

//**********************************************************************************************************************
// Version methods.
//**********************************************************************************************************************

- (const char *) serverVersion;
{
	return NULL;
}

- (const char *) dictionaryVersion;
{
	return NULL;
}

//**********************************************************************************************************************
// Sync messaging methods.
//**********************************************************************************************************************

- (id) sendSyncMessagesTo:destinationObject:(SEL)aSelector;
{
	return nil;
}

- (id) syncMessagesDestination;
{
	return nil;	
}

- (SEL) syncMessagesSelector;
{
	return nil;
}

- (int) setSyncRate:(int)rate;
{
	return 0;
}

- (int) syncRate;
{
	return 0;	
}

- (id) setSyncMessages:(BOOL)flag;
{
	return nil;	
}

- (BOOL) syncMessages;
{
	return NO;
}

//**********************************************************************************************************************
// Real-time messaging methods.
//**********************************************************************************************************************

- (id) sendRealTimeMessagesTo:destinationObject:(SEL)aSelector;
{
	return nil;
}

- (id) realTimeMessagesDestination;
{
	return nil;
}

- (SEL) realTimeMessagesSelector;
{
	return nil;
}

- (id) setRealTimeMessages:(BOOL)flag;
{
	return nil;
}

- (BOOL) realTimeMessages;
{
	return NO;
}

//**********************************************************************************************************************
// Formerly hidden methods.
//**********************************************************************************************************************

- (const char *) pronunciation:(const char *)word:(in short *)dict:(int)password;
{
	return NULL;
}

- (const char *) linePronunciation:(const char *)line:(int)password;
{
	return NULL;
}

@end

