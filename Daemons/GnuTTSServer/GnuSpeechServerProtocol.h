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
//  GnuSpeechServerProtocol.h
//  GnuTTSServer
//
//  Created by Dalmazio on 02/01/09.
//
//	Version: 0.1.1
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

#define GNUSPEECH_SERVER_REGISTERED_NAME	@"GnuSpeechServer"  // the name registered with the port name server

@protocol GnuSpeechServerProtocol

/* Voice quality methods. */
- (int) setSpeed:(float)speedValue;
- (float) speed;
- (int) setElasticity:(int)elasticityType;
- (int) elasticity;
- (int) setIntonation:(int)intonationMask;
- (int) intonation;
- (int) setVoiceType:(int)voiceType;
- (int) voiceType;
- (int) setPitchOffset:(float)offsetValue;
- (float) pitchOffset;
- (int) setVolume:(float)volumeLevel;
- (float) volume;
- (int) setBalance:(float)balanceValue;
- (float) balance;

/* Dictionary control methods. */
- (int) setDictionaryOrder:(const short *)order;
- (const short *) dictionaryOrder;
- (int) setAppDictPath:(const char *)path;
- (const char *) appDictPath;
- (int) setUserDictPath:(const char *)path;
- (const char *) userDictPath;

/* Text input methods. */
- (int) speakText:(in NSString *)text;
- (int) speakStream:(in NSStream *)stream;
- (int) setEscapeCharacter:(char)character;
- (char) escapeCharacter;
- (int) setBlock:(BOOL)flag;
- (BOOL) block;

/* Real-time methods. */
- (int) pauseImmediately;
- (int) pauseAfterCurrentWord;
- (int) pauseAfterCurrentUtterance;
- (int) continueImmediately;
- (int) eraseAllSound;
- (int) eraseAllWords;
- (int) eraseCurrentUtterance;

/* Version methods. */
- (const char *) serverVersion;
- (const char *) dictionaryVersion;

/* Sync messaging methods. */
- (id) sendSyncMessagesTo:destinationObject:(SEL)aSelector;
- (id) syncMessagesDestination;
- (SEL) syncMessagesSelector;
- (int) setSyncRate:(int)rate;
- (int) syncRate;
- (id) setSyncMessages:(BOOL)flag;
- (BOOL) syncMessages;

/* Real-time messaging methods. */
- (id) sendRealTimeMessagesTo:destinationObject:(SEL)aSelector;
- (id) realTimeMessagesDestination;
- (SEL) realTimeMessagesSelector;
- (id) setRealTimeMessages:(BOOL)flag;
- (BOOL) realTimeMessages;

/* Formerly hidden methods. */
- (const char *) pronunciation:(const char *)word:(in short *)dict:(int)password;
- (const char *) linePronunciation:(const char *)line:(int)password;

@end
