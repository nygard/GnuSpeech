#import "SpecialView.h"

#import <AppKit/AppKit.h>
#import "NSBezierPath-Extensions.h"
#include <math.h>

#import "MonetList.h"
#import "NamedList.h"
#import "MMPosture.h"
#import "MMPoint.h"
#import "MMEquation.h"
#import "MMSlopeRatio.h"
#import "MMTransition.h"
#import "MMTarget.h"

#import "MModel.h"

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
    rect = NSMakeRect(graphOrigin.x + 1.0, graphOrigin.y + 1.0, bounds.size.width - 2 * (LEFT_MARGIN + 1), ZERO_INDEX * sectionHeight);
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
        label = [NSString stringWithFormat:@"%4d%%", (i - ZERO_INDEX) * SECTION_AMOUNT];
        labelSize = [label sizeWithAttributes:nil];
        //NSLog(@"label (%@) size: %@", label, NSStringFromSize(labelSize));
        [label drawAtPoint:NSMakePoint(LEFT_MARGIN - LABEL_MARGIN - labelSize.width, currentYPos) withAttributes:nil];
        // The current max label width is 35, so we'll just shift the label over a little
        [label drawAtPoint:NSMakePoint(bounds.size.width - 10 - labelSize.width, currentYPos) withAttributes:nil];
    }

    [bezierPath stroke];
    [bezierPath release];
}

