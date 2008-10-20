//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h>

@class NSNotification;
@class GSPronunciationDictionary;
@class NSTextView;
@class NSButton;
@class NSTextField;

@interface ApplicationDelegate : NSObject
{
    IBOutlet NSTextView *inputTextView;
    IBOutlet NSButton *copyPhoneStringCheckBox;
    IBOutlet NSTextView *outputTextView;

    IBOutlet NSTextField *dictionaryVersionTextField;
    IBOutlet NSTextField *wordTextField;
    IBOutlet NSTextField *pronunciationTextField;

    GSPronunciationDictionary *dictionary;
}

+ (void)initialize;

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)_createDBMFileIfNecessary;

- (IBAction)parseText:(id)sender;
- (IBAction)loadMainDictionary:(id)sender;
- (IBAction)lookupPronunication:(id)sender;

@end
