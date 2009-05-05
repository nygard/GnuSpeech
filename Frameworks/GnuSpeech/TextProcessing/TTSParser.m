////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard, Dalmazio Brisinda
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
//  TTSParser.m
//  GnuSpeech
//
//  Created by Dalmazio Brisinda on 04/27/2009.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "TTSParser.h"
#import "NSScanner-Extensions.h"
#import "NSString-Extensions.h"
#import "GSPronunciationDictionary.h"

#import "parser_module.h"

/*  Dictionary Ordering Definitions - from TTS_types.h  */
#define TTS_EMPTY                       0
#define TTS_NUMBER_PARSER               1
#define TTS_USER_DICTIONARY             2
#define TTS_APPLICATION_DICTIONARY      3
#define TTS_MAIN_DICTIONARY             4
#define TTS_LETTER_TO_SOUND             5


@implementation TTSParser

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)aDictionary;
{
    [super init];

	NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SpecialAcronyms" ofType:@"plist"];
    NSLog(@"path: %@", path);
	
    specialAcronyms = [[[NSDictionary alloc] initWithContentsOfFile:path] retain];
    NSLog(@"specialAcronyms: %@", [specialAcronyms description]);
	
	userDictionary = [aDictionary retain];
	appDictionary = [aDictionary retain];
    mainDictionary = [aDictionary retain];	
	
    //[mainDictionary loadDictionary];

    return self;
}

- (void)dealloc;
{
    [mainDictionary release];
    [appDictionary release];
    [userDictionary release];	
	
	[specialAcronyms release];
	
    [super dealloc];
}

- (NSString *)parseString:(NSString *)aString;
{
	NSLog(@"> %s", _cmd);

	short order[4];
	
	/*  INITIALIZE PARSER MODULE  */
	init_parser_module();
	
	/*  SET ESCAPE CODE  */
	set_escape_code('%');
			
	order[0] = TTS_NUMBER_PARSER;
	order[1] = TTS_USER_DICTIONARY;
	order[2] = TTS_APPLICATION_DICTIONARY;
	order[3] = TTS_MAIN_DICTIONARY;
	
	set_dict_data(order, userDictionary, appDictionary, mainDictionary, specialAcronyms);
		
	const char * input = [aString cStringUsingEncoding:NSASCIIStringEncoding];
	const char * output;
	
	NSLog(@"input: %s", input);

	// TODO: check return type.
	parser(input, &output);
	
	NSLog(@"output: %s", output);
	
    NSString * resultString = [NSString stringWithCString:output encoding:NSASCIIStringEncoding];
	
    NSLog(@"resultString: %@", resultString);	
    NSLog(@"< %s", _cmd);

	return resultString;	
}

@end
