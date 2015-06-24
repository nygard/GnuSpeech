//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "ApplicationDelegate.h"

#import <GnuSpeech/GnuSpeech.h>

@implementation ApplicationDelegate
{
    IBOutlet NSTextView *inputTextView;
    IBOutlet NSButton *copyPhoneStringCheckBox;
    IBOutlet NSTextView *outputTextView;
    
    IBOutlet NSTextField *dictionaryVersionTextField;
    IBOutlet NSTextField *wordTextField;
    IBOutlet NSTextField *pronunciationTextField;
    
    GSPronunciationDictionary *dictionary;
	MMTextToPhone *textToPhone;
}

+ (void)initialize;
{
}

- (id)init;
{
    if ((self = [super init])) {
        textToPhone = [[MMTextToPhone alloc] init];
    }

    return self;
}

- (void)dealloc;
{
	[textToPhone release];
	
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
}

- (IBAction)parseText:(id)sender;
{
    NSString *inputString, *resultString;

    NSLog(@"> %s", __PRETTY_FUNCTION__);

    inputString = [[inputTextView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"parseText: inputString is: %@", inputString);

    resultString = [textToPhone phoneForText:inputString];

    [outputTextView setString:resultString];
    [outputTextView selectAll:nil];

    if ([copyPhoneStringCheckBox state])
        [outputTextView copy:nil];

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)lookupPronunication:(id)sender;
{
    NSString *word, *pronunciation;

    word = [[wordTextField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    pronunciation = [[GSSimplePronunciationDictionary mainDictionary] pronunciationForWord:word];
    //NSLog(@"word: %@, pronunciation: %@", word, pronunciation);
    if (pronunciation == nil) {
        //NSBeep();
        pronunciation = @"Pronunciation not found.";
    }

    [pronunciationTextField setStringValue:pronunciation];
}

@end
