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
//  TextToSpeech.m
//  GnuTTSServer
//
//  Created by Dalmazio on 05/01/09.
//
//  Version: 0.1.1
//
////////////////////////////////////////////////////////////////////////////////

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