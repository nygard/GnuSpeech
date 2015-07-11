//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAGraphView.h"

#import <GnuSpeech/GnuSpeech.h>
#import "MMDisplayParameter.h"

@interface MAGraphView ()
@property (strong) NSTrackingArea *trackingArea;
@end

@implementation MAGraphView
{
    CGFloat _leftInset;
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
    //self.layer.backgroundColor = [[NSColor magentaColor] colorWithAlphaComponent:0.2].CGColor;
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    //self.layer.borderWidth = 1;

    _scale = 0.5;
    _leftInset = 5.0;

    _selectedXPosition = -1;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSViewFrameDidChangeNotification object:self];
    self.postsFrameChangedNotifications = YES;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

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

    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (void)setScale:(CGFloat)scale;
{
    _scale = scale;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (void)setSelectedXPosition:(CGFloat)selectedXPosition;
{
    _selectedXPosition = selectedXPosition;
    [self setNeedsDisplay:YES];
}

- (void)setSelectedRange:(NSRange)selectedRange;
{
    _selectedRange = selectedRange;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)eventListDidGenerateOutput:(NSNotification *)notification;
{
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
    if (self.eventList == nil || self.displayParameter == nil) {
        return CGSizeMake(800, 100);
    }

    CGSize size = CGSizeMake(0, 100);
    Event *lastEvent = self.eventList.events.lastObject;
    if (lastEvent == nil) {
        return CGSizeMake(800, 100);
    }

    CGFloat leftInset = 5.0;
    CGFloat rightInset = 15.0;

    size.width = leftInset + lastEvent.time * _scale + rightInset;;
    return size;
}

- (void)frameDidChange:(NSNotification *)notification;
{
    //NSLog(@"[%p]  > %s", self, __PRETTY_FUNCTION__);
    //NSLog(@"bounds now: %@", NSStringFromRect(self.bounds));
    [self removeTrackingArea:self.trackingArea];
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseMoved|NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect|NSTrackingMouseEnteredAndExited/*|NSTrackingCursorUpdate*/ owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
    //NSLog(@"[%p] <  %s", self, __PRETTY_FUNCTION__);
}

- (void)drawRect:(NSRect)rect;
{
    NSRect bounds = self.bounds;
    CGFloat topInset = 2.0;
    CGFloat bottomInset = 2.0;
    CGFloat trackHeight = bounds.size.height - topInset - bottomInset;

    //NSLog(@"[%p] bounds: %@", self, NSStringFromRect(bounds));

    if (self.selectedRange.length > 0) {
        [[[NSColor greenColor] colorWithAlphaComponent:0.2] set];
        NSRectFill(NSMakeRect(self.selectedRange.location, 0.5, self.selectedRange.length, NSMaxY(bounds)));
    }

    NSUInteger parameterIndex = self.displayParameter.tag;
    double currentMin = self.displayParameter.parameter.minimumValue;
    double currentMax = self.displayParameter.parameter.maximumValue;

    NSArray *events = self.eventList.events;

    {
        NSBezierPath *posturePath = [[NSBezierPath alloc] init];
        NSBezierPath *valuePath = [[NSBezierPath alloc] init];
        CGFloat dash[] = { 4.0, 8.0, };
        [valuePath setLineDash:dash count:2 phase:0];
        for (Event *event in events) {
            if (event.isAtPosture) {
                CGFloat x = _leftInset + event.time * _scale;
                [posturePath moveToPoint:CGPointMake(x, 0)];
                [posturePath lineToPoint:CGPointMake(x, NSMaxY(bounds))];
            } else {
                double value = [event getValueAtIndex:parameterIndex];

                if (!isnan(value)) {
                    CGFloat x = _leftInset + event.time * _scale;
                    [valuePath moveToPoint:CGPointMake(x, 0)];
                    [valuePath lineToPoint:CGPointMake(x, NSMaxY(bounds))];
                }
            }
        }
        [[NSColor lightGrayColor] set];
//        [valuePath stroke];
        [posturePath stroke];
    }

    {
        NSBezierPath *valuePath = [[NSBezierPath alloc] init];
        for (Event *event in events) {
            double value = [event getValueAtIndex:parameterIndex];

            if (!isnan(value)) {
                CGPoint p1;
                p1.x = _leftInset + event.time * _scale;
                p1.y = rint(bottomInset + trackHeight * (value - currentMin) / (currentMax - currentMin));
                [valuePath moveToPoint:p1];
                [valuePath appendBezierPathWithArcWithCenter:p1 radius:2 startAngle:0 endAngle:360];
            }
        }
        [[NSColor blackColor] set];
        [valuePath fill];
    }

    {
        NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
        BOOL isFirstPoint = YES;

        for (Event *event in events) {
            double value = [event getValueAtIndex:parameterIndex];

            if (!isnan(value)) {
                CGPoint p1;
                p1.x = _leftInset + event.time * _scale;
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

    if (self.selectedXPosition >= 0) {
        NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
        [bezierPath moveToPoint:CGPointMake(self.selectedXPosition, 0.5)];
        [bezierPath lineToPoint:CGPointMake(self.selectedXPosition, NSMaxY(bounds) - 0.5)];

        [[[NSColor greenColor] colorWithAlphaComponent:0.8] set];
        [bezierPath stroke];
    }

    {
        // Draw this last, so that vertical lines don't overlap.
        NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
        [bezierPath moveToPoint:CGPointMake(0,                    0.5)];
        [bezierPath lineToPoint:CGPointMake(NSMaxX(bounds) - 0.5, 0.5)];
        [bezierPath lineToPoint:CGPointMake(NSMaxX(bounds) - 0.5, NSMaxY(bounds) - 0.5)];
        [bezierPath lineToPoint:CGPointMake(0,                    NSMaxY(bounds) - 0.5)];

        [[NSColor blackColor] set];
        [bezierPath stroke];
    }
}

#pragma mark -

- (void)mouseDown:(NSEvent *)event;
{
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    BOOL shiftClicked = (([event modifierFlags] & NSShiftKeyMask) != 0);

    if (!shiftClicked) {
        self.selectedXPosition = point.x;

        [self.delegate graphView:self didSelectXPosition:self.selectedXPosition];
    }
    [self updateTrackingAtPoint:point];


    if (event.clickCount == 1 && shiftClicked) {
        self.selectedRange = NSMakeRange(point.x, 0);
        [self.delegate graphView:self didSelectRange:self.selectedRange];

        while (1) {
            NSEvent *event = [NSApp nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask
                                                untilDate:[NSDate distantFuture]
                                                   inMode:NSEventTrackingRunLoopMode
                                                  dequeue:NO];
            if ([event type] == NSLeftMouseUp)
                break;

            NSPoint hitPoint = [self convertPoint:[event locationInWindow] fromView:nil];
            [self updateTrackingAtPoint:hitPoint];
            if (hitPoint.x < point.x) {
                self.selectedRange = NSMakeRange(hitPoint.x, point.x - hitPoint.x);
            } else {
                self.selectedRange = NSMakeRange(point.x, hitPoint.x - point.x);
            }
            [self.delegate graphView:self didSelectRange:self.selectedRange];

            // Dequeue the event after checking, so that the event which triggered the exit remains availble
            [NSApp nextEventMatchingMask:NSLeftMouseDraggedMask
                               untilDate:[NSDate distantFuture]
                                  inMode:NSEventTrackingRunLoopMode
                                 dequeue:YES];
        }
    }
}

- (void)mouseDragged:(NSEvent *)event;
{
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    self.selectedXPosition = point.x;

    [self.delegate graphView:self didSelectXPosition:self.selectedXPosition];
    [self updateTrackingAtPoint:point];
}

- (void)mouseMoved:(NSEvent *)event;
{
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    //NSLog(@"%s, point: %@", __PRETTY_FUNCTION__, NSStringFromPoint(point));

    [self updateTrackingAtPoint:point];
}

/// Point is in local coordinates already.
- (void)updateTrackingAtPoint:(NSPoint)point;
{
    NSNumber *timeNumber, *valueNumber;

    double time = (point.x - _leftInset) / _scale;

    if ((point.x >= _leftInset) && (point.x <= self.bounds.size.width)) {
        timeNumber = @(time);
    }

    //NSLog(@"tag: %ld", self.displayParameter.tag);

    double value = [self.eventList valueAtTimeOffset:time forEvent:self.displayParameter.tag];
    if (!isnan(value)) {
        valueNumber = @(value);
    }

    [self.delegate graphView:self trackingTime:timeNumber value:valueNumber];
}

- (void)mouseExited:(NSEvent *)theEvent;
{
    [self.delegate graphView:self trackingTime:nil value:nil];
}

- (void)cursorUpdate:(NSEvent *)event;
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    //[[NSCursor crosshairCursor] set];
}

@end
