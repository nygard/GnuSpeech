//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAIntonationView.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSBezierPath-Extensions.h"
#import "NSColor-STExtensions.h"
#import "NSNumberFormatter-Extensions.h"

#import "MAIntonationScaleView.h"

#import <math.h>

#define TOP_MARGIN 65
#define BOTTOM_MARGIN 50
#define LEFT_MARGIN 1
#define RIGHT_MARGIN 20.0

#define SECTION_COUNT 30

#define RULE_Y_OFFSET 40
#define RULE_HEIGHT 30
#define POSTURE_Y_OFFSET 62

#define ZERO_SECTION 20

NSString *MAIntonationViewSelectionDidChangeNotification = @"MAIntonationViewSelectionDidChangeNotification";

@implementation MAIntonationView
{
    NSTextFieldCell *_postureTextFieldCell;
    NSTextFieldCell *_ruleIndexTextFieldCell;
    NSTextFieldCell *_ruleDurationTextFieldCell;

    NSTextFieldCell *_labelTextFieldCell;
    NSTextFieldCell *_horizontalAxisLabelTextFieldCell;

    MAIntonationScaleView *_scaleView;

    NSFont *_timesFont;
    NSFont *_timesFontSmall;

    EventList *_eventList;

    CGFloat _timeScale;

    NSMutableArray *_selectedPoints;
    NSPoint _selectionPoint1;
    NSPoint _selectionPoint2;

    struct {
        unsigned int shouldDrawSelection:1;
        unsigned int shouldDrawSmoothPoints:1;
        unsigned int mouseBeingDragged:1;
    } _flags;
    
    __weak id _delegate;
}

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        _postureTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
        _ruleIndexTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
        [_ruleIndexTextFieldCell setFont:[NSFont labelFontOfSize:10.0]];
        [_ruleIndexTextFieldCell setAlignment:NSCenterTextAlignment];
        
        NSNumberFormatter *durationFormatter = [[NSNumberFormatter alloc] init];
        [durationFormatter setFormat:@"0.##"];
        
        _ruleDurationTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
        [_ruleDurationTextFieldCell setAlignment:NSCenterTextAlignment];
        [_ruleDurationTextFieldCell setFont:[NSFont labelFontOfSize:8.0]];
        [_ruleDurationTextFieldCell setFormatter:durationFormatter];

        NSFont *font = [[NSFontManager sharedFontManager] fontWithFamily:@"Times" traits:0 weight:0 size:10.0];
        _labelTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
        [_labelTextFieldCell setFont:font];
        
        font = [[NSFontManager sharedFontManager] fontWithFamily:@"Times" traits:0 weight:0 size:14.0];
        _horizontalAxisLabelTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
        [_horizontalAxisLabelTextFieldCell setFont:font];
        [_horizontalAxisLabelTextFieldCell setStringValue:@"Time (ms)"];
        
        _timesFont = [NSFont fontWithName:@"Times-Roman" size:12];
        _timesFontSmall = [NSFont fontWithName:@"Times-Roman" size:10];
        
        [_postureTextFieldCell setFont:_timesFont];
        
        _timeScale = 2.0;
        _flags.mouseBeingDragged = NO;
        
        _eventList = nil;
        
        _selectedPoints = [[NSMutableArray alloc] init];
        
        [self setNeedsDisplay:YES];
    }

    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)setScaleView:(MAIntonationScaleView *)newScaleView;
{
    if (newScaleView == _scaleView)
        return;

    _scaleView = newScaleView;

    [_scaleView setSectionCount:SECTION_COUNT];
    [_scaleView setSectionHeight:[self sectionHeight]];
    [_scaleView setZeroSection:ZERO_SECTION];
    [_scaleView setYOrigin:[self graphOrigin].y];
}

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (void)setEventList:(EventList *)newEventList;
{
    if (newEventList == _eventList)
        return;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventListDidChangeIntonationPoints object:nil];

    _eventList = newEventList;

    if (_eventList != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(intonationPointDidChange:)
                                              name:EventListDidChangeIntonationPoints
                                              object:_eventList];
    }

    [self setNeedsDisplay:YES];
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

