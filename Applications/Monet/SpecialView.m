#import "SpecialView.h"

#import <AppKit/AppKit.h>
#include <math.h>

#import "AppController.h"
#import "FormulaExpression.h"
#import "Inspector.h"
#import "MonetList.h"
#import "NamedList.h"
#import "MMPosture.h"
#import "MMPoint.h"
#import "PointInspector.h"
#import "MMEquation.h"
#import "PrototypeManager.h"
#import "MMTransition.h"
#import "SymbolList.h"
#import "MMTarget.h"
#import "TargetList.h"

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

static NSImage *_dotMarker = nil;
static NSImage *_squareMarker = nil;
static NSImage *_triangleMarker = nil;
static NSImage *_selectionBox = nil;

+ (void)initialize;
{
    NSBundle *mainBundle;
    NSString *path;

    mainBundle = [NSBundle mainBundle];
    path = [mainBundle pathForResource:@"dotMarker" ofType:@"tiff"];
    NSLog(@"path: %@", path);
    _dotMarker = [[NSImage alloc] initWithContentsOfFile:path];

    path = [mainBundle pathForResource:@"squareMarker" ofType:@"tiff"];
    NSLog(@"path: %@", path);
    _squareMarker = [[NSImage alloc] initWithContentsOfFile:path];

    path = [mainBundle pathForResource:@"triangleMarker" ofType:@"tiff"];
    NSLog(@"path: %@", path);
    _triangleMarker = [[NSImage alloc] initWithContentsOfFile:path];

    path = [mainBundle pathForResource:@"selectionBox" ofType:@"tiff"];
    NSLog(@"path: %@", path);
    _selectionBox = [[NSImage alloc] initWithContentsOfFile:path];
}

// The size was originally 700 x 380
- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    cache = 100000;
    [self allocateGState];

    timesFont = [[NSFont fontWithName:@"Times-Roman" size:12] retain];
    currentTemplate = nil;

    samplePhoneList = [[MonetList alloc] initWithCapacity:4];
    displayPoints = [[MonetList alloc] initWithCapacity:12];
    selectedPoint = nil;

    shouldDrawSelection = NO;

    [self setNeedsDisplay:YES];

    return self;
}

- (void)dealloc;
{
    [timesFont release];
    [samplePhoneList release];
    [displayPoints release];
    [selectedPoint release];

    [super dealloc];
}

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == model)
        return;

    [model release];
    model = [newModel retain];

    [self _updateFromModel];
}

// TODO (2004-03-21): I don't think this will catch changes to the "Formula Symbols"...
- (void)_updateFromModel;
{
    MMPosture *aPosture;

    NSLog(@" > %s", _cmd);

    [samplePhoneList removeAllObjects];
    [displayPoints removeAllObjects];
    [selectedPoint release];
    selectedPoint = nil;

    aPosture = [[MMPosture alloc] initWithModel:model];
    [aPosture setSymbol:@"dummy"];
    [(MMTarget *)[[aPosture symbolList] objectAtIndex:0] setValue:100.0]; // Rule Duration (should be "duration"?)
    [(MMTarget *)[[aPosture symbolList] objectAtIndex:1] setValue:33.3333]; // Beat Location? (should be "transition"?)
    [(MMTarget *)[[aPosture symbolList] objectAtIndex:2] setValue:33.3333]; // Mark 1 (should be "qssa"?)
    [(MMTarget *)[[aPosture symbolList] objectAtIndex:3] setValue:33.3333]; // Mark 2 (should be "qssb"?)

    // We need four postures to show a tetraphone
    [samplePhoneList addObject:aPosture];
    [samplePhoneList addObject:aPosture];
    [samplePhoneList addObject:aPosture];
    [samplePhoneList addObject:aPosture];

    [aPosture release];

    [self setNeedsDisplay:YES];

    NSLog(@"<  %s", _cmd);
}

- (double)ruleDuration;
{
    return _parameters[0];
}

- (void)setRuleDuration:(double)newValue;
{
    _parameters[0] = newValue;
    [self setNeedsDisplay:YES];
}

- (double)beatLocation;
{
    return _parameters[1];
}

