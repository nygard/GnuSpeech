//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MARulePhoneView.h"

@implementation MARulePhoneView

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        [self _commonInit_MARulePhoneView];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if ((self = [super initWithCoder:coder])) {
        [self _commonInit_MARulePhoneView];
    }

    return self;
}

- (void)_commonInit_MARulePhoneView;
{
    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor redColor] colorWithAlphaComponent:0.2].CGColor;
    self.layer.borderWidth = 1;
}

//- (void)drawRect:(NSRect)rect;
//{
//    [super drawRect:rect];
//}

#pragma mark -

- (CGSize)intrinsicContentSize;
{
    return CGSizeMake(10, 100);
}

@end
