//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MARulePhoneView.h"

#import <GnuSpeech/GnuSpeech.h>

#define TRACKHEIGHT		(120.0)

@implementation MARulePhoneView
{
    NSTextFieldCell *_ruleCell;
}

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

    _scale = 0.5;

    _ruleCell = [[NSTextFieldCell alloc] initTextCell:@""];
    [_ruleCell setFont:[NSFont labelFontOfSize:10.0]];
    [_ruleCell setAlignment:NSCenterTextAlignment];
    [_ruleCell setBordered:YES];
    [_ruleCell setEnabled:YES];
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)setEventList:(EventList *)eventList;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventListNotification_DidGenerateOutput object:nil];

    _eventList = eventList;
    if (_eventList != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventListDidGenerateOutput:) name:EventListNotification_DidGenerateOutput object:_eventList];
    }

    [self setNeedsDisplay:YES];
}

- (void)setScale:(CGFloat)scale;
{
    _scale = scale;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)drawRect:(NSRect)rect;
{
    CGFloat leftInset = 5.0;
    [super drawRect:rect];

    NSRect bounds = NSIntegralRect([self bounds]);
    //NSLog(@"%s, bounds: %@", __PRETTY_FUNCTION__, NSStringFromRect(bounds));

    NSFont *font = [NSFont systemFontOfSize:10];

    [font set];
    CGFloat currentX = 0;
    CGFloat extraWidth = 0.0;

    NSUInteger count = [self.eventList ruleCount];
    //NSLog(@"count: %lu", count);
    for (NSUInteger index = 0; index < count; index++) {
        struct _rule *rule = [self.eventList getRuleAtIndex:index];

        NSRect cellFrame;
        cellFrame.origin.x = leftInset + currentX;
        cellFrame.origin.y = bounds.size.height - 25.0;
        cellFrame.size.height = 18.0;
        cellFrame.size.width = rule->duration * _scale + extraWidth;
        //NSLog(@"%3lu: %@", index, NSStringFromRect(cellFrame));

        [_ruleCell setIntegerValue:rule->number];
        [_ruleCell drawWithFrame:cellFrame inView:self];

        extraWidth = 1.0;
        currentX += cellFrame.size.width - extraWidth;
    }

    // Draw phones/postures along top
    [font set];
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];

    NSUInteger phoneIndex = 0;
    NSArray *events = [_eventList events];
    for (NSUInteger index = 0; index < [events count]; index++) {
        currentX = leftInset + [[events objectAtIndex:index] time] * _scale;

        if ([[events objectAtIndex:index] isAtPosture]) {
            MMPosture *currentPhone = [_eventList getPhoneAtIndex:phoneIndex++];
            if (currentPhone) {
                [[NSColor blackColor] set];
                [[currentPhone name] drawAtPoint:NSMakePoint(currentX, bounds.size.height - 42.0) withAttributes:nil];
            }
        }

//        [bezierPath moveToPoint:NSMakePoint(currentX + 0.5, bounds.size.height - (50.0 + 1.0 + (float)j * TRACKHEIGHT))];
//        [bezierPath lineToPoint:NSMakePoint(currentX + 0.5, bounds.size.height - 50.0 - 1.0)];
    }

    [[NSColor lightGrayColor] set];
    [bezierPath stroke];
}

#pragma mark -

- (CGSize)intrinsicContentSize;
{
    return CGSizeMake(800, 50);
}

#pragma mark -

- (void)eventListDidGenerateOutput:(NSNotification *)notification;
{
    [self setNeedsDisplay:YES];
}

@end
