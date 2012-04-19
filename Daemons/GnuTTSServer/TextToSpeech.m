//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TextToSpeech.h"
#import "PhoneToSpeech.h"

#import <GnuSpeech/GnuSpeech.h>

@implementation TextToSpeech

- (id) init;
{
	[super init];
	
	textToPhone = [[MMTextToPhone alloc] init];
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