- (void)setBeatLocation:(double)newValue;
{
    _parameters[1] = newValue;
    [self setNeedsDisplay:YES];
}

- (double)mark1;
{
    return _parameters[2];
}

- (void)setMark1:(double)newValue;
{
    _parameters[2] = newValue;
    [self setNeedsDisplay:YES];
}

- (double)mark2;
{
    return _parameters[3];
}

- (void)setMark2:(double)newValue;
{
    _parameters[3] = newValue;
    [self setNeedsDisplay:YES];
}

- (double)mark3;
{
    return _parameters[4];
}

- (void)setMark3:(double)newValue;
{
    _parameters[4] = newValue;
    [self setNeedsDisplay:YES];
}

- (IBAction)takeRuleDurationFrom:(id)sender;
{
    [self setRuleDuration:[sender doubleValue]];
}

- (IBAction)takeBeatLocationFrom:(id)sender;
{
    [self setBeatLocation:[sender doubleValue]];
}

- (IBAction)takeMark1From:(id)sender;
{
    [self setMark1:[sender doubleValue]];
}

- (IBAction)takeMark2From:(id)sender;
{
    [self setMark2:[sender doubleValue]];
}

- (IBAction)takeMark3From:(id)sender;
{
    [self setMark3:[sender doubleValue]];
}

- (BOOL)shouldDrawSelection;
{
    return shouldDrawSelection;
}

- (void)setShouldDrawSelection:(BOOL)newFlag;
{
    if (newFlag == shouldDrawSelection)
        return;

    shouldDrawSelection = newFlag;
    [self setNeedsDisplay:YES];
}

//
// Drawing
//

- (void)drawRect:(NSRect)rect;
{
    NSLog(@" > %s", _cmd);

    [self clearView];
    [self drawGrid];
    [self drawEquations];
    [self drawPhones];
    [self drawTransition];

    if (shouldDrawSelection == YES) {
        NSRect selectionRect;

        selectionRect = [self rectFormedByPoint:selectionPoint1 andPoint:selectionPoint2];
        selectionRect.origin.x += 0.5;
        selectionRect.origin.y += 0.5;

        [[NSColor purpleColor] set];
        [NSBezierPath strokeRect:selectionRect];
    }

    NSLog(@"<  %s", _cmd);
}

- (void)clearView;
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
}

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

// These are the proto equations
- (void)drawEquations;
{
    int i, j;
    double time;
    MonetList *equationList = [NXGetNamedObject(@"prototypeManager", NSApp) equationList];
    NamedList *namedList;
    MMEquation *equation;
    float timeScale = [self timeScale];
    int type;
    NSBezierPath *bezierPath;
    NSPoint graphOrigin;

    graphOrigin = [self graphOrigin];

    cache++;

    if (currentTemplate)
        type = [currentTemplate type];
    else
        type = DIPHONE;

    [[NSColor darkGrayColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    for (i = 0; i < [equationList count]; i++) {
        namedList = [equationList objectAtIndex:i];
        //NSLog(@"named list: %@, count: %d", [namedList name], [namedList count]);
        for (j = 0; j < [namedList count]; j++) {
            equation = [namedList objectAtIndex:j];
            if ([[equation expression] maxPhone] <= type) {
                time = [equation evaluate:_parameters phones:samplePhoneList andCacheWith:cache];
                //NSLog(@"\t%@", [equation name]);
                //NSLog(@"\t\ttime = %f", time);
                //NSLog(@"equation name: %@, formula: %@, time: %f", [equation name], [[equation expression] expressionString], time);
                // TODO (2004-03-11): Need to check with users to see if floor()'ing the x is okay.
                [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + 0.5 + floor(timeScale * (float)time), graphOrigin.y - 1)];
                [bezierPath lineToPoint:NSMakePoint(graphOrigin.x + 0.5 + floor(timeScale * (float)time), graphOrigin.y - 10)];
            }
        }
    }

    [bezierPath stroke];
    [bezierPath release];
}

- (void)drawPhones;
{
    NSPoint myPoint;
    float timeScale;
    float currentTimePoint;
    int type;
    NSBezierPath *bezierPath;
    NSRect bounds;
    NSPoint graphOrigin;
    float graphTopYPos;

    bounds = NSIntegralRect([self bounds]);
    graphOrigin = [self graphOrigin];

    if (currentTemplate)
        type = [currentTemplate type];
    else
        type = DIPHONE;

    [[NSColor blackColor] set];
    //[[NSColor redColor] set];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];

    timeScale = [self timeScale];
    graphTopYPos = bounds.size.height - BOTTOM_MARGIN - 1;
    myPoint.y = bounds.size.height - BOTTOM_MARGIN + 6;

    switch (type) {
      case TETRAPHONE:
          currentTimePoint = (timeScale * [self mark3]);
          [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphOrigin.y + 1)];
          [bezierPath lineToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphTopYPos)];
          myPoint.x = currentTimePoint + LEFT_MARGIN;
          [self drawSquareMarkerAtPoint:myPoint];
          // And draw the other two:

      case TRIPHONE:
          currentTimePoint = (timeScale * [self mark2]);
          [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphOrigin.y + 1)];
          [bezierPath lineToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphTopYPos)];
          myPoint.x = currentTimePoint + LEFT_MARGIN;
          [self drawTriangleMarkerAtPoint:myPoint];
          // And draw the other one:

      case DIPHONE:
          currentTimePoint = (timeScale * [self mark1]);
          [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphOrigin.y + 1)];
          [bezierPath lineToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphTopYPos)];
          myPoint.x = currentTimePoint + LEFT_MARGIN;
          [self drawCircleMarkerAtPoint:myPoint];
    }

    [bezierPath stroke];
    [bezierPath release];
}

