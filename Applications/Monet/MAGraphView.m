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

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (CGSize)intrinsicContentSize;
{
    return CGSizeMake(2000, 100);
}

- (void)setDisplayParameter:(MMDisplayParameter *)displayParameter;
{
    _displayParameter = displayParameter;
    [self setNeedsDisplay:YES];
}

- (void)setEventList:(EventList *)eventList;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventListNotification_DidGenerateOutput object:nil];

    _eventList = eventList;
    if (_eventList != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventListDidGenerateOutput:) name:EventListNotification_DidGenerateOutput object:_eventList];
    }

    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)eventListDidGenerateOutput:(NSNotification *)notification;
{
    NSLog(@"%s, displayParameter: %@", __PRETTY_FUNCTION__, self.displayParameter);
}

@end