- (void)drawTransition;
{
    int count, index;
    NSArray *currentPoints;
    MMPoint *currentPoint;
    double tempos[4] = {1.0, 1.0, 1.0, 1.0};
    NSPoint myPoint;
    float timeScale, y;
    int yScale;
    float eventTime;
    NSBezierPath *bezierPath;
    NSPoint graphOrigin;
    NSMutableArray *diphonePoints, *triphonePoints, *tetraphonePoints;
    int cacheTag;

    if (transition == nil)
        return;

    [[NSColor blackColor] set];

    graphOrigin = [self graphOrigin];

    [displayPoints removeAllObjects];
    //[displaySlopes removeAllObjects];

    timeScale = [self timeScale];
    yScale = [self sectionHeight];

    cacheTag = [[self model] nextCacheTag];
    //NSLog(@"%s, cacheTag: %d", _cmd, cacheTag);

    currentPoints = [transition points];
    count = [currentPoints count];
    for (index = 0; index < count; index++) {
        currentPoint = [currentPoints objectAtIndex:index];
        //NSLog(@"%2d: object class: %@", index, NSStringFromClass([currentPoint class]));
        //NSLog(@"%2d (a): value: %g, freeTime: %g, type: %d, isPhantom: %d", index, [currentPoint value], [currentPoint freeTime], [currentPoint type], [currentPoint isPhantom]);
        [currentPoint calculatePoints:&_parameters tempos:tempos postures:samplePostures andCacheWith:cacheTag toDisplay:displayPoints];
        //NSLog(@"%2d (b): value: %g, freeTime: %g, type: %d, isPhantom: %d", index, [currentPoint value], [currentPoint freeTime], [currentPoint type], [currentPoint isPhantom]);

        if ([currentPoint isKindOfClass:[MMSlopeRatio class]])
            [(MMSlopeRatio *)currentPoint displaySlopesInList:displaySlopes];
    }

    [displayPoints sortUsingSelector:@selector(compareByAscendingCachedTime:)]; // TODO (2004-08-15): This is one of a very few differences between TransitionView implementation now.

    diphonePoints = [[NSMutableArray alloc] init];
    triphonePoints = [[NSMutableArray alloc] init];
    tetraphonePoints = [[NSMutableArray alloc] init];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath moveToPoint:NSMakePoint(graphOrigin.x, graphOrigin.y + (yScale * ZERO_INDEX))];

    // TODO (2004-03-02): With the bezier path change, we may want to do the compositing after we draw the path.
    count = [displayPoints count];
    //NSLog(@"%d display points", count);
    for (index = 0; index < count; index++) {
        currentPoint = [displayPoints objectAtIndex:index];
        y = [currentPoint value];
        //NSLog(@"%d: [%p] y = %f", index, currentPoint, y);
        if ([currentPoint timeEquation] == nil)
            eventTime = [currentPoint freeTime];
        else
            eventTime = [[currentPoint timeEquation] cacheValue];
        myPoint.x = graphOrigin.x + timeScale * eventTime;
        myPoint.y = graphOrigin.y + (yScale * ZERO_INDEX) + (y * (float)yScale / SECTION_AMOUNT);
        [bezierPath lineToPoint:myPoint];
        switch ([currentPoint type]) {
          case MMPhoneTypeTetraphone:
              [tetraphonePoints addObject:[NSValue valueWithPoint:myPoint]];
              break;
          case MMPhoneTypeTriphone:
              [triphonePoints addObject:[NSValue valueWithPoint:myPoint]];
              break;
          case MMPhoneTypeDiphone:
              [diphonePoints addObject:[NSValue valueWithPoint:myPoint]];
              break;
        }

        if (index != [displayPoints count] - 1) {
            if ([currentPoint type] == [(MMPoint *)[displayPoints objectAtIndex:index+1] type])
                [bezierPath moveToPoint:myPoint];
            else
                [bezierPath moveToPoint:NSMakePoint(myPoint.x, graphOrigin.y + (ZERO_INDEX * yScale))];
        } else
            [bezierPath moveToPoint:myPoint];
    }

    [bezierPath lineToPoint:NSMakePoint([self bounds].size.width - LEFT_MARGIN, [self bounds].size.height - BOTTOM_MARGIN - (ZERO_INDEX * yScale))];
    [bezierPath stroke];
    [bezierPath release];

    //[[NSColor redColor] set];
    count = [diphonePoints count];
    for (index = 0; index < count; index++) {
        NSPoint aPoint;

        aPoint = [[diphonePoints objectAtIndex:index] pointValue];
        [NSBezierPath drawCircleMarkerAtPoint:aPoint];
    }

    count = [triphonePoints count];
    for (index = 0; index < count; index++) {
        NSPoint aPoint;

        aPoint = [[triphonePoints objectAtIndex:index] pointValue];
        [NSBezierPath drawTriangleMarkerAtPoint:aPoint];
    }

    count = [tetraphonePoints count];
    for (index = 0; index < count; index++) {
        NSPoint aPoint;

        aPoint = [[tetraphonePoints objectAtIndex:index] pointValue];
        [NSBezierPath drawSquareMarkerAtPoint:aPoint];
    }

    [diphonePoints release];
    [triphonePoints release];
    [tetraphonePoints release];
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
            myPoint.y = graphOrigin.y + (yScale * ZERO_INDEX) + (y * (float)yScale / SECTION_AMOUNT);

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
            newValue = (hitPoint.y - graphOrigin.y - (ZERO_INDEX * yScale)) * SECTION_AMOUNT / yScale;

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
// View geometry
//

- (int)sectionHeight;
{
    NSRect bounds;
    int sectionHeight;

    bounds = [self bounds];
    sectionHeight = (bounds.size.height - 2 * BOTTOM_MARGIN) / SECTION_COUNT;

    return sectionHeight;
}

- (NSPoint)graphOrigin;
{
    NSPoint graphOrigin;

    graphOrigin.x = LEFT_MARGIN;
    graphOrigin.y = [self bounds].size.height - BOTTOM_MARGIN - 14 * [self sectionHeight];

    return graphOrigin;
}

- (float)timeScale;
{
    // TODO (2004-03-11): Remove outlets to form, turn these values into ivars.
    return ([self bounds].size.width - 2 * LEFT_MARGIN) / [self ruleDuration];
}

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
        currentPoint.y = (yScale * ZERO_INDEX) + ([currentDisplayPoint value] * yScale / SECTION_AMOUNT);

        //NSLog(@"%2d: currentPoint: %@", index, NSStringFromPoint(currentPoint));
        if (NSPointInRect(currentPoint, selectionRect) == YES) {
            [selectedPoints addObject:currentDisplayPoint];
        }
    }

    [self _selectionDidChange];
    [self setNeedsDisplay:YES];
}


@end
