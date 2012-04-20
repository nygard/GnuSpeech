//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TransitionView.h"

#include <math.h>

#import "NSBezierPath-Extensions.h"

#define LABEL_MARGIN 5
#define LEFT_MARGIN 50
#define BOTTOM_MARGIN 50
#define SECTION_COUNT 14
#define SLOPE_MARKER_HEIGHT 18

#define ZERO_INDEX 2
#define SECTION_AMOUNT 10

NSString *TransitionViewSelectionDidChangeNotification = @"TransitionViewSelectionDidChangeNotification";

// TODO (2004-03-15): Should have methods to convert between points in the view and graph values.

@implementation TransitionView
{
    MMFRuleSymbols _parameters;
    
    NSFont *timesFont;
    
    MMTransition *transition;
    
    NSMutableArray *samplePostures;
    NSMutableArray *displayPoints;
    NSMutableArray *displaySlopes;
    NSMutableArray *selectedPoints;
    
    NSPoint selectionPoint1;
    NSPoint selectionPoint2;
    
    MMSlope *editingSlope;
    NSTextFieldCell *textFieldCell;
    NSText *nonretained_fieldEditor;
    
    NSUInteger zeroIndex;
    NSInteger sectionAmount;
    
    MModel *model;
    
    struct {
        unsigned int shouldDrawSelection:1;
        unsigned int shouldDrawSlopes:1;
    } flags;
    
    id nonretained_delegate;
}

// The size was originally 700 x 380
- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    timesFont = [[NSFont fontWithName:@"Times-Roman" size:12] retain];
    transition = nil;

    samplePostures = [[NSMutableArray alloc] init];
    displayPoints = [[NSMutableArray alloc] init];
    displaySlopes = [[NSMutableArray alloc] init];
    selectedPoints = [[NSMutableArray alloc] init];

    flags.shouldDrawSelection = NO;
    flags.shouldDrawSlopes = YES;

    editingSlope = nil;
    textFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
    nonretained_fieldEditor = nil;

    zeroIndex = 2;
    sectionAmount = 10;

    [self setNeedsDisplay:YES];

    return self;
}

- (void)dealloc;
{
    [timesFont release];
    [transition release];

    [samplePostures release];
    [displayPoints release];
    [displaySlopes release];
    [selectedPoints release];

    [editingSlope release];
    [textFieldCell release];
    [model release];

    [super dealloc];
}

@synthesize timesFont, samplePostures, displayPoints, displaySlopes, selectedPoints;

- (MMFRuleSymbols *)parameters;
{
    return &_parameters;
}

- (NSUInteger)zeroIndex;
{
    return zeroIndex;
}

- (void)setZeroIndex:(NSUInteger)newZeroIndex;
{
    if (newZeroIndex == zeroIndex)
        return;

    zeroIndex = newZeroIndex;
    [self setNeedsDisplay:YES];
}

- (NSInteger)sectionAmount;
{
    return sectionAmount;
}