- (BOOL)shouldDrawSmoothPoints;
{
    return _flags.shouldDrawSmoothPoints;
}

- (void)setShouldDrawSmoothPoints:(BOOL)newFlag;
{
    if (newFlag == _flags.shouldDrawSmoothPoints)
        return;

    _flags.shouldDrawSmoothPoints = newFlag;
    [self setNeedsDisplay:YES];
}

- (id)delegate;
{
    return _delegate;
}

- (void)setDelegate:(id)newDelegate;
{
    _delegate = newDelegate;
}

- (CGFloat)minimumWidth;
{
    CGFloat minimumWidth;

    if ([[_eventList events] count] == 0) {
        minimumWidth = 0.0;
    } else {
        Event *lastEvent;
        lastEvent = [[_eventList events] lastObject];

        minimumWidth = [self scaleWidth:[lastEvent time]] + RIGHT_MARGIN;
    }

    // Make sure that we at least show something.
    if (minimumWidth < 50.0)
        minimumWidth = 50.0;

    return minimumWidth;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize;
{
    [super resizeWithOldSuperviewSize:oldSize];
    [self resizeWidth];
}

- (void)resizeWidth;
{
    NSScrollView *enclosingScrollView = [self enclosingScrollView];
    if (enclosingScrollView != nil) {
        NSRect documentVisibleRect = [enclosingScrollView documentVisibleRect];
        NSRect bounds = [self bounds];

        bounds.size.width = [self minimumWidth];
        if (bounds.size.width < documentVisibleRect.size.width)
            bounds.size.width = documentVisibleRect.size.width;

        [self setFrameSize:bounds.size];
        [self setNeedsDisplay:YES];
        [[self superview] setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)rect;
{
    [[NSColor whiteColor] set];
    NSRectFill(rect);

    [self drawRuleBackground];
    [self drawHorizontalScale];
    [self drawGrid];
    [self drawRules];
    [self drawPostureLabels];
    [self drawIntonationPoints];

    if (_flags.shouldDrawSmoothPoints && _flags.mouseBeingDragged == NO)
        [self drawSmoothPoints];

    if (_flags.shouldDrawSelection) {
        NSRect selectionRect = [self rectFormedByPoint:_selectionPoint1 andPoint:_selectionPoint2];
        selectionRect.origin.x += 0.5;
        selectionRect.origin.y += 0.5;

        [[NSColor purpleColor] set];
        [NSBezierPath strokeRect:selectionRect];
    }

    [[self enclosingScrollView] reflectScrolledClipView:(NSClipView *)[self superview]];
}

- (void)drawGrid;
{
    NSRect bounds = NSIntegralRect([self bounds]);
    NSPoint graphOrigin = [self graphOrigin];
    CGFloat sectionHeight = [self sectionHeight];

    // Draw border around graph
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    //[bezierPath appendBezierPathWithRect:NSMakeRect(graphOrigin.x, graphOrigin.y, bounds.size.width - 2, SECTION_COUNT * sectionHeight)];
    [bezierPath appendBezierPathWithRect:NSMakeRect(graphOrigin.x - 2, graphOrigin.y, bounds.size.width, SECTION_COUNT * sectionHeight)];

    [[NSColor blackColor] set];
    [bezierPath stroke];

    // Draw semitone grid markers
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    for (NSUInteger index = 0; index < SECTION_COUNT; index++) {
        NSPoint point;

        point.x = 0.0;
        point.y = rint(graphOrigin.y + index * sectionHeight) + 0.5;
        [bezierPath moveToPoint:point];

        point.x = bounds.size.width - 2;
        [bezierPath lineToPoint:point];
    }

    [[NSColor lightGrayColor] set];
    [bezierPath stroke];

    // Draw the zero semitone line in black.
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    {
        NSPoint point;

        point.x = 0.0;
        point.y = rint(graphOrigin.y + ZERO_SECTION * sectionHeight) + 0.5;
        [bezierPath moveToPoint:point];

        point.x = bounds.size.width - 2;
        [bezierPath lineToPoint:point];
    }

    [[NSColor blackColor] set];
    [bezierPath stroke];
}

- (void)drawHorizontalScale;
{
    NSRect bounds = NSIntegralRect([self bounds]);
    NSRect rect = bounds;

    NSPoint graphOrigin = [self graphOrigin];
    rect.origin = graphOrigin;
    rect.origin.y -= BOTTOM_MARGIN;
    rect.size.height = BOTTOM_MARGIN;

    NSRect cellFrame;
    cellFrame.origin.x = 0.0;
    cellFrame.origin.y = graphOrigin.y - 10.0 - 12.0;
    cellFrame.size.width = 100.0;
    cellFrame.size.height = 12.0;

    NSPoint point;
    point.x = 0.0;
    CGFloat time = 0.0;

    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];

    while (point.x < NSMaxX(bounds)) {
        point.x = [self scaleXPosition:time] + 0.5;
        point.y = graphOrigin.y;
        [bezierPath moveToPoint:point];

        if (((NSInteger)time % 100) == 0) {
            point.y -= 10;

            [_labelTextFieldCell setIntValue:time];
            cellFrame.size = [_labelTextFieldCell cellSize];
            cellFrame.origin.x = point.x - (cellFrame.size.width / 2.0);
            if (cellFrame.origin.x < 0.0)
                cellFrame.origin.x = 0.0;
            if (NSMaxX(cellFrame) > NSMaxX(bounds))
                cellFrame.origin.x = NSMaxX(bounds) - cellFrame.size.width;
            [_labelTextFieldCell drawWithFrame:cellFrame inView:self];

        } else {
            point.y -= 5;
        }
        [bezierPath lineToPoint:point];

        time += 10.0;
    }

    [[NSColor blackColor] set];
    [bezierPath stroke];

    cellFrame.size = [_horizontalAxisLabelTextFieldCell cellSize];
    cellFrame.origin.y = graphOrigin.y - 10.0 - 12.0 - 20.0;
    cellFrame.origin.x = (bounds.size.width - cellFrame.size.width) / 2.0;
    [_horizontalAxisLabelTextFieldCell drawWithFrame:cellFrame inView:self];
}

// Put posture label on the top
// TODO (2004-08-16): Need right margin so that the last posture is visible.
- (void)drawPostureLabels;
{
    NSRect bounds = NSIntegralRect([self bounds]);

    [[NSColor blackColor] set];
    [_timesFont set];

    NSArray *events = [_eventList events];
    for (Event *event in events) {
        CGFloat currentX = event.time / _timeScale;

        if (event.isAtPosture) {
            if (event.posture != nil) {
                [[NSColor blackColor] set];
                [event.posture.name drawAtPoint:NSMakePoint(currentX, bounds.size.height - POSTURE_Y_OFFSET) withAttributes:nil];
            }
        }
    }
}

// Put Rules on top
- (void)drawRules;
{
    NSRect bounds = NSIntegralRect([self bounds]);
    NSPoint graphOrigin = [self graphOrigin];
    CGFloat sectionHeight = [self sectionHeight];

    [[NSColor blackColor] set];

    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    CGFloat currentX = 0.0;
    CGFloat extraWidth = 0.0;

    NSUInteger count = [_eventList.appliedRules count];
    for (NSUInteger index = 0; index < count; index++) {
        MMAppliedRule *appliedRule = _eventList.appliedRules[index];

        NSRect ruleFrame;
        ruleFrame.origin.x = currentX;
        ruleFrame.origin.y = bounds.size.height - RULE_Y_OFFSET;
        ruleFrame.size.height = RULE_HEIGHT;
        ruleFrame.size.width = [self scaleWidth:appliedRule.duration] + extraWidth;
        NSFrameRect(ruleFrame);

        ruleFrame.size.height = 15.0;
        [_ruleDurationTextFieldCell setDoubleValue:appliedRule.duration];
        [_ruleDurationTextFieldCell drawWithFrame:ruleFrame inView:self];

        ruleFrame.size.height += 12.0;
        [_ruleIndexTextFieldCell setIntegerValue:appliedRule.number];
        [_ruleIndexTextFieldCell drawWithFrame:ruleFrame inView:self];

        NSPoint point;
        point.x = [self scaleXPosition:appliedRule.beat] + 0.5;
        point.y = graphOrigin.y + SECTION_COUNT * sectionHeight - 1.0;
        [bezierPath moveToPoint:point];

        point.y = graphOrigin.y;
        [bezierPath lineToPoint:point];

        extraWidth = 1.0;
        currentX += ruleFrame.size.width - extraWidth;
    }

    {
        CGFloat dashes[2] = {2.0, 2.0};
        [bezierPath setLineDash:dashes count:2 phase:0.0];
    }

    [[NSColor darkGrayColor] set];
    [bezierPath stroke];
}

- (void)drawRuleBackground;
{
    NSPoint graphOrigin = [self graphOrigin];
    CGFloat sectionHeight = [self sectionHeight];

    NSRect ruleFrame;
    ruleFrame.origin.y = graphOrigin.y;
    ruleFrame.size.height = SECTION_COUNT * sectionHeight;

    ruleFrame.origin.x = 0.0;
    CGFloat extraWidth = 0.0;

    NSUInteger count = [_eventList.appliedRules count];
    for (NSUInteger index = 0; index < count; index++) {
        MMAppliedRule *appliedRule = _eventList.appliedRules[index];

        ruleFrame.size.width = [self scaleWidth:appliedRule.duration] + extraWidth;
        if ((index % 2) == 1) {
            [[NSColor lighterGrayColor] set];
            NSRectFill(ruleFrame);
        }

        extraWidth = 1.0;
        ruleFrame.origin.x += ruleFrame.size.width - extraWidth;
    }
}

- (void)drawIntonationPoints;
{
    NSPoint graphOrigin = [self graphOrigin];
    BOOL isFirstPoint = YES;

    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];

    for (MMIntonationPoint *intonationPoint in [_eventList intonationPoints]) {
        NSPoint currentPoint;
        currentPoint.x = [self scaleXPosition:[intonationPoint absoluteTime]];
        currentPoint.y = rint(graphOrigin.y + ([intonationPoint semitone] + ZERO_SECTION) * [self sectionHeight]) + 0.5;
        if (isFirstPoint) {
            isFirstPoint = NO;
            [bezierPath moveToPoint:currentPoint];
        } else {
            [bezierPath lineToPoint:currentPoint];
        }

        [NSBezierPath drawCircleMarkerAtPoint:currentPoint];
    }
    [[NSColor blackColor] set];
    [bezierPath stroke];

    [[NSColor blueColor] set];

    for (MMIntonationPoint *intonationPoint in _selectedPoints) {
        NSPoint currentPoint;
        currentPoint.x = [self scaleXPosition:[intonationPoint absoluteTime]];
        currentPoint.y = rint(graphOrigin.y + ([intonationPoint semitone] + ZERO_SECTION) * [self sectionHeight]) + 0.5;
        [NSBezierPath highlightMarkerAtPoint:currentPoint];
    }
}

// TODO (2004-03-15): See if we can just use the code from -applyIntonationSmooth instead.
- (void)drawSmoothPoints;
{
    NSArray *intonationPoints = [_eventList intonationPoints];

    if ([intonationPoints count] < 2)
        return;

    NSPoint graphOrigin = [self graphOrigin];

    for (NSUInteger j = 0; j < [intonationPoints count] - 1; j++) {
        MMIntonationPoint *point1 = [intonationPoints objectAtIndex:j];
        MMIntonationPoint *point2 = [intonationPoints objectAtIndex:j + 1];

        double x1 = [point1 absoluteTime];
        double y1 = [point1 semitone] + ZERO_SECTION;
        double m1 = [point1 slope];

        double x2 = [point2 absoluteTime];
        double y2 = [point2 semitone] + ZERO_SECTION;
        double m2 = [point2 slope];

        double x12 = x1*x1;
        double x13 = x12*x1;

        double x22 = x2*x2;
        double x23 = x22*x2;

        double denominator = (x2 - x1);
        denominator = denominator * denominator * denominator;

        double d = ( -(y2*x13) + 3*y2*x12*x2 + m2*x13*x2 + m1*x12*x22 - m2*x12*x22 - 3*x1*y1*x22 - m1*x1*x23 + y1*x23)    / denominator;
        double c = ( -(m2*x13) - 6*y2*x1*x2 - 2*m1*x12*x2 - m2*x12*x2 + 6*x1*y1*x2 + m1*x1*x22 + 2*m2*x1*x22 + m1*x23)    / denominator;
        double b = ( 3*y2*x1 + m1*x12 + 2*m2*x12 - 3*x1*y1 + 3*x2*y2 + m1*x1*x2 - m2*x1*x2 - 3*y1*x2 - 2*m1*x22 - m2*x22) / denominator;
        double a = ( -2*y2 - m1*x1 - m2*x1 + 2*y1 + m1*x2 + m2*x2)                                                        / denominator;

        //NSLog(@"\n===\n x1 = %f y1 = %f m1 = %f", x1, y1, m1);
        //NSLog(@"x2 = %f y2 = %f m2 = %f", x2, y2, m2);
        //NSLog(@"a = %f b = %f c = %f d = %f", a, b, c, d);

        // The curve looks better (darker) without adding the extra 0.5 to the y positions.
        NSPoint point;
        point.x = [self scaleXPosition:x1];
        point.y = graphOrigin.y + y1 * [self sectionHeight];

        NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
        [bezierPath moveToPoint:point];
        for (NSUInteger i = (int)x1; i <= (int)x2; i++) {
            double x = i;
            double y = x*x*x*a + x*x*b + x*c + d;

            point.x = [self scaleXPosition:i];
            point.y = graphOrigin.y + y * [self sectionHeight];
            [bezierPath lineToPoint:point];
        }

        [[NSColor blackColor] set];
        [bezierPath stroke];
    }
}

#pragma mark - Event handling

- (void)mouseEntered:(NSEvent *)event;
{
#ifdef PORTING
    NSEvent *nextEvent;
    NSPoint position;
    CGFloat time;

    [[self window] setAcceptsMouseMovedEvents:YES];
    while (1) {
        nextEvent = [[self window] nextEventMatchingMask:NSAnyEventMask];
        if (([nextEvent type] != NSMouseMoved) && ([nextEvent type] != NSMouseExited))
            [NSApp sendEvent:nextEvent];

        if ([nextEvent type] == NSMouseExited)
            break;

        if (([nextEvent type] == NSMouseMoved) && [[self window] isKeyWindow]) {
            position.x = [nextEvent locationInWindow].x;
            position.y = [nextEvent locationInWindow].y;
            position = [self convertPoint:position fromView:nil];
            time = (int)((position.x - 80.0) * timeScale);
//            if ((position.x<80.0) || (position.x>frame.size.width-20.0))
//                [mouseTimeField setStringValue:"--"];
//            else
//                [mouseTimeField setIntValue: (int)((position.x-80.0)*timeScale)];
        }

    }
    [[self window] setAcceptsMouseMovedEvents:NO];
#endif
}

- (void)keyDown:(NSEvent *)event;
{
    NSUInteger ruleCount = [_eventList.appliedRules count];

    NSString *characters = [event characters];
    NSUInteger length = [characters length];
    for (NSUInteger index = 0; index < length; index++) {
        unichar ch = [characters characterAtIndex:index];
        //NSLog(@"index: %d, character: %@", index, [characters substringWithRange:NSMakeRange(index, 1)]);

        switch (ch) {
            case NSDeleteFunctionKey:
            case NSDeleteCharacter:
                //NSLog(@"delete");
                [self delete:nil];
                break;

            case NSLeftArrowFunctionKey:
                //NSLog(@"left arrow");
                for (MMIntonationPoint *intonationPoint in _selectedPoints) {
                    if (intonationPoint.ruleIndex - 1 < 0) {
                        NSBeep();
                        return;
                    }
                }

                for (MMIntonationPoint *intonationPoint in _selectedPoints) {
                    [intonationPoint decrementRuleIndex];
                }
                break;

            case NSRightArrowFunctionKey:
                //NSLog(@"right arrow");
                for (MMIntonationPoint *intonationPoint in _selectedPoints) {
                    if (intonationPoint.ruleIndex + 1 >= ruleCount) {
                        NSBeep();
                        return;
                    }
                }

                for (MMIntonationPoint *intonationPoint in _selectedPoints) {
                    [intonationPoint incrementRuleIndex];
                }
                break;

            case NSUpArrowFunctionKey:
                //NSLog(@"up arrow");
                for (MMIntonationPoint *intonationPoint in _selectedPoints) {
                    if (intonationPoint.semitone + 1.0 > 10.0) {
                        NSBeep();
                        return;
                    }
                }

                for (MMIntonationPoint *intonationPoint in _selectedPoints) {
                    [intonationPoint incrementSemitone];
                }
                break;

            case NSDownArrowFunctionKey:
                //NSLog(@"down arrow");
                for (MMIntonationPoint *intonationPoint in _selectedPoints) {
                    if (intonationPoint.semitone - 1.0 < -20.0) {
                        NSBeep();
                        return;
                    }
                }

                for (MMIntonationPoint *intonationPoint in _selectedPoints) {
                    [intonationPoint decrementSemitone];
                }
                break;

            default:
                NSLog(@"index: %lu, character: %@ (%d)", index, [characters substringWithRange:NSMakeRange(index, 1)], [characters characterAtIndex:index]);
        }
    }
}

- (void)mouseDown:(NSEvent *)event;
{
#if 0
    if ([self isEnabled] == NO) {
        [super mouseDown:mouseEvent];
        return;
    }
#endif
    // Force this to be first responder, since nothing else seems to work!
    [[self window] makeFirstResponder:self];

    NSPoint hitPoint = [self convertPoint:[event locationInWindow] fromView:nil];
    //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));

    [self setShouldDrawSelection:NO];
    [_selectedPoints removeAllObjects];
    [self _selectionDidChange];

    if ([event clickCount] == 1) {
        if ([event modifierFlags] & NSAlternateKeyMask) {
            CGFloat absoluteTime = [self convertXPositionToTime:hitPoint.x];

            NSUInteger ruleIndex;
            double offsetTime;
            [_eventList getRuleIndex:&ruleIndex offsetTime:&offsetTime forAbsoluteTime:absoluteTime];

            MMIntonationPoint *newIntonationPoint = [[MMIntonationPoint alloc] init];
            [newIntonationPoint setSemitone:[self convertYPositionToSemitone:hitPoint.y]];
            [newIntonationPoint setRuleIndex:ruleIndex];
            [newIntonationPoint setOffsetTime:offsetTime];
            [_eventList addIntonationPoint:newIntonationPoint];

            [self selectIntonationPoint:newIntonationPoint];

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

//    if ([self isEnabled] == NO)
//        return;

    [self autoscroll:event];
    if (_flags.shouldDrawSelection) {
        NSPoint hitPoint = [self convertPoint:[event locationInWindow] fromView:nil];
        //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));
        _selectionPoint2 = hitPoint;
        [self setNeedsDisplay:YES];

        [self selectGraphPointsBetweenPoint:_selectionPoint1 andPoint:_selectionPoint2];
    }

    //NSLog(@"<  %s", _cmd);
}

- (void)mouseUp:(NSEvent *)mouseEvent;
{
    [self setShouldDrawSelection:NO];
}

- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
{
    //float timeScale;

    [_selectedPoints removeAllObjects];

    //NSLog(@"%s, cacheTag: %d", _cmd, cacheTag);
    NSPoint graphOrigin = [self graphOrigin];
    //timeScale = [self timeScale];

    NSRect selectionRect = [self rectFormedByPoint:point1 andPoint:point2];
    selectionRect.origin.x -= graphOrigin.x;
    selectionRect.origin.y -= graphOrigin.y;

    //NSLog(@"%s, selectionRect: %@", _cmd, NSStringFromRect(selectionRect));

    //NSLog(@"%d display points", count);
    for (MMIntonationPoint *currentIntonationPoint in [_eventList intonationPoints]) {
        NSPoint currentPoint;
        currentPoint.x = [self scaleXPosition:[currentIntonationPoint absoluteTime]];
        currentPoint.y = rint(([currentIntonationPoint semitone] + ZERO_SECTION) * [self sectionHeight]) + 0.5;

        //NSLog(@"%2d: currentPoint: %@", index, NSStringFromPoint(currentPoint));
        if (NSPointInRect(currentPoint, selectionRect)) {
            [_selectedPoints addObject:currentIntonationPoint];
        }
    }

    [self _selectionDidChange];
}

#pragma mark - Actions

- (IBAction)selectAll:(id)sender;
{
    [_selectedPoints removeAllObjects];
    [_selectedPoints addObjectsFromArray:[_eventList intonationPoints]];
    [self _selectionDidChange];
}

- (IBAction)delete:(id)sender;
{
    // We need to be careful that intermediate notifications don't change the selectedPoints array here.

    NSArray *points = [[NSArray alloc] initWithArray:_selectedPoints];
    [self deselectAllPoints];
    [_eventList removeIntonationPointsFromArray:points];
}

#ifdef PORTING
// Single click selects an intonation point
// Control clicking and then dragging adjusts the scale
// Rubberband selection of multiple points
// Double-clicking adds intonation point?
- (void)mouseDown:(NSEvent *)theEvent;
{
    CGFloat row, column;
    CGFloat row1, column1;
    CGFloat row2, column2;
    CGFloat temp, distance, distance1, tally = 0.0, tally1 = 0.0;
    CGFloat semitone;
    NSPoint mouseDownLocation = [theEvent locationInWindow];
    NSEvent *newEvent;
    NSUInteger i, ruleIndex = 0;
    MMIntonationPoint *iPoint;
    id tempPoint;

    [[self window] setAcceptsMouseMovedEvents:YES];

    /* Get information about the original location of the mouse event */
    mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
    row = mouseDownLocation.y;
    column = mouseDownLocation.x;

    /* Single click mouse events */
    if ([theEvent clickCount] == 1) {
        for (i = 0; i < [intonationPoints count]; i++) {
            tempPoint = [intonationPoints objectAtIndex:i];
            row1 = (([tempPoint semitone]+20.0) * ([self frame].size.height-70.0) / 30.0)+5.0;
            column1 = [tempPoint absoluteTime] / timeScale;

            if ( ((row1-row)*(row1-row) + (column1-column)*(column1-column)) < 100.0) {
                [selectedPoints removeAllObjects];
                [selectedPoints addObject:tempPoint];
                [self _selectionDidChange];

                return;
            }
        }

        if (([theEvent modifierFlags] && NSControlKeyMask) || ([theEvent modifierFlags] && NSControlKeyMask)) {
            flags.mouseBeingDragged = YES;
            [self lockFocus];
            [self updateScale:(float)column];
            [self unlockFocus];
            flags.mouseBeingDragged = NO;
            [self setNeedsDisplay:YES];
        }
    }
}
#endif

- (void)updateScale:(float)column;
{
#ifdef PORTING
    NSPoint mouseDownLocation;
    NSEvent *newEvent;
    CGFloat delta, originalScale;

    originalScale = timeScale;

    [[self window] setAcceptsMouseMovedEvents:YES];
    while (1) {
        newEvent = [NSApp nextEventMatchingMask:NSAnyEventMask
                          untilDate:[NSDate distantFuture]
                          inMode:NSEventTrackingRunLoopMode
                          dequeue:YES];
        mouseDownLocation = [newEvent locationInWindow];
        mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
        delta = column-mouseDownLocation.x;
        timeScale = originalScale + delta / 20.0;
        if (timeScale > 10.0)
            timeScale = 10.0;
        if (timeScale < 0.1)
            timeScale = 0.1;
        //[self clearView];
        [self drawGrid];
        [[self window] flushWindow];

        if ([newEvent type] == NSLeftMouseUp)
            break;
    }

    [[self window] setAcceptsMouseMovedEvents:NO];
#endif
}

- (void)deselectAllPoints;
{
    if ([_selectedPoints count] == 0)
        return;

    [_selectedPoints removeAllObjects];
    [self _selectionDidChange];
}

- (MMIntonationPoint *)selectedIntonationPoint;
{
    if ([_selectedPoints count] == 0)
        return nil;

    return [_selectedPoints objectAtIndex:0];
}

- (void)selectIntonationPoint:(MMIntonationPoint *)intonationPoint;
{
    [_selectedPoints removeAllObjects];
    if (intonationPoint != nil)
        [_selectedPoints addObject:intonationPoint];
    [self _selectionDidChange];
}

- (void)_selectionDidChange;
{
    NSNotification *notification = [NSNotification notificationWithName:MAIntonationViewSelectionDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([[self delegate] respondsToSelector:@selector(intonationViewSelectionDidChange:)])
        [[self delegate] intonationViewSelectionDidChange:notification];

    [self setNeedsDisplay:YES];
}

#pragma mark - View geometry

- (CGFloat)sectionHeight;
{
    NSRect bounds = [self bounds];
    CGFloat sectionHeight = (bounds.size.height - TOP_MARGIN - BOTTOM_MARGIN) / SECTION_COUNT;

    return sectionHeight;
}

- (NSPoint)graphOrigin;
{
    NSPoint graphOrigin;

    graphOrigin.x = LEFT_MARGIN;
    graphOrigin.y = [self bounds].size.height - TOP_MARGIN - SECTION_COUNT * [self sectionHeight];

    return graphOrigin;
}

- (void)updateEvents;
{
    [self resizeWidth];
    [self setNeedsDisplay:YES];
}

- (CGFloat)scaleXPosition:(CGFloat)xPosition;
{
    return floor(xPosition / _timeScale);
}

- (CGFloat)scaleWidth:(CGFloat)width;
{
    return floor(width / _timeScale);
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

- (CGFloat)convertYPositionToSemitone:(CGFloat)yPosition;
{
    NSPoint graphOrigin = [self graphOrigin];

    return ((yPosition - graphOrigin.y) / [self sectionHeight]) - ZERO_SECTION;
}

- (CGFloat)convertXPositionToTime:(CGFloat)xPosition;
{
    return xPosition * _timeScale;
}

- (void)intonationPointDidChange:(NSNotification *)notification;
{
    [self removeOldSelectedPoints];
    [self setNeedsDisplay:YES];
}

- (void)removeOldSelectedPoints;
{
    // This is another case where count cannot be unsigned.
    NSInteger count = [_selectedPoints count];
    for (NSInteger index = count - 1; index >= 0; index--) {
        if ([[_selectedPoints objectAtIndex:index] eventList] == nil)
            [_selectedPoints removeObjectAtIndex:index];
    }

    [self setNeedsDisplay:YES];
}

- (void)setFrame:(NSRect)newFrame;
{
    [super setFrame:newFrame];

    [_scaleView setSectionHeight:[self sectionHeight]];
    [_scaleView setYOrigin:[self graphOrigin].y];
}

@end
