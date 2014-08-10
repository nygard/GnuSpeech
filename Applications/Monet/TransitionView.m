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
    MMFRuleSymbols *_parameters;

    NSFont *_timesFont;
    
    MMTransition *_transition;

    NSMutableArray *_samplePhones;
    NSMutableArray *_displayPoints;
    NSMutableArray *_displaySlopes;
    NSMutableArray *_selectedPoints;

    NSPoint _selectionPoint1;
    NSPoint _selectionPoint2;

    MMSlope *_editingSlope;
    NSTextFieldCell *_textFieldCell;
    NSText *_fieldEditor; // nonretained?
    
    NSInteger _zeroIndex;
    NSInteger _sectionAmount;

    MModel *_model;

    struct {
        unsigned int shouldDrawSelection:1;
        unsigned int shouldDrawSlopes:1;
    } _flags;

    __weak id _delegate;
}

// The size was originally 700 x 380
- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        _parameters = [[MMFRuleSymbols alloc] init];
        _timesFont = [NSFont fontWithName:@"Times-Roman" size:12];
        _transition = nil;
        
        _samplePhones = [[NSMutableArray alloc] init];
        _displayPoints = [[NSMutableArray alloc] init];
        _displaySlopes = [[NSMutableArray alloc] init];
        _selectedPoints = [[NSMutableArray alloc] init];
        
        _flags.shouldDrawSelection = NO;
        _flags.shouldDrawSlopes = YES;
        
        _editingSlope = nil;
        _textFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
        _fieldEditor = nil;
        
        _zeroIndex = 2;
        _sectionAmount = 10;
        
        [self setNeedsDisplay:YES];
    }

    return self;
}

#pragma mark -

- (NSInteger)zeroIndex;
{
    return _zeroIndex;
}

- (void)setZeroIndex:(NSInteger)newZeroIndex;
{
    if (newZeroIndex == _zeroIndex)
        return;

    _zeroIndex = newZeroIndex;
    [self setNeedsDisplay:YES];
}

- (NSInteger)sectionAmount;
{
    return _sectionAmount;
}

- (void)setSectionAmount:(NSInteger)newSectionAmount;
{
    if (newSectionAmount == _sectionAmount)
        return;

    _sectionAmount = newSectionAmount;
    [self setNeedsDisplay:YES];
}

- (MModel *)model;
{
    return _model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == _model)
        return;

    _model = newModel;

    [self _updateFromModel];
}

// TODO (2004-03-21): I don't think this will catch changes to the "Formula Symbols"... i.e. adding or removing them.
- (void)_updateFromModel;
{
    [_samplePhones removeAllObjects];
    [_displayPoints removeAllObjects];
    [_displaySlopes removeAllObjects];
    [_selectedPoints removeAllObjects];

    MMPosture *aPosture = [[MMPosture alloc] initWithModel:_model];
    [aPosture setName:@"dummy"];
    if ([[aPosture symbolTargets] count] >= 4) {
        [(MMTarget *)[[aPosture symbolTargets] objectAtIndex:0] setValue:100.0]; // duration
        [(MMTarget *)[[aPosture symbolTargets] objectAtIndex:1] setValue:33.3333]; // transition
        [(MMTarget *)[[aPosture symbolTargets] objectAtIndex:2] setValue:33.3333]; // qssa
        [(MMTarget *)[[aPosture symbolTargets] objectAtIndex:3] setValue:33.3333]; // qssb
    }

    MMPhone *phone1 = [[MMPhone alloc] initWithPosture:aPosture];
    MMPhone *phone2 = [[MMPhone alloc] initWithPosture:aPosture];
    MMPhone *phone3 = [[MMPhone alloc] initWithPosture:aPosture];
    MMPhone *phone4 = [[MMPhone alloc] initWithPosture:aPosture];

    // We need four postures to show a tetraphone
    [_samplePhones addObject:phone1];
    [_samplePhones addObject:phone2];
    [_samplePhones addObject:phone3];
    [_samplePhones addObject:phone4];

    [self setNeedsDisplay:YES];
}

