//
//  GnuSpeechService.h
//  GnuSpeechService
//
//  Created by Dalmazio on 03/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface GnuSpeechService : NSObject {
	id ttsServerProxy;
}

// Service initialization methods.
- (id) init;

// Service provider methods.
- (void) speakText:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;

// Deallocate memory.
- (void) dealloc;

@end