- (void)setSectionAmount:(NSInteger)newSectionAmount;
{
    if (newSectionAmount == sectionAmount)
        return;

    sectionAmount = newSectionAmount;
    [self setNeedsDisplay:YES];
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

// TODO (2004-03-21): I don't think this will catch changes to the "Formula Symbols"... i.e. adding or removing them.
- (void)_updateFromModel;
{
    MMPosture *aPosture;

    [samplePostures removeAllObjects];
    [displayPoints removeAllObjects];
    [displaySlopes removeAllObjects];
    [selectedPoints removeAllObjects];

    aPosture = [[MMPosture alloc] initWithModel:model];
    [aPosture setName:@"dummy"];
    if ([[aPosture symbolTargets] count] >= 4) {
        [(MMTarget *)[[aPosture symbolTargets] objectAtIndex:0] setValue:100.0]; // duration
        [(MMTarget *)[[aPosture symbolTargets] objectAtIndex:1] setValue:33.3333]; // transition
        [(MMTarget *)[[aPosture symbolTargets] objectAtIndex:2] setValue:33.3333]; // qssa
        [(MMTarget *)[[aPosture symbolTargets] objectAtIndex:3] setValue:33.3333]; // qssb
    }

    // We need four postures to show a tetraphone
    [samplePostures addObject:aPosture];
    [samplePostures addObject:aPosture];
    [samplePostures addObject:aPosture];
    [samplePostures addObject:aPosture];

    [aPosture release];

    [self setNeedsDisplay:YES];
}

- (void)updateTransitionType;
{
    switch ([transition type]) {
      case MMPhoneType_Diphone:
          [self setRuleDuration:100];
          [self setBeatLocation:33];
          [self setMark1:100];
          [self setMark2:0];
          [self setMark3:0];
          break;

      case MMPhoneType_Triphone:
          [self setRuleDuration:200];
          [self setBeatLocation:33];
          [self setMark1:100];
          [self setMark2:200];
          [self setMark3:0];
          break;

      case MMPhoneType_Tetraphone:
          [self setRuleDuration:300];
          [self setBeatLocation:33];
          [self setMark1:100];
          [self setMark2:200];
          [self setMark3:300];
          break;
    }

    [self setNeedsDisplay:YES];
}

- (double)ruleDuration;
{
    return _parameters.ruleDuration;
}

- (void)setRuleDuration:(double)newValue;
{
    _parameters.ruleDuration = newValue;
    [self setNeedsDisplay:YES];
}

- (double)beatLocation;
{
    return _parameters.beat;
}

- (void)setBeatLocation:(double)newValue;
{
    _parameters.beat = newValue;
    [self setNeedsDisplay:YES];
}

- (double)mark1;
{
    return _parameters.mark1;
}

- (void)setMark1:(double)newValue;
{
    _parameters.mark1 = newValue;
    [self setNeedsDisplay:YES];
}

- (double)mark2;
{
    return _parameters.mark2;
}

- (void)setMark2:(double)newValue;
{
    _parameters.mark2 = newValue;
    [self setNeedsDisplay:YES];
}

- (double)mark3;
{
    return _parameters.mark3;
}

- (void)setMark3:(double)newValue;
{
    _parameters.mark3 = newValue;
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
    return flags.shouldDrawSelection;
}

- (void)setShouldDrawSelection:(BOOL)newFlag;
{
    if (newFlag == flags.shouldDrawSelection)
        return;

    flags.shouldDrawSelection = newFlag;
    [self setNeedsDisplay:YES];
}

- (BOOL)shouldDrawSlopes;
{
    return flags.shouldDrawSlopes;
}

- (void)setShouldDrawSlopes:(BOOL)newFlag;
{
    if (newFlag == flags.shouldDrawSlopes)

        return;

    flags.shouldDrawSlopes = newFlag;
    [self setNeedsDisplay:YES];
}

- (id)delegate;
{
    return nonretained_delegate;
}

- (void)setDelegate:(id)newDelegate;
{
    nonretained_delegate = newDelegate;
}

//
// Drawing
//

- (void)drawRect:(NSRect)rect;
{
    //NSLog(@" > %s, cache: %d", _cmd, cache);

    [self clearView];
    [self drawGrid];
    [self drawEquations];
    [self drawPhones];
    [self drawTransition];
    [self highlightSelectedPoints];
    if (flags.shouldDrawSlopes == YES)
        [self drawSlopes];

    if (flags.shouldDrawSelection == YES) {
        NSRect selectionRect;

        selectionRect = [self rectFormedByPoint:selectionPoint1 andPoint:selectionPoint2];
        selectionRect.origin.x += 0.5;
        selectionRect.origin.y += 0.5;

        [[NSColor purpleColor] set];
        [NSBezierPath strokeRect:selectionRect];
    }

    if (nonretained_fieldEditor != nil) {
        NSRect editingRect;

        editingRect = [nonretained_fieldEditor frame];
        editingRect = NSInsetRect(editingRect, -1, -1);
        //[[NSColor redColor] set];
        //NSRectFill(editingRect);
        NSFrameRect(editingRect);
    }

    //NSLog(@"<  %s", _cmd);
}

- (void)clearView;
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
}

