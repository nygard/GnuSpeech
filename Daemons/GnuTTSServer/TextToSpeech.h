//
//  TextToSpeech.h
//  GnuTTSServer
//
//  Created by Dalmazio on 05/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TextToPhone, PhoneToSpeech;

@interface TextToSpeech : NSObject {
	TextToPhone * textToPhone;
	PhoneToSpeech * phoneToSpeech;
}

- (id) init;
- (void) dealloc;

- (void) speakText:(NSString *)text;

@end
