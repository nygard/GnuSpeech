//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSTableView.h>
#import <Foundation/NSDate.h> // To get NSTimeInterval

@class NSMutableString;

@interface MExtendedTableView : NSTableView
{
    NSTimeInterval lastTimestamp;
    NSMutableString *combinedCharacters;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)awakeFromNib;

- (void)keyDown:(NSEvent *)keyEvent;

- (void)doNotCombineNextKey;

@end