- (void)drawGrid;
{
    NSUInteger i;
    CGFloat sectionHeight;
    NSBezierPath *bezierPath;
    NSRect bounds, rect;
    NSPoint graphOrigin; // But not the zero point on the graph.

    bounds = NSIntegralRect([self bounds]);

    sectionHeight = [self sectionHeight];
    graphOrigin = [self graphOrigin];

    [[NSColor lightGrayColor] set];
    rect = NSMakeRect(graphOrigin.x + 1.0, graphOrigin.y + 1.0, bounds.size.width - 2 * (LEFT_MARGIN + 1), zeroIndex * sectionHeight);
    NSRectFill(rect);

    rect = NSMakeRect(graphOrigin.x + 1.0, graphOrigin.y + 1.0 + (10 + zeroIndex) * sectionHeight,
                      bounds.size.width - 2 * (LEFT_MARGIN + 1), 2 * sectionHeight);
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

    for (i = 1; i < SECTION_COUNT; i++) {
        NSString *label;
        CGFloat currentYPos;
        NSSize labelSize;

        currentYPos = graphOrigin.y + 0.5 + i * sectionHeight;
        [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + 0.5, currentYPos)];
        [bezierPath lineToPoint:NSMakePoint(bounds.size.width - LEFT_MARGIN + 0.5, currentYPos)];

        currentYPos = graphOrigin.y + i * sectionHeight - 5;
        label = [NSString stringWithFormat:@"%4lu%%", (i - zeroIndex) * sectionAmount];
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
    NSUInteger i, j;
    double time;
    NSArray *equationList = [model equations];
    NamedList *namedList;
    MMEquation *equation;
    CGFloat timeScale = [self timeScale];
    NSUInteger type;
    NSBezierPath *bezierPath;
    NSPoint graphOrigin;
    NSUInteger cacheTag;

    graphOrigin = [self graphOrigin];

    cacheTag = [[self model] nextCacheTag];
    //NSLog(@"%s, cacheTag: %d", _cmd, cacheTag);

    if (transition)
        type = [transition type];
    else
        type = MMPhoneType_Diphone;

    [[NSColor darkGrayColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    for (i = 0; i < [equationList count]; i++) {
        namedList = [equationList objectAtIndex:i];
        //NSLog(@"named list: %@, count: %d", [namedList name], [namedList count]);
        for (j = 0; j < [namedList count]; j++) {
            equation = [namedList objectAtIndex:j];
            if ([[equation formula] maxPhone] <= type) {
                time = [equation evaluate:&_parameters postures:samplePostures andCacheWith:cacheTag];
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
    CGFloat timeScale;
    CGFloat currentTimePoint;
    NSUInteger type;
    NSBezierPath *bezierPath;
    NSRect bounds;
    NSPoint graphOrigin;
    CGFloat graphTopYPos;

    bounds = NSIntegralRect([self bounds]);
    graphOrigin = [self graphOrigin];

    if (transition)
        type = [transition type];
    else
        type = MMPhoneType_Diphone;

    [[NSColor blackColor] set];
    //[[NSColor redColor] set];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];

    timeScale = [self timeScale];
    graphTopYPos = bounds.size.height - BOTTOM_MARGIN - 1;
    myPoint.y = bounds.size.height - BOTTOM_MARGIN + 6;

    switch (type) {
      case MMPhoneType_Tetraphone:
          currentTimePoint = (timeScale * [self mark3]);
          [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphOrigin.y + 1)];
          [bezierPath lineToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphTopYPos)];
          myPoint.x = currentTimePoint + LEFT_MARGIN;
          [NSBezierPath drawSquareMarkerAtPoint:myPoint];
          // And draw the other two:

      case MMPhoneType_Triphone:
          currentTimePoint = (timeScale * [self mark2]);
          [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphOrigin.y + 1)];
          [bezierPath lineToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphTopYPos)];
          myPoint.x = currentTimePoint + LEFT_MARGIN;
          [NSBezierPath drawTriangleMarkerAtPoint:myPoint];
          // And draw the other one:

      case MMPhoneType_Diphone:
          currentTimePoint = (timeScale * [self mark1]);
          [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphOrigin.y + 1)];
          [bezierPath lineToPoint:NSMakePoint(graphOrigin.x + currentTimePoint, graphTopYPos)];
          myPoint.x = currentTimePoint + LEFT_MARGIN;
          [NSBezierPath drawCircleMarkerAtPoint:myPoint];
    }

    [bezierPath stroke];
    [bezierPath release];
}