- (void)drawTransition;
{
    int count, index;
    int j;
    MonetList *currentPoints;
    MMPoint *currentPoint;
    //double tempos[4] = {1.0, 1.0, 1.0, 1.0};
    NSPoint myPoint;
    float timeScale, y;
    int yScale;
    float time, eventTime;
    //MMPoint *tempPoint;
    NSBezierPath *bezierPath;
    NSPoint graphOrigin;
    NSMutableArray *diphonePoints, *triphonePoints, *tetraphonePoints;

    if (currentTemplate == nil)
        return;

    [[NSColor blackColor] set];

    graphOrigin = [self graphOrigin];

    [displayPoints removeAllObjects];

    timeScale = [self timeScale];
    yScale = [self sectionHeight];

    cache++;

    currentPoints = [currentTemplate points];
    count = [currentPoints count];
    for (index = 0; index < count; index++) {
        currentPoint = [currentPoints objectAtIndex:index];
        //NSLog(@"%2d: object class: %@", index, NSStringFromClass([currentPoint class]));
        //NSLog(@"%2d (a): value: %g, freeTime: %g, type: %d, isPhantom: %d", index, [currentPoint value], [currentPoint freeTime], [currentPoint type], [currentPoint isPhantom]);
        if ([currentPoint expression] == nil)
            time = (float)[currentPoint freeTime];
        else
            time = (float)[[currentPoint expression] evaluate:_parameters phones:samplePhoneList andCacheWith:cache];
        //NSLog(@"%2d (b): value: %g, freeTime: %g, type: %d, isPhantom: %d", index, [currentPoint value], [currentPoint freeTime], [currentPoint type], [currentPoint isPhantom]);

        if (index == 0)
            [displayPoints addObject:currentPoint];
        else {
            j = [displayPoints count] - 1;
            while (j > 0) {
                if ([(MMPoint *)[displayPoints objectAtIndex:j] expression] == nil)
                    eventTime = (float)[[displayPoints objectAtIndex:j] freeTime];
                else
                    eventTime = (float)[[(MMPoint *)[displayPoints objectAtIndex:j] expression] cacheValue];

                if (time > eventTime)
                    break;
                j--;
            }
            [displayPoints insertObject:currentPoint atIndex:j+1];
        }
    }

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
        NSLog(@"%d: y = %f", index, y);
        if ([currentPoint expression] == nil)
            eventTime = [currentPoint freeTime];
        else
            eventTime = [[currentPoint expression] evaluate:_parameters phones:samplePhoneList andCacheWith:cache];
        myPoint.x = graphOrigin.x + timeScale * eventTime;
        myPoint.y = graphOrigin.y + (yScale * ZERO_INDEX) + (y * (float)yScale / SECTION_AMOUNT);
        [bezierPath lineToPoint:myPoint];
        switch ([currentPoint type]) {
          case TETRAPHONE:
              [tetraphonePoints addObject:[NSValue valueWithPoint:myPoint]];
              break;
          case TRIPHONE:
              [triphonePoints addObject:[NSValue valueWithPoint:myPoint]];
              break;
          case DIPHONE:
              [diphonePoints addObject:[NSValue valueWithPoint:myPoint]];
              break;
        }

        if (index != [displayPoints count] - 1) {
            if ([currentPoint type] == [(MMPoint *)[displayPoints objectAtIndex:index+1] type])
                [bezierPath moveToPoint:myPoint];
            else
                [bezierPath moveToPoint:NSMakePoint(myPoint.x, graphOrigin.y + (ZERO_INDEX * yScale))];
        }
        else
            [bezierPath moveToPoint:NSMakePoint(myPoint.x, myPoint.y)];
    }

    [bezierPath lineToPoint:NSMakePoint([self bounds].size.width - LEFT_MARGIN, [self bounds].size.height - BOTTOM_MARGIN - (ZERO_INDEX * yScale))];
    [bezierPath stroke];
    [bezierPath release];

    //[[NSColor redColor] set];
    count = [diphonePoints count];
    for (index = 0; index < count; index++) {
        NSPoint aPoint;

        aPoint = [[diphonePoints objectAtIndex:index] pointValue];
        [self drawCircleMarkerAtPoint:aPoint];
    }

    count = [triphonePoints count];
    for (index = 0; index < count; index++) {
        NSPoint aPoint;

        aPoint = [[triphonePoints objectAtIndex:index] pointValue];
        [self drawTriangleMarkerAtPoint:aPoint];
    }

    count = [tetraphonePoints count];
    for (index = 0; index < count; index++) {
        NSPoint aPoint;

        aPoint = [[tetraphonePoints objectAtIndex:index] pointValue];
        [self drawSquareMarkerAtPoint:aPoint];
    }

    [diphonePoints release];
    [triphonePoints release];
    [tetraphonePoints release];

    if (selectedPoint) {
        float y;
        NSPoint myPoint;

        y = (float)[(MMPoint *)selectedPoint value];
        if ([selectedPoint expression] == nil)
            eventTime = [selectedPoint freeTime];
        else
            eventTime = [[selectedPoint expression] evaluate:_parameters phones:samplePhoneList andCacheWith:cache];

        myPoint.x = graphOrigin.x + timeScale * eventTime;
        myPoint.y = graphOrigin.y + (yScale * ZERO_INDEX) + (y * (float)yScale / SECTION_AMOUNT);

        //NSLog(@"Selection; x: %f y:%f", myPoint.x, myPoint.y);

        [self highlightMarkerAtPoint:myPoint];
    }
}

