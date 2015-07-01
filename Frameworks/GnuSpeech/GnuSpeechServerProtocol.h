//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#define GNUSPEECH_SERVER_REGISTERED_NAME	@"GnuSpeechServer"  // the name registered with the port name server

@protocol GnuSpeechServerProtocol

// Voice quality methods
- (int)setSpeed:(float)speedValue;
- (float)speed;
- (int)setElasticity:(int)elasticityType;
- (int)elasticity;
- (int)setIntonation:(int)intonationMask;
- (int)intonation;
- (int)setVoiceType:(int)voiceType;
- (int)voiceType;
- (int)setPitchOffset:(float)offsetValue;
- (float)pitchOffset;
- (int)setVolume:(float)volumeLevel;
- (float)volume;
- (int)setBalance:(float)balanceValue;
- (float)balance;

// Dictionary control methods
- (int)setDictionaryOrder:(const short *)order;
- (const short *)dictionaryOrder;
- (int)setAppDictPath:(const char *)path;
- (const char *)appDictPath;
- (int)setUserDictPath:(const char *)path;
- (const char *)userDictPath;

// Text input methods
- (int)speakText:(in NSString *)text;
- (int)speakStream:(in NSStream *)stream;
- (int)setEscapeCharacter:(char)character;
- (char)escapeCharacter;
- (int)setBlock:(BOOL)flag;
- (BOOL)block;

// Real-time methods
- (int)pauseImmediately;
- (int)pauseAfterCurrentWord;
- (int)pauseAfterCurrentUtterance;
- (int)continueImmediately;
- (int)eraseAllSound;
- (int)eraseAllWords;
- (int)eraseCurrentUtterance;

// Version methods
- (const char *)serverVersion;
- (const char *)dictionaryVersion;

// Sync messaging methods
- (id)sendSyncMessagesTo:(id)destinationObject selector:(SEL)aSelector;
- (id)syncMessagesDestination;
- (SEL)syncMessagesSelector;
- (int)setSyncRate:(int)rate;
- (int)syncRate;
- (id)setSyncMessages:(BOOL)flag;
- (BOOL)syncMessages;

// Real-time messaging methods
- (id)sendRealTimeMessagesTo:(id)destinationObject selector:(SEL)aSelector;
- (id)realTimeMessagesDestination;
- (SEL)realTimeMessagesSelector;
- (id)setRealTimeMessages:(BOOL)flag;
- (BOOL)realTimeMessages;

// Formerly hidden methods
- (const char *)pronunciation:(const char *)word dict:(in short *)dict password:(int)password;
- (const char *)linePronunciation:(const char *)line password:(int)password;

@end
