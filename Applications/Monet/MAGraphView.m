//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAGraphView.h"

#import <GnuSpeech/GnuSpeech.h>
#import "MMDisplayParameter.h"

@implementation MAGraphView
{
    CGFloat _timeScale;
}

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

    _timeScale = 0.5;
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
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)drawRect:(NSRect)rect;
{
    NSRect bounds = self.bounds;
    CGFloat topInset = 2.0;
    CGFloat bottomInset = 2.0;
    CGFloat trackHeight = bounds.size.height - topInset - bottomInset;

    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    bezierPath.lineWidth = 2;

    NSUInteger parameterIndex = self.displayParameter.tag;
    double currentMin = self.displayParameter.parameter.minimumValue;
    double currentMax = self.displayParameter.parameter.maximumValue;

    NSArray *events = self.eventList.events;

    BOOL isFirstPoint = YES;

    for (NSUInteger index = 0; index < [events count]; index++) {
        Event *currentEvent = events[index];

        double value = [currentEvent getValueAtIndex:parameterIndex];

        if (value != NaN) {
            CGPoint p1;
            p1.x = currentEvent.time * _timeScale;
            p1.y = rint(bottomInset + trackHeight * (value - currentMin) / (currentMax - currentMin));
            if (isFirstPoint) {
                isFirstPoint = NO;
                [bezierPath moveToPoint:p1];
            } else
                [bezierPath lineToPoint:p1];
        }
    }

    [[NSColor blackColor] set];
    [bezierPath stroke];
}

@end
