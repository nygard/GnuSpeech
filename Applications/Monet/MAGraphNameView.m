//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAGraphNameView.h"

@interface MAGraphNameView ()
@property (strong) NSTextField *nameTextField;
@end

@implementation MAGraphNameView
{
}

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        [self _commonInit_MAGraphNameView];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if ((self = [super initWithCoder:coder])) {
        [self _commonInit_MAGraphNameView];
    }

    return self;
}

- (void)_commonInit_MAGraphNameView;
{
    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor greenColor] colorWithAlphaComponent:0.2].CGColor;
}

#pragma mark -

@end
