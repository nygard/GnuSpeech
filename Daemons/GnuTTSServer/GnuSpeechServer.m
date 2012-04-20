//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GnuSpeechServer.h"
#import "TextToSpeech.h"

@implementation GnuSpeechServer

#pragma mark - Internal methods.

- (int)restartServer;
{
	return 0;
}

#pragma mark - Creating and deallocating the object.

- (id)init;
{
	[super init];
	
	connection = [[NSConnection new] autorelease];
	[connection setRootObject:self];
	
	if (![connection registerName:GNUSPEECH_SERVER_REGISTERED_NAME]) {
		NSLog(@"GnuTTSServer: Unable to register name \"%@\" as it is already registered.", GNUSPEECH_SERVER_REGISTERED_NAME);
		return nil;
	}

	textToSpeech = [[TextToSpeech alloc] init];
	
	return self;
}

- (void)dealloc;
{
	NSLog(@"GnuTTSServer: Deallocating server...");
	[connection invalidate];
	[textToSpeech release];
	[super dealloc];
}

#pragma mark - Voice quality methods.

- (int)setSpeed:(float)speedValue;
{
	return 0;
}

- (float)speed;
{
	return 0;
}

- (int)setElasticity:(int)elasticityType;
{
	return 0;	
}

- (int)elasticity;
{
	return 0;
}

- (int)setIntonation:(int)intonationMask;
{
	return 0;
}

- (int)intonation;
{
	return 0;
}

- (int)setVoiceType:(int)voiceType;
{
	return 0;
}

- (int)voiceType;
{
	return 0;
}

- (int)setPitchOffset:(float)offsetValue;
{
	return 0;
}


- (float)pitchOffset;
{
	return 0;
}

- (int)setVolume:(float)volumeLevel;
{
	return 0;
}

- (float)volume;
{
	return 0;
}

- (int)setBalance:(float)balanceValue;
{
	return 0;
}

- (float)balance;
{
	return 0;
}

#pragma mark - Dictionary control methods.

- (int)setDictionaryOrder:(const short *)order;
{
	return 0;
}

- (const short *)dictionaryOrder;
{
	return NULL;
}

- (int)setAppDictPath:(const char *)path;
{
	return 0;
}

- (const char *)appDictPath;
{
	return NULL;
}

- (int)setUserDictPath:(const char *)path;
{
	return 0;
}

- (const char *)userDictPath;
{
	return NULL;
}

#pragma mark - Text input methods.

- (int)speakText:(in NSString *)text;
{
	NSLog(@"GnuTTSServer: %s %@", __PRETTY_FUNCTION__, text);	
	[textToSpeech speakText:text];
	
	return 0;
}

- (int)speakStream:(in NSStream *)stream;
{
	return 0;
}

- (int)setEscapeCharacter:(char)character;
{
	return 0;
}

- (char)escapeCharacter;
{
	return 0;
}

- (int)setBlock:(BOOL)flag;
{
	return 0;
}

- (BOOL)block;
{
	return TRUE;
}

#pragma mark - Real-time methods.

- (int)pauseImmediately;
{
	return 0;
}

- (int)pauseAfterCurrentWord;
{
	return 0;
}

- (int)pauseAfterCurrentUtterance;
{
	return 0;
}

- (int)continueImmediately;
{
	return 0;
}

- (int)eraseAllSound;
{
	return 0;
}

- (int)eraseAllWords;
{
	return 0;
}

- (int)eraseCurrentUtterance;
{
	return 0;
}

#pragma mark - Version methods.

- (const char *)serverVersion;
{
	return NULL;
}

- (const char *)dictionaryVersion;
{
	return NULL;
}

#pragma mark - Sync messaging methods.

- (id)sendSyncMessagesTo:destinationObject:(SEL)aSelector;
{
	return nil;
}

- (id)syncMessagesDestination;
{
	return nil;	
}

- (SEL)syncMessagesSelector;
{
	return nil;
}

- (int)setSyncRate:(int)rate;
{
	return 0;
}

- (int)syncRate;
{
	return 0;	
}

- (id)setSyncMessages:(BOOL)flag;
{
	return nil;	
}

- (BOOL)syncMessages;
{
	return NO;
}

#pragma mark - Real-time messaging methods.

- (id)sendRealTimeMessagesTo:destinationObject:(SEL)aSelector;
{
	return nil;
}

- (id)realTimeMessagesDestination;
{
	return nil;
}

- (SEL)realTimeMessagesSelector;
{
	return nil;
}

- (id)setRealTimeMessages:(BOOL)flag;
{
	return nil;
}

- (BOOL)realTimeMessages;
{
	return NO;
}

#pragma mark - Formerly hidden methods.

- (const char *)pronunciation:(const char *)word:(in short *)dict:(int)password;
{
	return NULL;
}

- (const char *)linePronunciation:(const char *)line:(int)password;
{
	return NULL;
}

@end