- (void)drawTransition;
{
    NSUInteger count, index;
    MMPoint *currentPoint;
    NSPoint myPoint;
    CGFloat timeScale, y;
    CGFloat yScale;
    CGFloat eventTime;
    NSBezierPath *bezierPath;
    NSPoint graphOrigin;
    NSMutableArray *diphonePoints, *triphonePoints, *tetraphonePoints;

    if (transition == nil)
        return;

    [self updateDisplayPoints];

    [[NSColor blackColor] set];

    graphOrigin = [self graphOrigin];

    timeScale = [self timeScale];
    yScale = [self sectionHeight];

    diphonePoints = [[NSMutableArray alloc] init];
    triphonePoints = [[NSMutableArray alloc] init];
    tetraphonePoints = [[NSMutableArray alloc] init];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath moveToPoint:NSMakePoint(graphOrigin.x, graphOrigin.y + (yScale * zeroIndex))];

    // TODO (2004-03-02): With the bezier path change, we may want to do the compositing after we draw the path.
    count = [displayPoints count];
    //NSLog(@"%d display points", count);
    for (index = 0; index < count; index++) {
        currentPoint = [displayPoints objectAtIndex:index];
        y = [currentPoint value];
        //NSLog(@"%d: [%p] y = %f", index, currentPoint, y);
        // TODO (2004-08-15): Move this into MMPoint
        if ([currentPoint timeEquation] == nil)
            eventTime = [currentPoint freeTime];
        else
            eventTime = [[currentPoint timeEquation] cacheValue];
        myPoint.x = graphOrigin.x + timeScale * eventTime;
        myPoint.y = graphOrigin.y + (yScale * zeroIndex) + (y * (float)yScale / sectionAmount);
        [bezierPath lineToPoint:myPoint];
        switch ([currentPoint type]) {
          case MMPhoneType_Tetraphone:
              [tetraphonePoints addObject:[NSValue valueWithPoint:myPoint]];
              break;
          case MMPhoneType_Triphone:
              [triphonePoints addObject:[NSValue valueWithPoint:myPoint]];
              break;
          case MMPhoneType_Diphone:
              [diphonePoints addObject:[NSValue valueWithPoint:myPoint]];
              break;
        }

        if (index != [displayPoints count] - 1) {
            if ([currentPoint type] == [(MMPoint *)[displayPoints objectAtIndex:index+1] type])
                [bezierPath moveToPoint:myPoint];
            else
                [bezierPath moveToPoint:NSMakePoint(myPoint.x, graphOrigin.y + (zeroIndex * yScale))];
        } else
            [bezierPath moveToPoint:myPoint];
    }

    [bezierPath lineToPoint:NSMakePoint([self bounds].size.width - LEFT_MARGIN, [self bounds].size.height - BOTTOM_MARGIN - (zeroIndex * yScale))];
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

//    for (i = 0; i < [displaySlopes count]; i++) {
//        currentSlope = [displaySlopes objectAtIndex:i];
//        slopeRect.origin.x = [currentSlope displayTime]*timeScale+32.0;
//        slopeRect.origin.y = 100.0;
//        slopeRect.size.height = 20.0;
//        slopeRect.size.width = 30.0;
//        NXDrawButton(&slopeRect, &bounds);
//    }
}

- (void)updateDisplayPoints;
{
    NSUInteger count, index;
    NSArray *currentPoints;
    MMPoint *currentPoint;
    double tempos[4] = {1.0, 1.0, 1.0, 1.0};
    NSUInteger cacheTag;

    if (transition == nil)
        return;

    [displayPoints removeAllObjects];
    [displaySlopes removeAllObjects];

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
}

