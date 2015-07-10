//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MARulePhoneView.h"

#import <GnuSpeech/GnuSpeech.h>

#define HEIGHT (40)

// TODO: (2015-06-28) Perhaps this would be better as two separate views, one for rules and one for postures.  Then we could baseline align the labels.
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
    //self.layer.backgroundColor = [[NSColor redColor] colorWithAlphaComponent:0.2].CGColor;
    //self.layer.borderWidth = 1;

    _scale = 0.5;

    _ruleCell = [[NSTextFieldCell alloc] initTextCell:@""];
    [_ruleCell setFont:[NSFont labelFontOfSize:10.0]];
    [_ruleCell setAlignment:NSCenterTextAlignment];
    [_ruleCell setBordered:NO];
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

    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (void)setScale:(CGFloat)scale;
{
    _scale = scale;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (void)setRightEdgeInset:(CGFloat)rightEdgeInset;
{
    _rightEdgeInset = rightEdgeInset;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

#pragma mark -

+ (BOOL)requiresConstraintBasedLayout;
{
    return YES;
}

- (CGSize)intrinsicContentSize;
{
    if (self.eventList == nil) {
        return CGSizeMake(800, HEIGHT);
    }

    CGSize size = CGSizeMake(0, HEIGHT);
    Event *lastEvent = self.eventList.events.lastObject;
    if (lastEvent == nil) {
        return CGSizeMake(800, HEIGHT);
    }

    CGFloat leftInset = 5.0;
    CGFloat rightInset = 15.0;

    size.width = leftInset + lastEvent.time * _scale + rightInset + _rightEdgeInset;
    return size;
}

- (void)drawRect:(NSRect)rect;
{
    CGFloat leftInset = 5.0;
    [super drawRect:rect];

    NSMutableArray *postureEvents = [[NSMutableArray alloc] init];
    for (Event *event in self.eventList.events) {
        if (event.isAtPosture) {
            [postureEvents addObject:event];
        }
    }

    {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        CGFloat top    = 19;
        CGFloat bottom = 1;

        [path moveToPoint:NSMakePoint(leftInset,                                        top)];
        [path lineToPoint:NSMakePoint(NSMaxX(self.bounds) - 15.0 - self.rightEdgeInset, top)];
        [path moveToPoint:NSMakePoint(leftInset,                                        bottom)];
        [path lineToPoint:NSMakePoint(NSMaxX(self.bounds) - 15.0 - self.rightEdgeInset, bottom)];
        [path moveToPoint:NSMakePoint(leftInset,                                        top)];
        [path lineToPoint:NSMakePoint(leftInset,                                        bottom)];

        NSUInteger count = [self.eventList ruleCount];
        //NSLog(@"count: %lu", count);
        for (NSUInteger index = 0; index < count; index++) {
            MMRuleValues *ruleValues = [self.eventList ruleValuesAtIndex:index];

            NSParameterAssert(ruleValues.firstPhone < [postureEvents count]);
            NSParameterAssert(ruleValues.lastPhone < [postureEvents count]);
            Event *e1 = postureEvents[ruleValues.firstPhone];
            Event *e2 = postureEvents[ruleValues.lastPhone];
            CGFloat left  = leftInset + e1.time * _scale;
            CGFloat right = leftInset + e2.time * _scale;
            NSRect cellFrame;
            cellFrame.origin.x = left;
            cellFrame.origin.y = 1 - 3;
            cellFrame.size.height = 18.0;
            cellFrame.size.width = rint(right - left);
            //NSLog(@"%3lu: %@", index, NSStringFromRect(cellFrame));

            [_ruleCell setIntegerValue:ruleValues.number];
            [_ruleCell drawWithFrame:cellFrame inView:self];

            [path moveToPoint:NSMakePoint(right, top)];
            [path lineToPoint:NSMakePoint(right, bottom)];
        }

        [[NSColor blackColor] set];
        [path stroke];
    }

    CGFloat currentX = 0;

    // Draw phones/postures along top
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
                [[currentPhone name] drawAtPoint:NSMakePoint(currentX, 20) withAttributes:nil];
            }
        }
    }

    [[NSColor lightGrayColor] set];
    [bezierPath stroke];
}

#pragma mark -

- (void)eventListDidGenerateOutput:(NSNotification *)notification;
{
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

@end
