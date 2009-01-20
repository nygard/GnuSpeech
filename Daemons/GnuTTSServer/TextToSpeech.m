//
//  TextToSpeech.m
//  GnuTTSServer
//
//  Created by Dalmazio on 05/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TextToSpeech.h"
#import "TextToPhone.h"
#import "PhoneToSpeech.h"

@implementation TextToSpeech

- (id) init;
{
	[super init];
	
	textToPhone = [[TextToPhone alloc] init];
	phoneToSpeech = [[PhoneToSpeech alloc] init];

	return self;
}

- (void) dealloc;
{
	[textToPhone release];
	[phoneToSpeech release];
	
	[super dealloc];
}

- (void) speakText:(NSString *)text;
{
	NSString * phoneString = [textToPhone phoneForText:text];	
	[phoneToSpeech speakPhoneString:phoneString];
}

@end
