//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "ApplicationDelegate.h"

#import <Foundation/Foundation.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSButton.h>

#import "GSPronunciationDictionary.h"
#import "GSDBMPronunciationDictionary.h"
#import "GSSimplePronunciationDictionary.h"
#import "TTSParser.h"

@implementation ApplicationDelegate

+ (void)initialize;
{
    NSDictionary *dict;

    dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"ShouldUseDBMFile",
                         nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    dictionary = nil;

    return self;
}

- (void)dealloc;
{
    [dictionary release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSLog(@" > %s", _cmd);

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldUseDBMFile"]) {
        NSLog(@"Using DBM dictionary.");
        [self _createDBMFileIfNecessary];
        dictionary = [[GSDBMPronunciationDictionary mainDictionary] retain];
    } else {
        NSLog(@"Using simple dictionary.");
        dictionary = [[GSSimplePronunciationDictionary mainDictionary] retain];
        [dictionary loadDictionaryIfNecessary];
    }

    if ([dictionary version] != nil)
        [dictionaryVersionTextField setStringValue:[dictionary version]];

    NSLog(@"<  %s", _cmd);
}

- (void)_createDBMFileIfNecessary
{
    GSSimplePronunciationDictionary *simpleDictionary;
    GSDBMPronunciationDictionary *dbmDictionary;
    NSDateFormatter *dateFormatter;

    NSLog(@" > %s", _cmd);

    simpleDictionary = [GSSimplePronunciationDictionary mainDictionary];
    dbmDictionary = [GSDBMPronunciationDictionary mainDictionary];

    dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d %H:%M:%S" allowNaturalLanguage:NO];

    NSLog(@"simpleDictionary modificationDate: %@", [dateFormatter stringForObjectValue:[simpleDictionary modificationDate]]);
    NSLog(@"dbmDictionary modificationDate: %@", [dateFormatter stringForObjectValue:[dbmDictionary modificationDate]]);

    [dateFormatter release];

    if ([dbmDictionary modificationDate] == nil || [[dbmDictionary modificationDate] compare:[simpleDictionary modificationDate]] == NSOrderedAscending) {
        [GSDBMPronunciationDictionary createDatabase:[GSDBMPronunciationDictionary mainFilename] fromSimpleDictionary:simpleDictionary];
    }

    // TODO (2004-08-21): And unfortunately it leaves the simple dictionary around in memory, but... it's good enough for now.

    NSLog(@"<  %s", _cmd);
}

- (IBAction)parseText:(id)sender;
{
    NSString *inputString, *resultString;
    TTSParser *parser;

    NSLog(@" > %s", _cmd);

    inputString = [[inputTextView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"inputString: %@", inputString);

    parser = [[TTSParser alloc] initWithPronunciationDictionary:dictionary];
    resultString = [parser parseString:inputString];
    [parser release];

    [outputTextView setString:resultString];
    [outputTextView selectAll:nil];

    if ([copyPhoneStringCheckBox state])
        [outputTextView copy:nil];

    NSLog(@"<  %s", _cmd);
}

- (IBAction)loadMainDictionary:(id)sender;
{
    NSString *path;
    GSPronunciationDictionary *aDictionary;

    NSLog(@" > %s", _cmd);

    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
    aDictionary = [[GSSimplePronunciationDictionary alloc] initWithFilename:path];
    [aDictionary loadDictionary];
    NSLog(@"loaded %@", aDictionary);
    [aDictionary release];

    NSLog(@"<  %s", _cmd);
}

- (IBAction)lookupPronunication:(id)sender;
{
    NSString *word, *pronunciation;

    word = [[wordTextField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    pronunciation = [[GSSimplePronunciationDictionary mainDictionary] pronunciationForWord:word];
    //NSLog(@"word: %@, pronunciation: %@", word, pronunciation);
    if (pronunciation == nil) {
        //NSBeep();
        pronunciation = @"Pronunciation not found";
    }

    [pronunciationTextField setStringValue:pronunciation];
}

@end