- (void)updateTransitionType;
{
    switch ([_transition type]) {
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

// TODO (2012-04-23): Observe any changes to self.parameters values w/ KVO

- (double)ruleDuration;
{
    return self.parameters.ruleDuration;
}

- (void)setRuleDuration:(double)newValue;
{
    self.parameters.ruleDuration = newValue;
    [self setNeedsDisplay:YES];
}

- (double)beatLocation;
{
    return self.parameters.beat;
}

- (void)setBeatLocation:(double)newValue;
{
    self.parameters.beat = newValue;
    [self setNeedsDisplay:YES];
}

- (double)mark1;
{
    return self.parameters.mark1;
}

- (void)setMark1:(double)newValue;
{
    self.parameters.mark1 = newValue;
    [self setNeedsDisplay:YES];
}

- (double)mark2;
{
    return self.parameters.mark2;
}

- (void)setMark2:(double)newValue;
{
    self.parameters.mark2 = newValue;
    [self setNeedsDisplay:YES];
}

- (double)mark3;
{
    return self.parameters.mark3;
}

- (void)setMark3:(double)newValue;
{
    self.parameters.mark3 = newValue;
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
    return _flags.shouldDrawSelection;
}

- (void)setShouldDrawSelection:(BOOL)newFlag;
{
    if (newFlag == _flags.shouldDrawSelection)
        return;

    _flags.shouldDrawSelection = newFlag;
    [self setNeedsDisplay:YES];
}

- (BOOL)shouldDrawSlopes;
{
    return _flags.shouldDrawSlopes;
}

- (void)setShouldDrawSlopes:(BOOL)newFlag;
{
    if (newFlag == _flags.shouldDrawSlopes)
        return;

    _flags.shouldDrawSlopes = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)rect;
{
    //NSLog(@" > %s, cache: %d", _cmd, cache);

    [self clearView];
    [self drawGrid];
    [self drawEquations];
    [self drawPhones];
    [self drawTransition];
    [self highlightSelectedPoints];
    if (_flags.shouldDrawSlopes == YES)
        [self drawSlopes];

    if (_flags.shouldDrawSelection == YES) {
        NSRect selectionRect = [self rectFormedByPoint:_selectionPoint1 andPoint:_selectionPoint2];
        selectionRect.origin.x += 0.5;
        selectionRect.origin.y += 0.5;

        [[NSColor purpleColor] set];
        [NSBezierPath strokeRect:selectionRect];
    }

    if (_fieldEditor != nil) {
        NSRect editingRect = [_fieldEditor frame];
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
    NSRect bounds = NSIntegralRect([self bounds]);

    CGFloat sectionHeight = [self sectionHeight];
    NSPoint graphOrigin = [self graphOrigin]; // But not the zero point on the graph.

    [[NSColor lightGrayColor] set];
    NSRect rect = NSMakeRect(graphOrigin.x + 1.0, graphOrigin.y + 1.0, bounds.size.width - 2 * (LEFT_MARGIN + 1), _zeroIndex * sectionHeight);
    NSRectFill(rect);

    rect = NSMakeRect(graphOrigin.x + 1.0, graphOrigin.y + 1.0 + (10 + _zeroIndex) * sectionHeight,
                      bounds.size.width - 2 * (LEFT_MARGIN + 1), 2 * sectionHeight);
    NSRectFill(rect);

    /* Grayed out (unused) data spaces should be placed here */

    [[NSColor blackColor] set];
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath appendBezierPathWithRect:NSMakeRect(graphOrigin.x, graphOrigin.y, bounds.size.width - 2 * LEFT_MARGIN, 14 * sectionHeight)];
    [bezierPath stroke];

    [[NSColor blackColor] set];
    [_timesFont set];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];

    for (NSInteger i = 1; i < SECTION_COUNT; i++) {
        CGFloat currentYPos = graphOrigin.y + 0.5 + i * sectionHeight;
        [bezierPath moveToPoint:NSMakePoint(graphOrigin.x + 0.5, currentYPos)];
        [bezierPath lineToPoint:NSMakePoint(bounds.size.width - LEFT_MARGIN + 0.5, currentYPos)];

        currentYPos = graphOrigin.y + i * sectionHeight - 5;
        NSString *label = [NSString stringWithFormat:@"%4ld%%", (i - _zeroIndex) * _sectionAmount];
        NSSize labelSize = [label sizeWithAttributes:nil];
        //NSLog(@"label (%@) size: %@", label, NSStringFromSize(labelSize));
        [label drawAtPoint:NSMakePoint(LEFT_MARGIN - LABEL_MARGIN - labelSize.width, currentYPos) withAttributes:nil];
        // The current max label width is 35, so we'll just shift the label over a little
        [label drawAtPoint:NSMakePoint(bounds.size.width - 10 - labelSize.width, currentYPos) withAttributes:nil];
    }

    [bezierPath stroke];
}

// These are the proto equations
- (void)drawEquations;
{
    if (_transition == nil) return;
    NSArray *groups = [_model equationGroups];
    CGFloat timeScale = [self timeScale];
    NSUInteger type;

    NSPoint graphOrigin = [self graphOrigin];

    NSUInteger cacheTag = [[self model] nextCacheTag];
    //NSLog(@"%s, cacheTag: %d", _cmd, cacheTag);

    if (_transition)
        type = [_transition type];
    else
        type = MMPhoneType_Diphone;

    [[NSColor darkGrayColor] set];
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    for (NSUInteger i = 0; i < [groups count]; i++) {
        MMGroup *group = [groups objectAtIndex:i];
        //NSLog(@"named list: %@, count: %d", [namedList name], [namedList count]);
        for (NSUInteger j = 0; j < [group.objects count]; j++) {
            MMEquation *equation = [group.objects objectAtIndex:j];
            if ([[equation formula] maxPhone] <= type) {
                double time = [equation evaluateWithPhonesInArray:self.samplePhones ruleSymbols:self.parameters andCacheWithTag:cacheTag];
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
}

- (void)drawPhones;
{
    if (_transition == nil) return;
    CGFloat currentTimePoint;
    NSUInteger type;
    NSRect bounds = NSIntegralRect([self bounds]);
    NSPoint graphOrigin = [self graphOrigin];

    if (_transition)
        type = [_transition type];
    else
        type = MMPhoneType_Diphone;

    [[NSColor blackColor] set];
    //[[NSColor redColor] set];

    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];

    CGFloat timeScale = [self timeScale];
    CGFloat graphTopYPos = bounds.size.height - BOTTOM_MARGIN - 1;

    NSPoint myPoint;
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
}

- (void)drawTransition;
{
    if (_transition == nil)
        return;

    [self updateDisplayPoints];

    [[NSColor blackColor] set];

    NSPoint graphOrigin = [self graphOrigin];

    CGFloat timeScale = [self timeScale];
    CGFloat yScale = [self sectionHeight];

    NSMutableArray *diphonePoints = [[NSMutableArray alloc] init];
    NSMutableArray *triphonePoints = [[NSMutableArray alloc] init];
    NSMutableArray *tetraphonePoints = [[NSMutableArray alloc] init];

    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath moveToPoint:NSMakePoint(graphOrigin.x, graphOrigin.y + (yScale * _zeroIndex))];

    // TODO (2004-03-02): With the bezier path change, we may want to do the compositing after we draw the path.
    NSUInteger count = [_displayPoints count];
    //NSLog(@"%d display points", count);
    for (NSUInteger index = 0; index < count; index++) {
        MMPoint *currentPoint = [_displayPoints objectAtIndex:index];
        CGFloat y = [currentPoint value];
        //NSLog(@"%d: [%p] y = %f", index, currentPoint, y);
        // TODO (2004-08-15): Move this into MMPoint
        CGFloat eventTime;
        if ([currentPoint timeEquation] == nil)
            eventTime = [currentPoint freeTime];
        else
            eventTime = [[currentPoint timeEquation] cacheValue];

        NSPoint myPoint;
        myPoint.x = graphOrigin.x + timeScale * eventTime;
        myPoint.y = graphOrigin.y + (yScale * _zeroIndex) + (y * (float)yScale / _sectionAmount);
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

        if (index != [_displayPoints count] - 1) {
            if ([currentPoint type] == [(MMPoint *)[_displayPoints objectAtIndex:index+1] type])
                [bezierPath moveToPoint:myPoint];
            else
                [bezierPath moveToPoint:NSMakePoint(myPoint.x, graphOrigin.y + (_zeroIndex * yScale))];
        } else
            [bezierPath moveToPoint:myPoint];
    }

    [bezierPath lineToPoint:NSMakePoint([self bounds].size.width - LEFT_MARGIN, [self bounds].size.height - BOTTOM_MARGIN - (_zeroIndex * yScale))];
    [bezierPath stroke];

    //[[NSColor redColor] set];
    count = [diphonePoints count];
    for (NSUInteger index = 0; index < count; index++) {
        NSPoint aPoint;

        aPoint = [[diphonePoints objectAtIndex:index] pointValue];
        [NSBezierPath drawCircleMarkerAtPoint:aPoint];
    }

    count = [triphonePoints count];
    for (NSUInteger index = 0; index < count; index++) {
        NSPoint aPoint;

        aPoint = [[triphonePoints objectAtIndex:index] pointValue];
        [NSBezierPath drawTriangleMarkerAtPoint:aPoint];
    }

    count = [tetraphonePoints count];
    for (NSUInteger index = 0; index < count; index++) {
        NSPoint aPoint;

        aPoint = [[tetraphonePoints objectAtIndex:index] pointValue];
        [NSBezierPath drawSquareMarkerAtPoint:aPoint];
    }

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
    if (_transition == nil)
        return;

    [_displayPoints removeAllObjects];
    [_displaySlopes removeAllObjects];

    NSUInteger cacheTag = [[self model] nextCacheTag];
    //NSLog(@"%s, cacheTag: %d", _cmd, cacheTag);

    NSArray *currentPoints = [_transition points];
    NSUInteger count = [currentPoints count];
    for (NSUInteger index = 0; index < count; index++) {
        MMPoint *currentPoint = [currentPoints objectAtIndex:index];
        //NSLog(@"%2d: object class: %@", index, NSStringFromClass([currentPoint class]));
        //NSLog(@"%2d (a): value: %g, freeTime: %g, type: %d, isPhantom: %d", index, [currentPoint value], [currentPoint freeTime], [currentPoint type], [currentPoint isPhantom]);
        [currentPoint calculatePointsWithPhonesInArray:self.samplePhones ruleSymbols:self.parameters andCacheWithTag:cacheTag andAddToDisplay:_displayPoints];
        //NSLog(@"%2d (b): value: %g, freeTime: %g, type: %d, isPhantom: %d", index, [currentPoint value], [currentPoint freeTime], [currentPoint type], [currentPoint isPhantom]);

        if ([currentPoint isKindOfClass:[MMSlopeRatio class]])
            [(MMSlopeRatio *)currentPoint displaySlopesInList:_displaySlopes];
    }
}

- (void)highlightSelectedPoints;
{
    if ([_selectedPoints count]) {
        //NSLog(@"Drawing %d selected points", [selectedPoints count]);

        NSPoint graphOrigin = [self graphOrigin];
        CGFloat timeScale = [self timeScale];
        CGFloat yScale = [self sectionHeight];

        for (NSUInteger index = 0; index < [_selectedPoints count]; index++) {
            CGFloat eventTime;

            MMPoint *currentPoint = [_selectedPoints objectAtIndex:index];
            CGFloat y = (CGFloat)[currentPoint value];
            if ([currentPoint timeEquation] == nil)
                eventTime = [currentPoint freeTime];
            else
                eventTime = [[currentPoint timeEquation] cacheValue];

            NSPoint myPoint;
            myPoint.x = graphOrigin.x + timeScale * eventTime;
            myPoint.y = graphOrigin.y + (yScale * _zeroIndex) + (y * (float)yScale / _sectionAmount);

            //NSLog(@"Selection; x: %f y:%f", myPoint.x, myPoint.y);

            [NSBezierPath highlightMarkerAtPoint:myPoint];
        }
    }
}

#pragma mark - Event handling

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event;
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event;
{
    if ([self isEnabled] == NO) {
        [super mouseDown:event];
        return;
    }

    // Force this to be first responder, since nothing else seems to work!
    [[self window] makeFirstResponder:self];

    NSPoint hitPoint = [self convertPoint:[event locationInWindow] fromView:nil];
    //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));

    CGFloat startTime, endTime;
    MMSlope *hitSlope = [self getSlopeMarkerAtPoint:hitPoint startTime:&startTime endTime:&endTime];

    [self setShouldDrawSelection:NO];
    [_selectedPoints removeAllObjects];
    [self _selectionDidChange];
    [self setNeedsDisplay:YES];

    if ([event clickCount] == 1) {
        if (hitSlope == nil || _flags.shouldDrawSlopes == NO)
            [[self window] endEditingFor:nil];
        else {
            [self editSlope:hitSlope startTime:startTime endTime:endTime];
            return;
        }

        //NSLog(@"[mouseEvent modifierFlags]: %x", [mouseEvent modifierFlags]);
        if ([event modifierFlags] & NSAlternateKeyMask) {
            NSPoint graphOrigin = [self graphOrigin];
            CGFloat yScale = [self sectionHeight];

            //NSLog(@"Alt-clicked!");
            MMPoint *newPoint = [[MMPoint alloc] init];
            [newPoint setFreeTime:(hitPoint.x - graphOrigin.x) / [self timeScale]];
            //NSLog(@"hitPoint: %@, graphOrigin: %@, yScale: %d", NSStringFromPoint(hitPoint), NSStringFromPoint(graphOrigin), yScale);
            CGFloat newValue = (hitPoint.y - graphOrigin.y - (_zeroIndex * yScale)) * _sectionAmount / yScale;

            //NSLog(@"NewPoint Time: %f  value: %f", [tempPoint freeTime], [tempPoint value]);
            [newPoint setValue:newValue];
            if ([[self delegate] respondsToSelector:@selector(transitionView:shouldAddPoint:)] == NO
                || [[self delegate] transitionView:self shouldAddPoint:newPoint] == YES) {
                [_transition insertPoint:newPoint];
                [_selectedPoints removeAllObjects];
                [_selectedPoints addObject:newPoint];
            }

            [self _selectionDidChange];
            [self setNeedsDisplay:YES];
            return;
        }
    }


    _selectionPoint1 = hitPoint;
    _selectionPoint2 = hitPoint; // TODO (2004-03-11): Should only do this one they start dragging
    [self setShouldDrawSelection:YES];
}

- (void)mouseDragged:(NSEvent *)event;
{
    //NSLog(@" > %s", _cmd);

    if ([self isEnabled] == NO)
        return;

    if (_flags.shouldDrawSelection == YES) {
        NSPoint hitPoint = [self convertPoint:[event locationInWindow] fromView:nil];
        //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));
        _selectionPoint2 = hitPoint;
        [self setNeedsDisplay:YES];

        [self selectGraphPointsBetweenPoint:_selectionPoint1 andPoint:_selectionPoint2];
    }

    //NSLog(@"<  %s", _cmd);
}

- (void)mouseUp:(NSEvent *)event;
{
    [self setShouldDrawSelection:NO];
}

- (void)keyDown:(NSEvent *)event;
{
    NSArray *keyEvents = [[NSArray alloc] initWithObjects:event, nil];
    [self interpretKeyEvents:keyEvents];
}

#pragma mark - View geometry

- (CGFloat)sectionHeight;
{
    NSRect bounds = [self bounds];
    CGFloat sectionHeight = (bounds.size.height - 2 * BOTTOM_MARGIN) / SECTION_COUNT;

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

    NSRect rect;
    rect.origin.x = minx;
    rect.origin.y = miny;
    rect.size.width = maxx - minx;
    rect.size.height = maxy - miny;

    return rect;
}

- (CGFloat)slopeMarkerYPosition;
{
    NSPoint graphOrigin = [self graphOrigin];

    return graphOrigin.y - BOTTOM_MARGIN + 10;
}

- (NSRect)slopeMarkerRect;
{
    NSRect bounds = NSIntegralRect([self bounds]);
    NSPoint graphOrigin = [self graphOrigin];

    NSRect rect;
    rect.origin.x = graphOrigin.x;
    rect.origin.y = [self slopeMarkerYPosition];
    rect.size.width = bounds.size.width - 2 * LEFT_MARGIN;
    rect.size.height = SLOPE_MARKER_HEIGHT; // Roughly

    return rect;
}

#pragma mark - Slopes

- (void)drawSlopes;
{
    NSRect rect = NSMakeRect(0, 0, 2 * LEFT_MARGIN, SLOPE_MARKER_HEIGHT);
    CGFloat timeScale = [self timeScale];

    NSRect bounds = [self bounds];
    NSPoint graphOrigin = [self graphOrigin];
    rect.origin.y = [self slopeMarkerYPosition];

    NSArray *transitionPoints = [_transition points];
    NSUInteger count = [transitionPoints count];
    for (NSUInteger index = 0; index < count; index++) {
        id currentPoint = [transitionPoints objectAtIndex:index];
        if ([currentPoint isKindOfClass:[MMSlopeRatio class]]) {
            //NSLog(@"%d: Drawing slope ratio...", index);
            double start = graphOrigin.x + [currentPoint startTime] * timeScale;
            double end = graphOrigin.x + [currentPoint endTime] * timeScale;
            //NSLog(@"Slope  %f -> %f", start, end);
            rect.origin.x = (float)start;
            rect.size.width = (float)(end - start);
            //NSLog(@"drawing button, rect: %@, bounds: %@", NSStringFromRect(rect), NSStringFromRect(bounds));
            NSDrawButton(rect, bounds);

            NSMutableArray *slopes = [currentPoint slopes];
            NSMutableArray *points = [currentPoint points];
            for (NSUInteger j = 0; j < [slopes count]; j++) {
                NSRect textFieldFrame;

                NSString *str = [NSString stringWithFormat:@"%.1f", [[slopes objectAtIndex:j] slope]];
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
                [_textFieldCell setStringValue:str];
                [_textFieldCell setFont:_timesFont];
                [_textFieldCell drawWithFrame:textFieldFrame inView:self];
            }
        }
    }
}

- (void)_setEditingSlope:(MMSlope *)newSlope;
{
    if (newSlope == _editingSlope)
        return;

    _editingSlope = newSlope;
}

- (void)editSlope:(MMSlope *)slope startTime:(CGFloat)startTime endTime:(CGFloat)endTime;
{
    if (slope == nil)
        return;

    NSWindow *window = [self window];

    if ([window makeFirstResponder:window] == YES) {
        [self _setEditingSlope:slope];
        CGFloat timeScale = [self timeScale];

        NSRect rect;
        rect.origin.x = LEFT_MARGIN + startTime * timeScale;
        rect.origin.y = [self slopeMarkerYPosition];
        rect.size.width = (endTime - startTime) * timeScale;
        rect.size.height = SLOPE_MARKER_HEIGHT;
        rect = NSIntegralRect(rect);
        _fieldEditor = [window fieldEditor:YES forObject:self];

        [_fieldEditor setString:[NSString stringWithFormat:@"%0.1f", [slope slope]]];
        [_fieldEditor setRichText:NO];
        [_fieldEditor setUsesFontPanel:NO];
        [_fieldEditor setFont:_timesFont];
        [_fieldEditor setHorizontallyResizable:NO];
        [_fieldEditor setVerticallyResizable:NO];
        [_fieldEditor setAutoresizingMask:NSViewWidthSizable];

        [_fieldEditor setFrame:rect];
        [_fieldEditor setMinSize:rect.size];
        [_fieldEditor setMaxSize:rect.size];
        [[(NSTextView *)_fieldEditor textContainer] setLineFragmentPadding:3];

        [_fieldEditor setFieldEditor:YES];

        [self setNeedsDisplay:YES];
        [_fieldEditor setNeedsDisplay:YES];
        [_fieldEditor setDelegate:self];

        [self addSubview:_fieldEditor positioned:NSWindowAbove relativeTo:nil];

        [window makeFirstResponder:_fieldEditor];
        [_fieldEditor selectAll:nil];
    } else {
        [window endEditingFor:nil];
    }
}

- (MMSlope *)getSlopeMarkerAtPoint:(NSPoint)point startTime:(CGFloat *)startTime endTime:(CGFloat *)endTime;
{
    CGFloat timeScale = [self timeScale];

    //NSLog(@" > %s", _cmd);
    //NSLog(@"aPoint: %@", NSStringFromPoint(aPoint));

    //if ( (aPoint.y > -21.0) || (aPoint.y < -39.0)) {

    NSRect slopeMarkerRect = [self slopeMarkerRect];
    if (NSPointInRect(point, slopeMarkerRect) == NO) {
        //NSLog(@"Y not in range -21 to -39, returning.");
        //NSLog(@"<  %s", _cmd);
        return nil;
    }

    point.x -= LEFT_MARGIN;
    point.y -= BOTTOM_MARGIN;

    CGFloat tempTime = point.x / timeScale;

    //NSLog(@"ClickSlopeMarker Row: %f  Col: %f  time = %f", aPoint.y, aPoint.x, tempTime);

    NSArray *points = [_transition points];
    for (NSUInteger i = 0; i < [points count]; i++) {
        MMSlopeRatio *currentMMSlopeRatio = [points objectAtIndex:i];
        if ([currentMMSlopeRatio isKindOfClass:[MMSlopeRatio class]]) {
            if ((tempTime < [currentMMSlopeRatio endTime]) && (tempTime > [currentMMSlopeRatio startTime])) {
                NSMutableArray *pointList = [currentMMSlopeRatio points];
                CGFloat time1 = [[pointList objectAtIndex:0] cachedTime];

                for (NSUInteger j = 1; j < [pointList count]; j++) {
                    CGFloat time2 = [[pointList objectAtIndex:j] cachedTime];
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

#pragma mark - NSTextView delegate method, used for editing slopes

- (void)textDidEndEditing:(NSNotification *)notification;
{
    NSString *str = [_fieldEditor string];

    [_editingSlope setSlope:[str floatValue]];
    [self _setEditingSlope:nil];

    [_fieldEditor removeFromSuperview];
    _fieldEditor = nil;

    [self setNeedsDisplay:YES];
}

#pragma mark - Selection

- (MMPoint *)selectedPoint;
{
    if ([_selectedPoints count] > 0)
        return [_selectedPoints objectAtIndex:0];

    return nil;
}

- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
{
    [_selectedPoints removeAllObjects];

    NSUInteger cacheTag = [[self model] nextCacheTag];
    //NSLog(@"%s, cacheTag: %d", _cmd, cacheTag);
    NSPoint graphOrigin = [self graphOrigin];
    CGFloat timeScale = [self timeScale];
    CGFloat yScale = [self sectionHeight];

    NSRect selectionRect = [self rectFormedByPoint:point1 andPoint:point2];
    selectionRect.origin.x -= graphOrigin.x;
    selectionRect.origin.y -= graphOrigin.y;

    //NSLog(@"%s, selectionRect: %@", _cmd, NSStringFromRect(selectionRect));

    NSUInteger count = [_displayPoints count];
    //NSLog(@"%d display points", count);
    for (NSUInteger index = 0; index < count; index++) {
        NSPoint currentPoint;

        MMPoint *currentDisplayPoint = [_displayPoints objectAtIndex:index];
        MMEquation *currentExpression = [currentDisplayPoint timeEquation];
        if (currentExpression == nil)
            currentPoint.x = [currentDisplayPoint freeTime];
        else {
            MMEquation *equation = [currentDisplayPoint timeEquation];
            currentPoint.x = [equation evaluateWithPhonesInArray:self.samplePhones ruleSymbols:self.parameters andCacheWithTag:cacheTag];
        }

        currentPoint.x *= timeScale;
        currentPoint.y = (yScale * _zeroIndex) + ([currentDisplayPoint value] * yScale / _sectionAmount);

        //NSLog(@"%2d: currentPoint: %@", index, NSStringFromPoint(currentPoint));
        if (NSPointInRect(currentPoint, selectionRect) == YES) {
            [_selectedPoints addObject:currentDisplayPoint];
        }
    }

    [self _selectionDidChange];
    [self setNeedsDisplay:YES];
}

- (void)_selectionDidChange;
{
    NSNotification *notification = [NSNotification notificationWithName:TransitionViewSelectionDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([[self delegate] respondsToSelector:@selector(transitionViewSelectionDidChange:)] == YES)
        [[self delegate] transitionViewSelectionDidChange:notification];
}

#pragma mark - Actions

- (IBAction)deleteBackward:(id)sender;
{
    if (_transition == nil || [_selectedPoints count] == 0) {
        NSBeep();
        return;
    }

    for (NSUInteger i = 0; i < [_selectedPoints count]; i++) {
        MMPoint *tempPoint = [_selectedPoints objectAtIndex:i];
        if ([[_transition points] indexOfObject:tempPoint]) {
            [[_transition points] removeObject:tempPoint];
        }
    }

    [_selectedPoints removeAllObjects];
    [self _selectionDidChange];

    [self setNeedsDisplay:YES];
}


- (IBAction)groupInSlopeRatio:(id)sender;
{
    if ([_selectedPoints count] < 3) {
        NSLog(@"You must have at least three points selected to create a Slope Ratio.");
        NSBeep();
        return;
    }

    NSUInteger type = [(MMPoint *)[_selectedPoints objectAtIndex:0] type];
    for (NSUInteger i = 1; i < [_selectedPoints count]; i++) {
        if (type != [(MMPoint *)[_selectedPoints objectAtIndex:i] type]) {
            NSLog(@"All of the selected points should have the same type.");
            NSBeep();
            return;
        }
    }

    NSMutableArray *tempPoints = [_transition points];

    NSUInteger index = [tempPoints indexOfObject:[_selectedPoints objectAtIndex:0]];
    [tempPoints removeObjectsInArray:_selectedPoints];

    MMSlopeRatio *newSlopeRatio = [[MMSlopeRatio alloc] init];
    NSMutableArray *newPoints = [newSlopeRatio points];
    [newPoints addObjectsFromArray:_selectedPoints];
    [newSlopeRatio updateSlopes];

    [tempPoints insertObject:newSlopeRatio atIndex:index];

    [self setNeedsDisplay:YES];
}

#pragma mark - Publicly used API

- (MMTransition *)transition;
{
    return _transition;
}

- (void)setTransition:(MMTransition *)newTransition;
{
    [[self window] endEditingFor:nil];
    [_selectedPoints removeAllObjects];
    [self _selectionDidChange];
    [_displayPoints removeAllObjects];
    [_displaySlopes removeAllObjects];

    // In case we've changed the type of the transition
    if (newTransition != _transition) {
        _transition = newTransition;
    }

    [self updateTransitionType];
    [self setNeedsDisplay:YES];
}

@end
