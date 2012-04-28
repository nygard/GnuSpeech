//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TextToSpeech.h"

#import <GnuSpeech/GnuSpeech.h>
#import "PhoneToSpeech.h"

@implementation TextToSpeech
{
	MMTextToPhone *m_textToPhone;
	PhoneToSpeech *m_phoneToSpeech;
}

- (id)init;
{
	if ((self = [super init])) {
        m_textToPhone = [[MMTextToPhone alloc] init];
        m_phoneToSpeech = [[PhoneToSpeech alloc] init];
    }

	return self;
}

- (void)dealloc;
{
	[m_textToPhone release];
	[m_phoneToSpeech release];
	
	[super dealloc];
}

#pragma mark -

- (void)speakText:(NSString *)text;
{
	NSString *phoneString = [m_textToPhone phoneForText:text];
	[m_phoneToSpeech speakPhoneString:phoneString];
}

@end
