//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSPopUpButton-Extensions.h"

#import <AppKit/AppKit.h>

@implementation NSPopUpButton (Extensions)

- (void)selectItemWithTag:(int)tag;
{
    [self selectItemAtIndex:[self indexOfItemWithTag:tag]];
}

@end
