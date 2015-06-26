//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAGraphView.h"

#import <GnuSpeech/GnuSpeech.h>
#import "MMDisplayParameter.h"

@implementation MAGraphView

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        [self _commonInit_MAGraphView];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if ((self = [super initWithCoder:coder])) {
        [self _commonInit_MAGraphView];
    }

    return self;
}

- (void)_commonInit_MAGraphView;
{
    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor magentaColor] colorWithAlphaComponent:0.2].CGColor;
    self.layer.borderWidth = 1;
}

- (CGSize)intrinsicContentSize;
{
    return CGSizeMake(400, 100);
}

@end
