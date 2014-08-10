//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "SpecialView.h"

#import <GnuSpeech/GnuSpeech.h>
#include <math.h>

#import "NSBezierPath-Extensions.h"

#define LABEL_MARGIN 5
#define LEFT_MARGIN 50
#define BOTTOM_MARGIN 50
#define SECTION_COUNT 14

#define ZERO_INDEX 7
#define SECTION_AMOUNT 20

// TODO (2004-03-15): Should have methods to convert between points in the view and graph values.

// Differences from TransitionView:
// - Shows -110% to 110%
//   - zero 7 instead of 2
//   - section amount 20 instead of 10
// - Only allows one point to be selected
// - different method of calculating point times

@implementation SpecialView
{
}

// The size was originally 700 x 380
- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        //[self setShouldDrawSlopes:NO];
        self.zeroIndex = 7;
        self.sectionAmount = 20;
    }

    return self;
}

#pragma mark - Drawing

- (void)drawGrid;
{
    NSRect bounds = NSIntegralRect([self bounds]);

    CGFloat sectionHeight = [self sectionHeight];
    NSPoint graphOrigin = [self graphOrigin]; // But not the zero point on the graph.

    [[NSColor lightGrayColor] set];
    NSRect rect = NSMakeRect(graphOrigin.x + 1.0, graphOrigin.y + 1.0, bounds.size.width - 2 * (LEFT_MARGIN + 1), self.zeroIndex * sectionHeight);
    NSRectFill(rect);

    /* Grayed out (unused) data spaces should be placed here */

    [[NSColor blackColor] set];
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath appendBezierPathWithRect:NSMakeRect(graphOrigin.x, graphOrigin.y, bounds.size.width - 2 * LEFT_MARGIN, 14 * sectionHeight)];
    [bezierPath stroke];

    [[NSColor blackColor] set];
    [self.timesFont set];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];

    for (NSUInteger i = 1; i < 14; i++) {
        NSString *label;
        CGFloat currentYPos;
        NSSize labelSize;

        currentYPos = graphOrigin.y + 0.5 + i * sectionHeight;
        [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + 0.5, currentYPos)];
        [bezierPath lineToPoint:NSMakePoint(bounds.size.width - LEFT_MARGIN + 0.5, currentYPos)];

        currentYPos = graphOrigin.y + i * sectionHeight - 5;
        label = [NSString stringWithFormat:@"%4ld%%", (i - self.zeroIndex) * self.sectionAmount];
        labelSize = [label sizeWithAttributes:nil];
        //NSLog(@"label (%@) size: %@", label, NSStringFromSize(labelSize));
        [label drawAtPoint:NSMakePoint(LEFT_MARGIN - LABEL_MARGIN - labelSize.width, currentYPos) withAttributes:nil];
        // The current max label width is 35, so we'll just shift the label over a little
        [label drawAtPoint:NSMakePoint(bounds.size.width - 10 - labelSize.width, currentYPos) withAttributes:nil];
    }

    [bezierPath stroke];
}

- (void)updateDisplayPoints;
{
    [super updateDisplayPoints];
    [self.displayPoints sortUsingSelector:@selector(compareByAscendingCachedTime:)];
}

- (void)highlightSelectedPoints;
{
    if ([self.selectedPoints count]) {
        //NSLog(@"Drawing %d selected points", [selectedPoints count]);

        NSUInteger cacheTag = [[self model] nextCacheTag];

        NSPoint graphOrigin = [self graphOrigin];
        CGFloat timeScale = [self timeScale];
        CGFloat yScale = [self sectionHeight];

        for (NSUInteger index = 0; index < [self.selectedPoints count]; index++) {
            CGFloat eventTime;

            MMPoint *currentPoint = [self.selectedPoints objectAtIndex:index];
            CGFloat y = (CGFloat)[currentPoint value];
            if ([currentPoint timeEquation] == nil)
                eventTime = [currentPoint freeTime];
            else {
                eventTime = [[currentPoint timeEquation] evaluateWithPhonesInArray:self.samplePhones ruleSymbols:self.parameters andCacheWithTag:cacheTag];
            }

            NSPoint myPoint;
            myPoint.x = graphOrigin.x + timeScale * eventTime;
            myPoint.y = graphOrigin.y + (yScale * self.zeroIndex) + (y * (float)yScale / self.sectionAmount);

            //NSLog(@"Selection; x: %f y:%f", myPoint.x, myPoint.y);

            [NSBezierPath highlightMarkerAtPoint:myPoint];
        }
    }
}

