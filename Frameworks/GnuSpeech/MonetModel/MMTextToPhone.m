//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMTextToPhone.h"

#import "GSDBMPronunciationDictionary.h"
#import "GSSimplePronunciationDictionary.h"
#import "TTSParser.h"

static GSPronunciationDictionary * pronunciationDictionary = nil;

@interface MMTextToPhone ()
+ (void)_createDBMFileIfNecessary;
@end

#pragma mark -

@implementation MMTextToPhone
{
}

+ (void)initialize;
{
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"ShouldUseDBMFile", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldUseDBMFile"]) {
        //NSLog(@"initialize: Using DBM dictionary.");
        [MMTextToPhone _createDBMFileIfNecessary];
        pronunciationDictionary = [[GSDBMPronunciationDictionary mainDictionary] retain];
    } else {
        //NSLog(@"initialize: Using simple dictionary.");
        pronunciationDictionary = [[GSSimplePronunciationDictionary mainDictionary] retain];
        [pronunciationDictionary loadDictionaryIfNecessary];
    }
	
    if ([pronunciationDictionary version] != nil) {
		//NSLog(@"initialize: Dictionary version %@", [pronunciationDictionary version]);
    }
}

+ (void)_createDBMFileIfNecessary
{
    GSSimplePronunciationDictionary *simpleDictionary = [GSSimplePronunciationDictionary mainDictionary];
    GSDBMPronunciationDictionary *dbmDictionary = [GSDBMPronunciationDictionary mainDictionary];
	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d %H:%M:%S" allowNaturalLanguage:NO];
	
    //NSLog(@"_createDBMFileIfNecessary: simpleDictionary modificationDate: %@", [dateFormatter stringForObjectValue:[simpleDictionary modificationDate]]);
    //NSLog(@"_createDBMFileIfNecessary: dbmDictionary modificationDate: %@", [dateFormatter stringForObjectValue:[dbmDictionary modificationDate]]);
	
    [dateFormatter release];
	
    if ([dbmDictionary modificationDate] == nil || [[dbmDictionary modificationDate] compare:[simpleDictionary modificationDate]] == NSOrderedAscending) {
        [GSDBMPronunciationDictionary createDatabase:[GSDBMPronunciationDictionary mainFilename] fromSimpleDictionary:simpleDictionary];
    }
}

- (NSString *)phoneForText:(NSString *)text;
{
    NSString *inputString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];	
    TTSParser *parser = [[TTSParser alloc] initWithPronunciationDictionary:pronunciationDictionary];
    NSString *resultString = [parser parseString:inputString];
    [parser release];
	
    return resultString;	
}

// TODO (2012-04-21): Uh, this method is useless.
- (void)loadMainDictionary;
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
    GSPronunciationDictionary *aDictionary = [[GSSimplePronunciationDictionary alloc] initWithFilename:path];
    [aDictionary loadDictionary];
    NSLog(@"loadMainDictionary: Loaded %@", aDictionary);
    [aDictionary release];	
}

@end
