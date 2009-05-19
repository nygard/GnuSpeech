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
//  GnuSpeechServer.h
//  GnuTTSServer
//
//  Created by Dalmazio on 03/01/09.
//
//  Version: 0.1.3
//
////////////////////////////////////////////////////////////////////////////////

#import "GnuSpeechServerProtocol.h"
#import <Foundation/Foundation.h>

@class TextToSpeech;

@interface GnuSpeechServer : NSObject <GnuSpeechServerProtocol> {
	NSConnection * connection;
	TextToSpeech * textToSpeech;
}

/* Internal methods. */
- (int) restartServer;

/* Creating and freeing the object. */
- (id) init;
- (void) dealloc;

@end