#pragma mark - Event handling

// TODO (2004-03-22): Need methods to convert between view coordinates and (time, value) pairs.
#ifdef PORTING
- (void)mouseDown:(NSEvent *)mouseEvent;
{
    NSPoint hitPoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
    //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));

    [self setShouldDrawSelection:NO];
    [selectedPoint release];
    selectedPoint = nil;
    [self setNeedsDisplay:YES];

    if ([mouseEvent clickCount] == 1) {
        //NSLog(@"[mouseEvent modifierFlags]: %x", [mouseEvent modifierFlags]);
        if ([mouseEvent modifierFlags] & NSAlternateKeyMask) {
            NSPoint graphOrigin = [self graphOrigin];
            CGFloat yScale = [self sectionHeight];

            //NSLog(@"Alt-clicked!");
            MMPoint *newPoint = [[MMPoint alloc] init];
            [newPoint setFreeTime:(hitPoint.x - graphOrigin.x) / [self timeScale]];
            //NSLog(@"hitPoint: %@, graphOrigin: %@, yScale: %d", NSStringFromPoint(hitPoint), NSStringFromPoint(graphOrigin), yScale);
            CGFloat newValue = (hitPoint.y - graphOrigin.y - (zeroIndex * yScale)) * self.sectionAmount / yScale;

            //NSLog(@"NewPoint Time: %f  value: %f", [tempPoint freeTime], [tempPoint value]);
            [newPoint setValue:newValue];
            if ([transition insertPoint:newPoint]) {
                [selectedPoint release];
                selectedPoint = [newPoint retain];
            }

            [newPoint release];

            [self _selectionDidChange];
            [self setNeedsDisplay:YES];
            return;
        }
    }


    selectionPoint1 = hitPoint;
    selectionPoint2 = hitPoint; // TODO (2004-03-11): Should only do this one they start dragging
    [self setShouldDrawSelection:YES];
}
#endif

#pragma mark - Selection

- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
{
    [self.selectedPoints removeAllObjects];

    NSUInteger cacheTag = [[self model] nextCacheTag];
    NSPoint graphOrigin = [self graphOrigin];
    CGFloat timeScale = [self timeScale];
    CGFloat yScale = [self sectionHeight];

    NSRect selectionRect = [self rectFormedByPoint:point1 andPoint:point2];
    selectionRect.origin.x -= graphOrigin.x;
    selectionRect.origin.y -= graphOrigin.y;

    //NSLog(@"%s, selectionRect: %@", _cmd, NSStringFromRect(selectionRect));

    NSUInteger count = [self.displayPoints count];
    //NSLog(@"%d display points", count);
    for (NSUInteger index = 0; index < count; index++) {
        NSPoint currentPoint;

        MMPoint *currentDisplayPoint = [self.displayPoints objectAtIndex:index];
        MMEquation *currentExpression = [currentDisplayPoint timeEquation];
        if (currentExpression == nil)
            currentPoint.x = [currentDisplayPoint freeTime];
        else {
            currentPoint.x = [[currentDisplayPoint timeEquation] evaluateWithPhonesInArray:nil ruleSymbols:self.parameters andCacheWithTag:cacheTag];
        }

        currentPoint.x *= timeScale;
        currentPoint.y = (yScale * self.zeroIndex) + ([currentDisplayPoint value] * yScale / self.sectionAmount);

        //NSLog(@"%2d: currentPoint: %@", index, NSStringFromPoint(currentPoint));
        if (NSPointInRect(currentPoint, selectionRect) == YES) {
            [self.selectedPoints addObject:currentDisplayPoint];
        }
    }

    [self _selectionDidChange];
    [self setNeedsDisplay:YES];
}


@end