- (void)drawCircleMarkerAtPoint:(NSPoint)aPoint;
{
    int radius = 3;
    NSBezierPath *bezierPath;

    //NSLog(@"->%s, point: %@", _cmd, NSStringFromPoint(aPoint));
    aPoint.x = rint(aPoint.x);
    aPoint.y = rint(aPoint.y);
    //NSLog(@"-->%s, point: %@", _cmd, NSStringFromPoint(aPoint));

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath appendBezierPathWithArcWithCenter:aPoint radius:radius startAngle:0 endAngle:360];
    [bezierPath closePath];
    [bezierPath fill];
    //[bezierPath stroke];
    [bezierPath release];
}

- (void)drawTriangleMarkerAtPoint:(NSPoint)aPoint;
{
    int radius = 5;
    NSBezierPath *bezierPath;
    float angle;

    //NSLog(@"->%s, point: %@", _cmd, NSStringFromPoint(aPoint));
    aPoint.x = rint(aPoint.x);
    aPoint.y = rint(aPoint.y);
    //NSLog(@"-->%s, point: %@", _cmd, NSStringFromPoint(aPoint));

    bezierPath = [[NSBezierPath alloc] init];
    //[bezierPath moveToPoint:NSMakePoint(aPoint.x, aPoint.y + radius)];
    angle = 90.0 * (2 * M_PI) / 360.0;
    //NSLog(@"angle: %f, cos(angle): %f, sin(angle): %f", angle, cos(angle), sin(angle));
    [bezierPath moveToPoint:NSMakePoint(aPoint.x + cos(angle) * radius, aPoint.y + sin(angle) * radius)];
    angle = 210.0 * (2 * M_PI) / 360.0;
    //NSLog(@"angle: %f, cos(angle): %f, sin(angle): %f", angle, cos(angle), sin(angle));
    [bezierPath lineToPoint:NSMakePoint(aPoint.x + cos(angle) * radius, aPoint.y + sin(angle) * radius)];
    angle = 330.0 * (2 * M_PI) / 360.0;
    //NSLog(@"angle: %f, cos(angle): %f, sin(angle): %f", angle, cos(angle), sin(angle));
    [bezierPath lineToPoint:NSMakePoint(aPoint.x + cos(angle) * radius, aPoint.y + sin(angle) * radius)];
    [bezierPath closePath];
    [bezierPath fill];
    //[bezierPath stroke];
    [bezierPath release];
}

