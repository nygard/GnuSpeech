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
    NSLog(@"path: %@", path);
    _commentIcon = [[NSImage alloc] initWithContentsOfFile:path];
}

- (void)setObjectValue:(id)newObjectValue;
{
    if ([newObjectValue boolValue] == YES)
        [super setObjectValue:_commentIcon];
    else
        [super setObjectValue:nil];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    NSLog(@"self objectValue: %@", [self objectValue]);
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
