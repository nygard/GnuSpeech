//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "ApplicationDelegate.h"

#import <Foundation/Foundation.h>
#import "GSPronunciationDictionary.h"
#import "TTSParser.h"

@implementation ApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSLog(@" > %s", _cmd);
    [GSPronunciationDictionary mainDictionary]; // Force it to load right away.
    NSLog(@"<  %s", _cmd);
}

- (IBAction)parseText:(id)sender;
{
    NSString *inputString, *resultString;
    TTSParser *parser;

    NSLog(@" > %s", _cmd);

    inputString = [inputTextView string];
    NSLog(@"inputString: %@", inputString);

    parser = [[TTSParser alloc] init];
    resultString = [parser parseString:inputString];
    [parser release];

    [outputTextView setString:resultString];

    NSLog(@"<  %s", _cmd);
}

@end
