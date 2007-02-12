#import "SpecialView.h"

#import <AppKit/AppKit.h>
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

// The size was originally 700 x 380
- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    //[self setShouldDrawSlopes:NO];
    [self setZeroIndex:7];
    [self setSectionAmount:20];

    return self;
}

- (void)dealloc;
{
    [super dealloc];
}

//
// Drawing
//

- (void)drawGrid;
{
    int i;
    int sectionHeight;
    NSBezierPath *bezierPath;
    NSRect bounds, rect;
    NSPoint graphOrigin; // But not the zero point on the graph.

    bounds = NSIntegralRect([self bounds]);

    sectionHeight = [self sectionHeight];
    graphOrigin = [self graphOrigin];

    [[NSColor lightGrayColor] set];
    rect = NSMakeRect(graphOrigin.x + 1.0, graphOrigin.y + 1.0, bounds.size.width - 2 * (LEFT_MARGIN + 1), zeroIndex * sectionHeight);
    NSRectFill(rect);

    /* Grayed out (unused) data spaces should be placed here */

    [[NSColor blackColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath appendBezierPathWithRect:NSMakeRect(graphOrigin.x, graphOrigin.y, bounds.size.width - 2 * LEFT_MARGIN, 14 * sectionHeight)];
    [bezierPath stroke];
    [bezierPath release];

    [[NSColor blackColor] set];
    [timesFont set];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];

    for (i = 1; i < 14; i++) {
        NSString *label;
        float currentYPos;
        NSSize labelSize;

        currentYPos = graphOrigin.y + 0.5 + i * sectionHeight;
        [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + 0.5, currentYPos)];
        [bezierPath lineToPoint:NSMakePoint(bounds.size.width - LEFT_MARGIN + 0.5, currentYPos)];

        currentYPos = graphOrigin.y + i * sectionHeight - 5;
        label = [NSString stringWithFormat:@"%4d%%", (i - zeroIndex) * sectionAmount];
        labelSize = [label sizeWithAttributes:nil];
        //NSLog(@"label (%@) size: %@", label, NSStringFromSize(labelSize));
        [label drawAtPoint:NSMakePoint(LEFT_MARGIN - LABEL_MARGIN - labelSize.width, currentYPos) withAttributes:nil];
        // The current max label width is 35, so we'll just shift the label over a little
        [label drawAtPoint:NSMakePoint(bounds.size.width - 10 - labelSize.width, currentYPos) withAttributes:nil];
    }

    [bezierPath stroke];
    [bezierPath release];
}

- (void)updateDisplayPoints;
{
    [super updateDisplayPoints];
    [displayPoints sortUsingSelector:@selector(compareByAscendingCachedTime:)];
}

- (void)highlightSelectedPoints;
{
    if ([selectedPoints count]) {
        unsigned int index;
        float timeScale, y;
        int yScale;
        NSPoint graphOrigin;
        int cacheTag;

        //NSLog(@"Drawing %d selected points", [selectedPoints count]);

        cacheTag = [[self model] nextCacheTag];

        graphOrigin = [self graphOrigin];
        timeScale = [self timeScale];
        yScale = [self sectionHeight];

        for (index = 0; index < [selectedPoints count]; index++) {
            MMPoint *currentPoint;
            float eventTime;
            NSPoint myPoint;

            currentPoint = [selectedPoints objectAtIndex:index];
            y = (float)[currentPoint value];
            if ([currentPoint timeEquation] == nil)
                eventTime = [currentPoint freeTime];
            else
                eventTime = [[currentPoint timeEquation] evaluate:&_parameters postures:samplePostures andCacheWith:cacheTag];

            myPoint.x = graphOrigin.x + timeScale * eventTime;
            myPoint.y = graphOrigin.y + (yScale * zeroIndex) + (y * (float)yScale / sectionAmount);

            //NSLog(@"Selection; x: %f y:%f", myPoint.x, myPoint.y);

            [NSBezierPath highlightMarkerAtPoint:myPoint];
        }
    }
}

//
// Event handling
//

// TODO (2004-03-22): Need methods to convert between view coordinates and (time, value) pairs.
#ifdef PORTING
- (void)mouseDown:(NSEvent *)mouseEvent;
{
    NSPoint hitPoint;

    hitPoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
    //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));

    [self setShouldDrawSelection:NO];
    [selectedPoint release];
    selectedPoint = nil;
    [self setNeedsDisplay:YES];

    if ([mouseEvent clickCount] == 1) {
        //NSLog(@"[mouseEvent modifierFlags]: %x", [mouseEvent modifierFlags]);
        if ([mouseEvent modifierFlags] & NSAlternateKeyMask) {
            MMPoint *newPoint;
            NSPoint graphOrigin = [self graphOrigin];
            int yScale = [self sectionHeight];
            float newValue;

            //NSLog(@"Alt-clicked!");
            newPoint = [[MMPoint alloc] init];
            [newPoint setFreeTime:(hitPoint.x - graphOrigin.x) / [self timeScale]];
            //NSLog(@"hitPoint: %@, graphOrigin: %@, yScale: %d", NSStringFromPoint(hitPoint), NSStringFromPoint(graphOrigin), yScale);
            newValue = (hitPoint.y - graphOrigin.y - (zeroIndex * yScale)) * sectionAmount / yScale;

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

//
// Selection
//

- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
{
    NSPoint graphOrigin;
    NSRect selectionRect;
    int count, index;
    float timeScale;
    int yScale;
    int cacheTag;

    [selectedPoints removeAllObjects];

    cacheTag = [[self model] nextCacheTag];
    graphOrigin = [self graphOrigin];
    timeScale = [self timeScale];
    yScale = [self sectionHeight];

    selectionRect = [self rectFormedByPoint:point1 andPoint:point2];
    selectionRect.origin.x -= graphOrigin.x;
    selectionRect.origin.y -= graphOrigin.y;

    //NSLog(@"%s, selectionRect: %@", _cmd, NSStringFromRect(selectionRect));

    count = [displayPoints count];
    //NSLog(@"%d display points", count);
    for (index = 0; index < count; index++) {
        MMPoint *currentDisplayPoint;
        MMEquation *currentExpression;
        NSPoint currentPoint;

        currentDisplayPoint = [displayPoints objectAtIndex:index];
        currentExpression = [currentDisplayPoint timeEquation];
        if (currentExpression == nil)
            currentPoint.x = [currentDisplayPoint freeTime];
        else
            currentPoint.x = [[currentDisplayPoint timeEquation] evaluate:&_parameters postures:samplePostures andCacheWith:cacheTag];

        currentPoint.x *= timeScale;
        currentPoint.y = (yScale * zeroIndex) + ([currentDisplayPoint value] * yScale / sectionAmount);

        //NSLog(@"%2d: currentPoint: %@", index, NSStringFromPoint(currentPoint));
        if (NSPointInRect(currentPoint, selectionRect) == YES) {
            [selectedPoints addObject:currentDisplayPoint];
        }
    }

    [self _selectionDidChange];
    [self setNeedsDisplay:YES];
}


@end
