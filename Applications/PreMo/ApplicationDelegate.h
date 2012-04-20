//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h>

@class NSNotification;
@class GSPronunciationDictionary;
@class NSTextView;
@class NSButton;
@class NSTextField;
@class MMTextToPhone;

@interface ApplicationDelegate : NSObject
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

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (IBAction)parseText:(id)sender;
- (IBAction)lookupPronunication:(id)sender;

@end
