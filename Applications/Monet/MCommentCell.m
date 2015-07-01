//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MCommentCell.h"

static NSImage *_commentIcon = nil;

@implementation MCommentCell
{
}

+ (void)initialize;
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"CommentIcon" ofType:@"tiff"];
    _commentIcon = [[NSImage alloc] initWithContentsOfFile:path];
}

- (void)setObjectValue:(id)newObjectValue;
{
    if ([newObjectValue isKindOfClass:[NSNumber class]]) {
        if ([newObjectValue boolValue])
            [super setObjectValue:_commentIcon];
        else
            [super setObjectValue:nil];
    } else {
        [super setObjectValue:newObjectValue];
    }
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
