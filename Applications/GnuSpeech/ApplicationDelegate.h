//
// $Id: ApplicationDelegate.h,v 1.2 2004/04/29 01:07:17 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface ApplicationDelegate : NSObject
{
    IBOutlet NSTextView *inputTextView;
    IBOutlet NSTextView *outputTextView;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (IBAction)parseText:(id)sender;

@end
