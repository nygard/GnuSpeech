//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MExtendedTableView.h"

#import <AppKit/AppKit.h>

@interface NSObject (MExtendedTableViewMethods)
- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;
@end

@implementation MExtendedTableView

- (void)keyDown:(NSEvent *)keyEvent;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"characters: %@", [keyEvent characters]);
    //NSLog(@"characters ignoring modifiers: %@", [keyEvent charactersIgnoringModifiers]);
    //NSLog(@"character count: %d", [[keyEvent characters] length]);

    if ([[self delegate] respondsToSelector:@selector(control:shouldProcessCharacters:)] == NO ||
        [[self delegate] control:self shouldProcessCharacters:[keyEvent characters]] == YES) {
        [super keyDown:keyEvent];
    }

    //NSLog(@"<  %s", _cmd);
}

@end