- (void)drawSquareMarkerAtPoint:(NSPoint)aPoint;
{
    NSRect rect;

    //NSLog(@"->%s, point: %@", _cmd, NSStringFromPoint(aPoint));
    aPoint.x = rint(aPoint.x);
    aPoint.y = rint(aPoint.y);
    //NSLog(@"-->%s, point: %@", _cmd, NSStringFromPoint(aPoint));

    rect = NSIntegralRect(NSMakeRect(aPoint.x - 3, aPoint.y - 3, 1, 1));
    rect.size = NSMakeSize(6, 6);
    //NSLog(@"%s, rect: %@", _cmd, NSStringFromRect(rect));
    [NSBezierPath fillRect:rect];
    //[NSBezierPath strokeRect:rect];
    //NSRectFill(rect);
    //NSFrameRect(rect);
}

- (void)highlightMarkerAtPoint:(NSPoint)aPoint;
{
    NSRect rect;

    //NSLog(@"->%s, point: %@", _cmd, NSStringFromPoint(aPoint));
    aPoint.x = rint(aPoint.x);
    aPoint.y = rint(aPoint.y);
    //NSLog(@"-->%s, point: %@", _cmd, NSStringFromPoint(aPoint));


    rect = NSIntegralRect(NSMakeRect(aPoint.x - 5, aPoint.y - 5, 10, 10));
    //NSLog(@"%s, rect: %@", _cmd, NSStringFromRect(rect));
    NSFrameRect(rect);
}

//
// Event handling
//

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
{
    return YES;
}

- (void)mouseDown:(NSEvent *)mouseEvent;
{
    NSPoint hitPoint;

    NSLog(@" > %s", _cmd);

    hitPoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
    NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));

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
            if ([currentTemplate insertPoint:newPoint]) {
                [selectedPoint release];
                selectedPoint = [newPoint retain];
            }

            [newPoint release];

            [[controller inspector] inspectPoint:selectedPoint];
            [self setNeedsDisplay:YES];
            return;
        }
    }


    selectionPoint1 = hitPoint;
    selectionPoint2 = hitPoint; // TODO (2004-03-11): Should only do this one they start dragging
    [self setShouldDrawSelection:YES];

    NSLog(@"<  %s", _cmd);
}

- (void)mouseDragged:(NSEvent *)mouseEvent;
{
    NSPoint hitPoint;

    //NSLog(@" > %s", _cmd);

    if (shouldDrawSelection == YES) {
        hitPoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
        //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));
        selectionPoint2 = hitPoint;
        [self setNeedsDisplay:YES];

        [self selectGraphPointsBetweenPoint:selectionPoint1 andPoint:selectionPoint2];
    }

    //NSLog(@"<  %s", _cmd);
}

