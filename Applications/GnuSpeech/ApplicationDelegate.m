//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "ApplicationDelegate.h"

#import <Foundation/Foundation.h>
#import "GSPronunciationDictionary.h"
#import "GSSimplePronunciationDictionary.h"
#import "TTSParser.h"

@implementation ApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    GSPronunciationDictionary *dict;

    NSLog(@" > %s", _cmd);
    dict = [GSSimplePronunciationDictionary mainDictionary]; // Force it to load right away.
    [dictionaryVersionTextField setStringValue:[dict version]];
    NSLog(@"<  %s", _cmd);
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

    dictionary = [[GSSimplePronunciationDictionary alloc] init];
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
    [dictionary loadFromFile:path];
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
