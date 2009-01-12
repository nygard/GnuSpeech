//
//  MTextToPhone.m
//  Monet
//
//  Created by Dalmazio on 05/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MTextToPhone.h"

#import <Foundation/Foundation.h>
#import <GnuSpeech/GnuSpeech.h>

@implementation MTextToPhone

- (id) init;
{
	[super init];
	
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"ShouldUseDBMFile", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldUseDBMFile"]) {
        NSLog(@"init: Using DBM dictionary.");
        [self _createDBMFileIfNecessary];
        pronunciationDictionary = [[GSDBMPronunciationDictionary mainDictionary] retain];
    } else {
        NSLog(@"init: Using simple dictionary.");
        pronunciationDictionary = [[GSSimplePronunciationDictionary mainDictionary] retain];
        [pronunciationDictionary loadDictionaryIfNecessary];
    }
	
    if ([pronunciationDictionary version] != nil)
		NSLog(@"init: Dictionary version %@", [pronunciationDictionary version]);
	
    return self;
}

- (void) dealloc;
{
    [pronunciationDictionary release];
    [super dealloc];
}

- (void) _createDBMFileIfNecessary
{
    GSSimplePronunciationDictionary * simpleDictionary;
    GSDBMPronunciationDictionary * dbmDictionary;
    NSDateFormatter * dateFormatter;
		
    simpleDictionary = [GSSimplePronunciationDictionary mainDictionary];
    dbmDictionary = [GSDBMPronunciationDictionary mainDictionary];
	
    dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d %H:%M:%S" allowNaturalLanguage:NO];
	
    NSLog(@"_createDBMFileIfNecessary: simpleDictionary modificationDate: %@", [dateFormatter stringForObjectValue:[simpleDictionary modificationDate]]);
    NSLog(@"_createDBMFileIfNecessary: dbmDictionary modificationDate: %@", [dateFormatter stringForObjectValue:[dbmDictionary modificationDate]]);
	
    [dateFormatter release];
	
    if ([dbmDictionary modificationDate] == nil || [[dbmDictionary modificationDate] compare:[simpleDictionary modificationDate]] == NSOrderedAscending) {
        [GSDBMPronunciationDictionary createDatabase:[GSDBMPronunciationDictionary mainFilename] fromSimpleDictionary:simpleDictionary];
    }
}

- (NSString *) phoneForText:(NSString *)text;
{
    NSString * inputString, * resultString;
    TTSParser * parser;
		
    inputString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];	
    parser = [[TTSParser alloc] initWithPronunciationDictionary:pronunciationDictionary];
    resultString = [parser parseString:inputString];
    [parser release];

    return resultString;	
}

- (void) loadMainDictionary;
{
    NSString * path;
    GSPronunciationDictionary * aDictionary;
		
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
    aDictionary = [[GSSimplePronunciationDictionary alloc] initWithFilename:path];
    [aDictionary loadDictionary];
    NSLog(@"loadMainDictionary: Loaded %@", aDictionary);
    [aDictionary release];	
}

@end