- (void)highlightSelectedPoints;
{
    if ([selectedPoints count]) {
        NSUInteger index;
        CGFloat timeScale, y;
        CGFloat yScale;
        NSPoint graphOrigin;

        //NSLog(@"Drawing %d selected points", [selectedPoints count]);

        graphOrigin = [self graphOrigin];
        timeScale = [self timeScale];
        yScale = [self sectionHeight];

        for (index = 0; index < [selectedPoints count]; index++) {
            MMPoint *currentPoint;
            CGFloat eventTime;
            NSPoint myPoint;

            currentPoint = [selectedPoints objectAtIndex:index];
            y = (float)[currentPoint value];
            if ([currentPoint timeEquation] == nil)
                eventTime = [currentPoint freeTime];
            else
                eventTime = [[currentPoint timeEquation] cacheValue];
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
    MMSlope *hitSlope;
    CGFloat startTime, endTime;

    if ([self isEnabled] == NO) {
        [super mouseDown:mouseEvent];
        return;
    }

    // Force this to be first responder, since nothing else seems to work!
    [[self window] makeFirstResponder:self];

    hitPoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
    //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));

    hitSlope = [self getSlopeMarkerAtPoint:hitPoint startTime:&startTime endTime:&endTime];

    [self setShouldDrawSelection:NO];
    [selectedPoints removeAllObjects];
    [self _selectionDidChange];
    [self setNeedsDisplay:YES];

    if ([mouseEvent clickCount] == 1) {
        if (hitSlope == nil || flags.shouldDrawSlopes == NO)
            [[self window] endEditingFor:nil];
        else {
            [self editSlope:hitSlope startTime:startTime endTime:endTime];
            return;
        }

        //NSLog(@"[mouseEvent modifierFlags]: %x", [mouseEvent modifierFlags]);
        if ([mouseEvent modifierFlags] & NSAlternateKeyMask) {
            MMPoint *newPoint;
            NSPoint graphOrigin = [self graphOrigin];
            CGFloat yScale = [self sectionHeight];
            CGFloat newValue;

            //NSLog(@"Alt-clicked!");
            newPoint = [[MMPoint alloc] init];
            [newPoint setFreeTime:(hitPoint.x - graphOrigin.x) / [self timeScale]];
            //NSLog(@"hitPoint: %@, graphOrigin: %@, yScale: %d", NSStringFromPoint(hitPoint), NSStringFromPoint(graphOrigin), yScale);
            newValue = (hitPoint.y - graphOrigin.y - (zeroIndex * yScale)) * sectionAmount / yScale;

            //NSLog(@"NewPoint Time: %f  value: %f", [tempPoint freeTime], [tempPoint value]);
            [newPoint setValue:newValue];
            if ([[self delegate] respondsToSelector:@selector(transitionView:shouldAddPoint:)] == NO
                || [[self delegate] transitionView:self shouldAddPoint:newPoint] == YES) {
                [transition insertPoint:newPoint];
                [selectedPoints removeAllObjects];
                [selectedPoints addObject:newPoint];
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

- (void)mouseDragged:(NSEvent *)mouseEvent;
{
    NSPoint hitPoint;

    //NSLog(@" > %s", _cmd);

    if ([self isEnabled] == NO)
        return;

    if (flags.shouldDrawSelection == YES) {
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
    [self setShouldDrawSelection:NO];
}

- (void)keyDown:(NSEvent *)keyEvent;
{
    NSArray *keyEvents;

    keyEvents = [[NSArray alloc] initWithObjects:keyEvent, nil];
    [self interpretKeyEvents:keyEvents];
    [keyEvents release];
}

//
// View geometry
//

- (CGFloat)sectionHeight;
{
    NSRect bounds;
    CGFloat sectionHeight;

    bounds = [self bounds];
    sectionHeight = (bounds.size.height - 2 * BOTTOM_MARGIN) / SECTION_COUNT;

    return sectionHeight;
}

- (NSPoint)graphOrigin;
{
    NSPoint graphOrigin;

    graphOrigin.x = LEFT_MARGIN;
    graphOrigin.y = [self bounds].size.height - BOTTOM_MARGIN - SECTION_COUNT * [self sectionHeight];

    return graphOrigin;
}

- (CGFloat)timeScale;
{
    return ([self bounds].size.width - 2 * LEFT_MARGIN) / [self ruleDuration];
}

- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
{
    CGFloat minx, miny, maxx, maxy;
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

- (CGFloat)slopeMarkerYPosition;
{
    NSPoint graphOrigin;

    graphOrigin = [self graphOrigin];

    return graphOrigin.y - BOTTOM_MARGIN + 10;
}

- (NSRect)slopeMarkerRect;
{
    NSRect bounds, rect;
    NSPoint graphOrigin;

    bounds = NSIntegralRect([self bounds]);
    graphOrigin = [self graphOrigin];

    rect.origin.x = graphOrigin.x;
    rect.origin.y = [self slopeMarkerYPosition];
    rect.size.width = bounds.size.width - 2 * LEFT_MARGIN;
    rect.size.height = SLOPE_MARKER_HEIGHT; // Roughly

    return rect;
}

//
// Slopes
//

- (void)drawSlopes;
{
    NSUInteger count, index;
    NSUInteger j;
    double start, end;
    NSRect rect = NSMakeRect(0, 0, 2 * LEFT_MARGIN, SLOPE_MARKER_HEIGHT);
    id currentPoint;
    NSMutableArray *points, *slopes;
    CGFloat timeScale = [self timeScale];
    NSPoint graphOrigin;
    NSRect bounds;
    NSArray *transitionPoints;

    bounds = [self bounds];
    graphOrigin = [self graphOrigin];
    rect.origin.y = [self slopeMarkerYPosition];

    transitionPoints = [transition points];
    count = [transitionPoints count];
    for (index = 0; index < count; index++) {
        currentPoint = [transitionPoints objectAtIndex:index];
        if ([currentPoint isKindOfClass:[MMSlopeRatio class]]) {
            //NSLog(@"%d: Drawing slope ratio...", index);
            start = graphOrigin.x + [currentPoint startTime] * timeScale;
            end = graphOrigin.x + [currentPoint endTime] * timeScale;
            //NSLog(@"Slope  %f -> %f", start, end);
            rect.origin.x = (float)start;
            rect.size.width = (float)(end - start);
            //NSLog(@"drawing button, rect: %@, bounds: %@", NSStringFromRect(rect), NSStringFromRect(bounds));
            NSDrawButton(rect, bounds);

            slopes = [currentPoint slopes];
            points = [currentPoint points];
            for (j = 0; j < [slopes count]; j++) {
                NSString *str;
                //NSPoint aPoint;
                NSRect textFieldFrame;

                str = [NSString stringWithFormat:@"%.1f", [[slopes objectAtIndex:j] slope]];
                //NSLog(@"Buffer = %@", str);

                [[NSColor blackColor] set];
                // TODO (2004-08-15): This is wrong, it can be a free time value.
                //textFieldFrame.origin.x = ([[(MMPoint *)[points objectAtIndex:j] timeEquation] cacheValue]) * timeScale + LEFT_MARGIN + 5.0;
                textFieldFrame.origin.x = ([(MMPoint *)[points objectAtIndex:j] cachedTime]) * timeScale + LEFT_MARGIN + 5.0;
                textFieldFrame.origin.y = rect.origin.y + 2;
                textFieldFrame.size.width = 60;
                textFieldFrame.size.height = SLOPE_MARKER_HEIGHT - 2;
                //NSLog(@"textFieldFrame: %@", NSStringFromRect(textFieldFrame));
                //[str drawAtPoint:aPoint withAttributes:nil];
                [textFieldCell setStringValue:str];
                [textFieldCell setFont:timesFont];
                [textFieldCell drawWithFrame:textFieldFrame inView:self];
            }
        }
    }
}

- (void)_setEditingSlope:(MMSlope *)newSlope;
{
    if (newSlope == editingSlope)
        return;

    [editingSlope release];
    editingSlope = [newSlope retain];
}

- (void)editSlope:(MMSlope *)aSlope startTime:(CGFloat)startTime endTime:(CGFloat)endTime;
{
    NSWindow *window;

    if (aSlope == nil)
        return;

    window = [self window];

    if ([window makeFirstResponder:window] == YES) {
        CGFloat timeScale;
        NSRect rect;

        [self _setEditingSlope:aSlope];
        timeScale = [self timeScale];

        rect.origin.x = LEFT_MARGIN + startTime * timeScale;
        rect.origin.y = [self slopeMarkerYPosition];
        rect.size.width = (endTime - startTime) * timeScale;
        rect.size.height = SLOPE_MARKER_HEIGHT;
        rect = NSIntegralRect(rect);
        nonretained_fieldEditor = [window fieldEditor:YES forObject:self];

        [nonretained_fieldEditor setString:[NSString stringWithFormat:@"%0.1f", [aSlope slope]]];
        [nonretained_fieldEditor setRichText:NO];
        [nonretained_fieldEditor setUsesFontPanel:NO];
        [nonretained_fieldEditor setFont:timesFont];
        [nonretained_fieldEditor setHorizontallyResizable:NO];
        [nonretained_fieldEditor setVerticallyResizable:NO];
        [nonretained_fieldEditor setAutoresizingMask:NSViewWidthSizable];

        [nonretained_fieldEditor setFrame:rect];
        [nonretained_fieldEditor setMinSize:rect.size];
        [nonretained_fieldEditor setMaxSize:rect.size];
        [[(NSTextView *)nonretained_fieldEditor textContainer] setLineFragmentPadding:3];

        [nonretained_fieldEditor setFieldEditor:YES];

        [self setNeedsDisplay:YES];
        [nonretained_fieldEditor setNeedsDisplay:YES];
        [nonretained_fieldEditor setDelegate:self];

        [self addSubview:nonretained_fieldEditor positioned:NSWindowAbove relativeTo:nil];

        [window makeFirstResponder:nonretained_fieldEditor];
        [nonretained_fieldEditor selectAll:nil];
    } else {
        [window endEditingFor:nil];
    }
}

- (MMSlope *)getSlopeMarkerAtPoint:(NSPoint)aPoint startTime:(CGFloat *)startTime endTime:(CGFloat *)endTime;
{
    NSMutableArray *pointList;
    MMSlopeRatio *currentMMSlopeRatio;
    CGFloat timeScale = [self timeScale];
    CGFloat tempTime;
    CGFloat time1, time2;
    NSUInteger i, j;
    NSArray *points;

    NSRect slopeMarkerRect;

    //NSLog(@" > %s", _cmd);
    //NSLog(@"aPoint: %@", NSStringFromPoint(aPoint));

    //if ( (aPoint.y > -21.0) || (aPoint.y < -39.0)) {

    slopeMarkerRect = [self slopeMarkerRect];
    if (NSPointInRect(aPoint, slopeMarkerRect) == NO) {
        //NSLog(@"Y not in range -21 to -39, returning.");
        //NSLog(@"<  %s", _cmd);
        return nil;
    }

    aPoint.x -= LEFT_MARGIN;
    aPoint.y -= BOTTOM_MARGIN;

    tempTime = aPoint.x / timeScale;

    //NSLog(@"ClickSlopeMarker Row: %f  Col: %f  time = %f", aPoint.y, aPoint.x, tempTime);

    points = [transition points];
    for (i = 0; i < [points count]; i++) {
        currentMMSlopeRatio = [points objectAtIndex:i];
        if ([currentMMSlopeRatio isKindOfClass:[MMSlopeRatio class]]) {
            if ((tempTime < [currentMMSlopeRatio endTime]) && (tempTime > [currentMMSlopeRatio startTime])) {
                pointList = [currentMMSlopeRatio points];
                time1 = [[pointList objectAtIndex:0] cachedTime];

                for (j = 1; j < [pointList count]; j++) {
                    time2 = [[pointList objectAtIndex:j] cachedTime];
                    if ((tempTime < time2) && (tempTime > time1)) {
                        *startTime = time1;
                        *endTime = time2;
                        //NSLog(@"<  %s", _cmd);
                        return [[currentMMSlopeRatio slopes] objectAtIndex:j-1];
                    }

                    time1 = time2;
                }
            }
        }
    }

    //NSLog(@"<  %s", _cmd);
    return nil;
}

//
// NSTextView delegate method, used for editing slopes
//

- (void)textDidEndEditing:(NSNotification *)notification;
{
    NSString *str;

    str = [nonretained_fieldEditor string];

    [editingSlope setSlope:[str floatValue]];
    [self _setEditingSlope:nil];

    [nonretained_fieldEditor removeFromSuperview];
    nonretained_fieldEditor = nil;

    [self setNeedsDisplay:YES];
}

//
// Selection
//

- (MMPoint *)selectedPoint;
{
    if ([selectedPoints count] > 0)
        return [selectedPoints objectAtIndex:0];

    return nil;
}

- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
{
    NSPoint graphOrigin;
    NSRect selectionRect;
    NSUInteger count, index;
    CGFloat timeScale;
    CGFloat yScale;
    NSUInteger cacheTag;

    [selectedPoints removeAllObjects];

    cacheTag = [[self model] nextCacheTag];
    //NSLog(@"%s, cacheTag: %d", _cmd, cacheTag);
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

- (void)_selectionDidChange;
{
    NSNotification *aNotification;

    aNotification = [NSNotification notificationWithName:TransitionViewSelectionDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotification:aNotification];

    if ([[self delegate] respondsToSelector:@selector(transitionViewSelectionDidChange:)] == YES)
        [[self delegate] transitionViewSelectionDidChange:aNotification];
}

//
// Actions
//

- (IBAction)deleteBackward:(id)sender;
{
    NSUInteger i;
    MMPoint *tempPoint;

    if (transition == nil || [selectedPoints count] == 0) {
        NSBeep();
        return;
    }

    for (i = 0; i < [selectedPoints count]; i++) {
        tempPoint = [selectedPoints objectAtIndex:i];
        if ([[transition points] indexOfObject:tempPoint]) {
            [[transition points] removeObject:tempPoint];
        }
    }

    [selectedPoints removeAllObjects];
    [self _selectionDidChange];

    [self setNeedsDisplay:YES];
}


- (IBAction)groupInSlopeRatio:(id)sender;
{
    NSUInteger i, index;
    NSUInteger type;
    NSMutableArray *tempPoints, *newPoints;
    MMSlopeRatio *newSlopeRatio;

    if ([selectedPoints count] < 3) {
        NSLog(@"You must have at least three points selected to create a Slope Ratio.");
        NSBeep();
        return;
    }

    type = [(MMPoint *)[selectedPoints objectAtIndex:0] type];
    for (i = 1; i < [selectedPoints count]; i++) {
        if (type != [(MMPoint *)[selectedPoints objectAtIndex:i] type]) {
            NSLog(@"All of the selected points should have the same type.");
            NSBeep();
            return;
        }
    }

    tempPoints = [transition points];

    index = [tempPoints indexOfObject:[selectedPoints objectAtIndex:0]];
    [tempPoints removeObjectsInArray:selectedPoints];

    newSlopeRatio = [[MMSlopeRatio alloc] init];
    newPoints = [newSlopeRatio points];
    [newPoints addObjectsFromArray:selectedPoints];
    [newSlopeRatio updateSlopes];

    [tempPoints insertObject:newSlopeRatio atIndex:index];
    [newSlopeRatio release];

    [self setNeedsDisplay:YES];
}

//
// Publicly used API
//

- (MMTransition *)transition;
{
    return transition;
}

- (void)setTransition:(MMTransition *)newTransition;
{
    [[self window] endEditingFor:nil];
    [selectedPoints removeAllObjects];
    [self _selectionDidChange];
    [displayPoints removeAllObjects];
    [displaySlopes removeAllObjects];

    // In case we've changed the type of the transition
    if (newTransition != transition) {
        [transition release];
        transition = [newTransition retain];
    }

    [self updateTransitionType];
    [self setNeedsDisplay:YES];
}

@end
