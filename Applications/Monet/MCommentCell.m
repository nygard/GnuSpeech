//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MCommentCell.h"

#import <AppKit/AppKit.h>

static NSImage *_commentIcon = nil;

@implementation MCommentCell

+ (void)initialize;
{
    NSBundle *mainBundle;
    NSString *path;

    mainBundle = [NSBundle mainBundle];
    path = [mainBundle pathForResource:@"CommentIcon" ofType:@"tiff"];
    _commentIcon = [[NSImage alloc] initWithContentsOfFile:path];
}

// TODO (2004-08-24): Double clicking on the icon in the rule manager copies the cell, which calls -setObjectValue: with a non-NSNumber value, raising a "selector not recognized" exception.
- (void)setObjectValue:(id)newObjectValue;
{
    if ([newObjectValue boolValue] == YES)
        [super setObjectValue:_commentIcon];
    else
        [super setObjectValue:nil];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
