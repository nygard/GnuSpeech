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
    //self.layer.backgroundColor = [[NSColor magentaColor] colorWithAlphaComponent:0.2].CGColor;
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    //self.layer.borderWidth = 1;

    _scale = 0.5;
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

- (void)setScale:(CGFloat)scale;
{
    _scale = scale;
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
    CGFloat leftInset = 5.0;
    NSRect bounds = self.bounds;
    CGFloat topInset = 2.0;
    CGFloat bottomInset = 2.0;
    CGFloat trackHeight = bounds.size.height - topInset - bottomInset;


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
                CGFloat x = leftInset + event.time * _scale;
                [posturePath moveToPoint:CGPointMake(x, 0)];
                [posturePath lineToPoint:CGPointMake(x, NSMaxY(bounds))];
            } else {
                double value = [event getValueAtIndex:parameterIndex];

                if (value != NaN) {
                    CGFloat x = leftInset + event.time * _scale;
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

            if (value != NaN) {
                CGPoint p1;
                p1.x = leftInset + event.time * _scale;
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

            if (value != NaN) {
                CGPoint p1;
                p1.x = leftInset + event.time * _scale;
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

    {
        // Draw this last, so that vertical lines don't overlap.
        NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
        [bezierPath moveToPoint:CGPointMake(0,              0.5)];
        [bezierPath lineToPoint:CGPointMake(NSMaxX(bounds), 0.5)];
        [bezierPath moveToPoint:CGPointMake(0,              NSMaxY(bounds) - 0.5)];
        [bezierPath lineToPoint:CGPointMake(NSMaxX(bounds), NSMaxY(bounds) - 0.5)];

        [[NSColor blackColor] set];
        [bezierPath stroke];
    }
}

@end
