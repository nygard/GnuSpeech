//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "ApplicationDelegate.h"

#import <Foundation/Foundation.h>
#import "GSPronunciationDictionary.h"
#import "GSDBMPronunciationDictionary.h"
#import "GSSimplePronunciationDictionary.h"
#import "TTSParser.h"

@implementation ApplicationDelegate

- (id)init;
{
    if ([super init] == nil)
        return nil;

    dictionaryClass = [GSDBMPronunciationDictionary class];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    GSPronunciationDictionary *dict;

    NSLog(@" > %s", _cmd);
    dict = [dictionaryClass mainDictionary]; // Force it to load right away (for the simple version only).
    if ([dict version] != nil)
        [dictionaryVersionTextField setStringValue:[dict version]];

    //[GSDBMPronunciationDictionary createDatabase:@"/tmp/test1" fromSimpleDictionary:[GSSimplePronunciationDictionary mainDictionary]];
    NSLog(@"<  %s", _cmd);
}

- (void)_createDBMFileIfNecessary;
{
}

- (IBAction)parseText:(id)sender;
{
    NSString *inputString, *resultString;
    TTSParser *parser;

    NSLog(@" > %s", _cmd);

    inputString = [[inputTextView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"inputString: %@", inputString);

    parser = [[TTSParser alloc] init];
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
    GSPronunciationDictionary *dictionary;

    NSLog(@" > %s", _cmd);

    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
    dictionary = [[GSSimplePronunciationDictionary alloc] initWithFilename:path];
    [dictionary loadDictionary];
    NSLog(@"loaded %@", dictionary);
    [dictionary release];

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