- (void)mouseUp:(NSEvent *)mouseEvent;
{
    NSLog(@" > %s", _cmd);
    [self setShouldDrawSelection:NO];
    NSLog(@"<  %s", _cmd);
}

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

- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
{
    float minx, miny, maxx, maxy;
    NSRect rect;

    if (point1.x < point2.x) {
        minx = point1.x;
        maxx = point2.x;
    } else {
        minx = point2.x;
        maxx = point1.x;
    }

    if (point1.y < point2.y) {
        miny = point1.y;
        maxy = point2.y;
    } else {
        miny = point2.y;
        maxy = point1.y;
    }

    rect.origin.x = minx;
    rect.origin.y = miny;
    rect.size.width = maxx - minx;
    rect.size.height = maxy - miny;

    return rect;
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

    [selectedPoint release];
    selectedPoint = nil;

    cache++;
    graphOrigin = [self graphOrigin];
    timeScale = [self timeScale];
    yScale = [self sectionHeight];

    selectionRect = [self rectFormedByPoint:point1 andPoint:point2];
    selectionRect.origin.x -= graphOrigin.x;
    selectionRect.origin.y -= graphOrigin.y;

    NSLog(@"%s, selectionRect: %@", _cmd, NSStringFromRect(selectionRect));

    count = [displayPoints count];
    NSLog(@"%d display points", count);
    for (index = 0; index < count; index++) {
        MMPoint *currentDisplayPoint;
        MMEquation *currentExpression;
        NSPoint currentPoint;

        currentDisplayPoint = [displayPoints objectAtIndex:index];
        currentExpression = [currentDisplayPoint expression];
        if (currentExpression == nil)
            currentPoint.x = [currentDisplayPoint freeTime];
        else
            currentPoint.x = [[currentDisplayPoint expression] evaluate:_parameters phones:samplePhoneList andCacheWith:cache];

        currentPoint.x *= timeScale;
        currentPoint.y = (yScale * ZERO_INDEX) + ([currentDisplayPoint value] * yScale / SECTION_AMOUNT);

        //NSLog(@"%2d: currentPoint: %@", index, NSStringFromPoint(currentPoint));
        if (NSPointInRect(currentPoint, selectionRect) == YES) {
            [selectedPoint release];
            selectedPoint = [currentDisplayPoint retain];
        }
    }

    [[controller inspector] inspectPoint:selectedPoint];
    [self setNeedsDisplay:YES];
}

//
// Actions
//

- (IBAction)delete:(id)sender;
{
    if ((currentTemplate == nil) || (selectedPoint == nil)) {
        NSBeep();
        return;
    }

    if ([[currentTemplate points] indexOfObject:selectedPoint] == 0) {
        NSBeep();
        return;
    }

    [[currentTemplate points] removeObject:selectedPoint];
    [selectedPoint release];
    selectedPoint = nil;
    [[controller inspector] cleanInspectorWindow];

    [self setNeedsDisplay:YES];
}

//
// Publicly used API
//

- (void)setTransition:(MMTransition *)newTransition;
{
    if (newTransition == currentTemplate)
        return;

    [[self window] endEditingFor:nil];
    [selectedPoint release];
    selectedPoint = nil;

    [currentTemplate release];
    currentTemplate = [newTransition retain];

    switch ([currentTemplate type]) {
      case DIPHONE:
          [self setRuleDuration:100];
          [self setBeatLocation:33];
          [self setMark1:100];
          [self setMark2:0];
          [self setMark3:0];
          break;
      case TRIPHONE:
          [self setRuleDuration:200];
          [self setBeatLocation:33];
          [self setMark1:100];
          [self setMark2:200];
          [self setMark3:0];
          break;
      case TETRAPHONE:
          [self setRuleDuration:300];
          [self setBeatLocation:33];
          [self setMark1:100];
          [self setMark2:200];
          [self setMark3:300];
          break;
    }

    [self setNeedsDisplay:YES];
}

- (void)showWindow:(int)otherWindow;
{
    [[self window] orderWindow:NSWindowBelow relativeTo:otherWindow];
}

@end
