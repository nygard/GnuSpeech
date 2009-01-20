//
//  GnuSpeechServer.h
//  GnuTTSServer
//
//  Created by Dalmazio on 03/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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
