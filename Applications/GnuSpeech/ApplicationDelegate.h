//
// $Id: ApplicationDelegate.h,v 1.3 2004/05/01 00:06:05 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface ApplicationDelegate : NSObject
{
    IBOutlet NSTextView *inputTextView;
    IBOutlet NSTextView *outputTextView;

    IBOutlet NSTextField *dictionaryVersionTextField;
    IBOutlet NSTextField *wordTextField;
    IBOutlet NSTextField *pronunciationTextField;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (IBAction)parseText:(id)sender;

- (IBAction)loadMainDictionary:(id)sender;

- (IBAction)lookupPronunication:(id)sender;

@end
