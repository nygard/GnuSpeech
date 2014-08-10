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
    NSScrollView *enclosingScrollView;

    enclosingScrollView = [self enclosingScrollView];
    if (enclosingScrollView != nil) {
        NSRect documentVisibleRect, bounds;

        documentVisibleRect = [enclosingScrollView documentVisibleRect];
        bounds = [self bounds];

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

    if (_flags.shouldDrawSmoothPoints == YES && _flags.mouseBeingDragged == NO)
        [self drawSmoothPoints];

    if (_flags.shouldDrawSelection == YES) {
        NSRect selectionRect;

        selectionRect = [self rectFormedByPoint:_selectionPoint1 andPoint:_selectionPoint2];
        selectionRect.origin.x += 0.5;
        selectionRect.origin.y += 0.5;

        [[NSColor purpleColor] set];
        [NSBezierPath strokeRect:selectionRect];
    }

    [[self enclosingScrollView] reflectScrolledClipView:(NSClipView *)[self superview]];
}

- (void)drawGrid;
{
    NSBezierPath *bezierPath;
    NSRect bounds;
    NSPoint graphOrigin;
    CGFloat sectionHeight;
    NSUInteger index;

    bounds = NSIntegralRect([self bounds]);
    graphOrigin = [self graphOrigin];
    sectionHeight = [self sectionHeight];

    // Draw border around graph
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    //[bezierPath appendBezierPathWithRect:NSMakeRect(graphOrigin.x, graphOrigin.y, bounds.size.width - 2, SECTION_COUNT * sectionHeight)];
    [bezierPath appendBezierPathWithRect:NSMakeRect(graphOrigin.x - 2, graphOrigin.y, bounds.size.width, SECTION_COUNT * sectionHeight)];

    [[NSColor blackColor] set];
    [bezierPath stroke];

    // Draw semitone grid markers
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    for (index = 0; index < SECTION_COUNT; index++) {
        NSPoint aPoint;

        aPoint.x = 0.0;
        aPoint.y = rint(graphOrigin.y + index * sectionHeight) + 0.5;
        [bezierPath moveToPoint:aPoint];

        aPoint.x = bounds.size.width - 2;
        [bezierPath lineToPoint:aPoint];
    }

    [[NSColor lightGrayColor] set];
    [bezierPath stroke];

    // Draw the zero semitone line in black.
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    {
        NSPoint aPoint;

        aPoint.x = 0.0;
        aPoint.y = rint(graphOrigin.y + ZERO_SECTION * sectionHeight) + 0.5;
        [bezierPath moveToPoint:aPoint];

        aPoint.x = bounds.size.width - 2;
        [bezierPath lineToPoint:aPoint];
    }

    [[NSColor blackColor] set];
    [bezierPath stroke];
}

- (void)drawHorizontalScale;
{
    NSPoint graphOrigin;
    NSRect bounds, rect;
    NSBezierPath *bezierPath;
    NSPoint point;
    CGFloat time;
    NSRect cellFrame;

    bounds = NSIntegralRect([self bounds]);
    rect = bounds;

    graphOrigin = [self graphOrigin];
    rect.origin = graphOrigin;
    rect.origin.y -= BOTTOM_MARGIN;
    rect.size.height = BOTTOM_MARGIN;

    cellFrame.origin.x = 0.0;
    cellFrame.origin.y = graphOrigin.y - 10.0 - 12.0;
    cellFrame.size.width = 100.0;
    cellFrame.size.height = 12.0;

    point.x = 0.0;
    time = 0.0;

    bezierPath = [[NSBezierPath alloc] init];

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

        } else
            point.y -= 5;
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
    NSUInteger count, index;
    MMPosture *currentPosture;
    NSRect bounds;
    CGFloat currentX;
    NSUInteger postureIndex = 0;
    NSArray *events;

    bounds = NSIntegralRect([self bounds]);

    [[NSColor blackColor] set];
    [_timesFont set];

    events = [_eventList events];
    count = [events count];
    for (index = 0; index < count; index++) {
        currentX = ((float)[[events objectAtIndex:index] time] / _timeScale);

        if ([[events objectAtIndex:index] flag]) {
            currentPosture = [_eventList getPhoneAtIndex:postureIndex++];
            if (currentPosture != nil) {
                //NSLog(@"[currentPosture name]: %@", [currentPosture name]);
                [[NSColor blackColor] set];
                [[currentPosture name] drawAtPoint:NSMakePoint(currentX, bounds.size.height - POSTURE_Y_OFFSET) withAttributes:nil];
                //[postureTextFieldCell setStringValue:[currentPosture name]];
            }
        }
    }
}

// Put Rules on top
- (void)drawRules;
{
    NSBezierPath *bezierPath;
    CGFloat currentX, extraWidth;
    NSUInteger count, index;
    NSRect bounds;
    NSPoint graphOrigin;
    CGFloat sectionHeight;
    struct _rule *rule;

    bounds = NSIntegralRect([self bounds]);
    graphOrigin = [self graphOrigin];
    sectionHeight = [self sectionHeight];

    [[NSColor blackColor] set];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    currentX = 0.0;
    extraWidth = 0.0;

    count = [_eventList ruleCount];
    for (index = 0; index < count; index++) {
        NSPoint aPoint;
        NSRect ruleFrame;

        rule = [_eventList getRuleAtIndex:index];

        ruleFrame.origin.x = currentX;
        ruleFrame.origin.y = bounds.size.height - RULE_Y_OFFSET;
        ruleFrame.size.height = RULE_HEIGHT;
        ruleFrame.size.width = [self scaleWidth:rule->duration] + extraWidth;
        NSFrameRect(ruleFrame);

        ruleFrame.size.height = 15.0;
        [_ruleDurationTextFieldCell setDoubleValue:rule->duration];
        [_ruleDurationTextFieldCell drawWithFrame:ruleFrame inView:self];

        ruleFrame.size.height += 12.0;
        [_ruleIndexTextFieldCell setIntegerValue:rule->number];
        [_ruleIndexTextFieldCell drawWithFrame:ruleFrame inView:self];

        aPoint.x = [self scaleXPosition:rule->beat] + 0.5;
        aPoint.y = graphOrigin.y + SECTION_COUNT * sectionHeight - 1.0;
        [bezierPath moveToPoint:aPoint];

        aPoint.y = graphOrigin.y;
        [bezierPath lineToPoint:aPoint];

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
    CGFloat extraWidth;
    NSUInteger count, index;
    NSRect ruleFrame;
    NSPoint graphOrigin;
    CGFloat sectionHeight;
    struct _rule *rule;

    graphOrigin = [self graphOrigin];
    sectionHeight = [self sectionHeight];

    ruleFrame.origin.y = graphOrigin.y;
    ruleFrame.size.height = SECTION_COUNT * sectionHeight;

    ruleFrame.origin.x = 0.0;
    extraWidth = 0.0;

    count = [_eventList ruleCount];
    for (index = 0; index < count; index++) {
        rule = [_eventList getRuleAtIndex:index];

        ruleFrame.size.width = [self scaleWidth:rule->duration] + extraWidth;
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
    NSBezierPath *bezierPath;
    NSUInteger count, index;
    NSPoint currentPoint;
    NSPoint graphOrigin;
    NSArray *intonationPoints = [_eventList intonationPoints];
    MMIntonationPoint *currentIntonationPoint;

    graphOrigin = [self graphOrigin];

    [[NSColor blackColor] set];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    [bezierPath moveToPoint:graphOrigin];

    count = [intonationPoints count];
    for (index = 0; index < count; index++) {
        currentIntonationPoint = [intonationPoints objectAtIndex:index];
        currentPoint.x = [self scaleXPosition:[currentIntonationPoint absoluteTime]];
        currentPoint.y = rint(graphOrigin.y + ([currentIntonationPoint semitone] + ZERO_SECTION) * [self sectionHeight]) + 0.5;
        [bezierPath lineToPoint:currentPoint];

        [NSBezierPath drawCircleMarkerAtPoint:currentPoint];
    }
    [bezierPath stroke];

    [[NSColor blueColor] set];

    count = [_selectedPoints count];
    for (index = 0; index < count; index++) {
        currentIntonationPoint = [_selectedPoints objectAtIndex:index];
        currentPoint.x = [self scaleXPosition:[currentIntonationPoint absoluteTime]];
        currentPoint.y = rint(graphOrigin.y + ([currentIntonationPoint semitone] + ZERO_SECTION) * [self sectionHeight]) + 0.5;
        [NSBezierPath highlightMarkerAtPoint:currentPoint];
    }
}

// TODO (2004-03-15): See if we can just use the code from -applyIntonationSmooth instead.
- (void)drawSmoothPoints;
{
    double a, b, c, d;
    double x1, y1, m1, x12, x13;
    double x2, y2, m2, x22, x23;
    double denominator;
    double x, y;
    NSUInteger i, j;
    id point1, point2;
    NSBezierPath *bezierPath;
    NSArray *intonationPoints = [_eventList intonationPoints];
    NSPoint graphOrigin;
    NSPoint aPoint;

    if ([intonationPoints count] < 2)
        return;

    graphOrigin = [self graphOrigin];

    for (j = 0; j < [intonationPoints count] - 1; j++) {
        point1 = [intonationPoints objectAtIndex:j];
        point2 = [intonationPoints objectAtIndex:j + 1];

        x1 = [point1 absoluteTime];
        y1 = [point1 semitone] + ZERO_SECTION;
        m1 = [point1 slope];

        x2 = [point2 absoluteTime];
        y2 = [point2 semitone] + ZERO_SECTION;
        m2 = [point2 slope];

        x12 = x1*x1;
        x13 = x12*x1;

        x22 = x2*x2;
        x23 = x22*x2;

        denominator = (x2 - x1);
        denominator = denominator * denominator * denominator;

        d = ( -(y2*x13) + 3*y2*x12*x2 + m2*x13*x2 + m1*x12*x22 - m2*x12*x22 - 3*x1*y1*x22 - m1*x1*x23 + y1*x23) / denominator;
        c = ( -(m2*x13) - 6*y2*x1*x2 - 2*m1*x12*x2 - m2*x12*x2 + 6*x1*y1*x2 + m1*x1*x22 + 2*m2*x1*x22 + m1*x23) / denominator;
        b = ( 3*y2*x1 + m1*x12 + 2*m2*x12 - 3*x1*y1 + 3*x2*y2 + m1*x1*x2 - m2*x1*x2 - 3*y1*x2 - 2*m1*x22 - m2*x22) / denominator;
        a = ( -2*y2 - m1*x1 - m2*x1 + 2*y1 + m1*x2 + m2*x2) / denominator;

        //NSLog(@"\n===\n x1 = %f y1 = %f m1 = %f", x1, y1, m1);
        //NSLog(@"x2 = %f y2 = %f m2 = %f", x2, y2, m2);
        //NSLog(@"a = %f b = %f c = %f d = %f", a, b, c, d);

        // The curve looks better (darker) without adding the extra 0.5 to the y positions.
        aPoint.x = [self scaleXPosition:x1];
        aPoint.y = graphOrigin.y + y1 * [self sectionHeight];

        bezierPath = [[NSBezierPath alloc] init];
        [bezierPath moveToPoint:aPoint];
        for (i = (int)x1; i <= (int)x2; i++) {
            x = (double)i;
            y = x*x*x*a + x*x*b + x*c + d;

            aPoint.x = [self scaleXPosition:i];
            aPoint.y = graphOrigin.y + y * [self sectionHeight];
            [bezierPath lineToPoint:aPoint];
        }

        [[NSColor blackColor] set];
        [bezierPath stroke];
    }
}

#pragma mark - Event handling

- (void)mouseEntered:(NSEvent *)theEvent;
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

- (void)keyDown:(NSEvent *)keyEvent;
{
    NSString *characters;
    NSUInteger index, length;
    unichar ch;

    NSUInteger ruleCount;

    ruleCount = [_eventList ruleCount];

    characters = [keyEvent characters];
    length = [characters length];
    for (index = 0; index < length; index++) {
        NSUInteger pointCount, pointIndex;

        pointCount = [_selectedPoints count];

        ch = [characters characterAtIndex:index];
        //NSLog(@"index: %d, character: %@", index, [characters substringWithRange:NSMakeRange(index, 1)]);

        switch (ch) {
          case NSDeleteFunctionKey:
          case NSDeleteCharacter:
              //NSLog(@"delete");
              [self delete:nil];
              break;

          case NSLeftArrowFunctionKey:
              //NSLog(@"left arrow");
              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  if ([[_selectedPoints objectAtIndex:pointIndex] ruleIndex] - 1 < 0) {
                      NSBeep();
                      return;
                  }
              }

              for (pointIndex = 0; pointIndex < pointCount; pointIndex++)
                  [[_selectedPoints objectAtIndex:pointIndex] decrementRuleIndex];
              break;

          case NSRightArrowFunctionKey:
              //NSLog(@"right arrow");
              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  if ([[_selectedPoints objectAtIndex:pointIndex] ruleIndex] + 1 >= ruleCount) {
                      NSBeep();
                      return;
                  }
              }

              for (pointIndex = 0; pointIndex < pointCount; pointIndex++)
                  [[_selectedPoints objectAtIndex:pointIndex] incrementRuleIndex];
              break;

          case NSUpArrowFunctionKey:
              //NSLog(@"up arrow");
              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  if ([[_selectedPoints objectAtIndex:pointIndex] semitone] + 1.0 > 10.0) {
                      NSBeep();
                      return;
                  }
              }

              for (pointIndex = 0; pointIndex < pointCount; pointIndex++)
                  [[_selectedPoints objectAtIndex:pointIndex] incrementSemitone];
              break;

          case NSDownArrowFunctionKey:
              //NSLog(@"down arrow");
              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  if ([[_selectedPoints objectAtIndex:pointIndex] semitone] - 1.0 < -20.0) {
                      NSBeep();
                      return;
                  }
              }

              for (pointIndex = 0; pointIndex < pointCount; pointIndex++)
                  [[_selectedPoints objectAtIndex:pointIndex] decrementSemitone];
              break;

          default:
              NSLog(@"index: %lu, character: %@ (%d)", index, [characters substringWithRange:NSMakeRange(index, 1)], [characters characterAtIndex:index]);
        }
    }
}

- (void)mouseDown:(NSEvent *)mouseEvent;
{
    NSPoint hitPoint;
#if 0
    if ([self isEnabled] == NO) {
        [super mouseDown:mouseEvent];
        return;
    }
#endif
    // Force this to be first responder, since nothing else seems to work!
    [[self window] makeFirstResponder:self];

    hitPoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
    //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));

    [self setShouldDrawSelection:NO];
    [_selectedPoints removeAllObjects];
    [self _selectionDidChange];

    if ([mouseEvent clickCount] == 1) {
        if ([mouseEvent modifierFlags] & NSAlternateKeyMask) {
            MMIntonationPoint *newIntonationPoint;
            CGFloat absoluteTime;
            NSUInteger ruleIndex;
            double offsetTime;

            absoluteTime = [self convertXPositionToTime:hitPoint.x];
            [_eventList getRuleIndex:&ruleIndex offsetTime:&offsetTime forAbsoluteTime:absoluteTime];

            newIntonationPoint = [[MMIntonationPoint alloc] init];
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

- (void)mouseDragged:(NSEvent *)mouseEvent;
{
    NSPoint hitPoint;

    //NSLog(@" > %s", _cmd);

//    if ([self isEnabled] == NO)
//        return;

    [self autoscroll:mouseEvent];
    if (_flags.shouldDrawSelection == YES) {
        hitPoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
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
    NSPoint graphOrigin;
    NSRect selectionRect;
    NSUInteger count, index;
    //float timeScale;
    NSArray *intonationPoints;

    [_selectedPoints removeAllObjects];

    //NSLog(@"%s, cacheTag: %d", _cmd, cacheTag);
    graphOrigin = [self graphOrigin];
    //timeScale = [self timeScale];

    selectionRect = [self rectFormedByPoint:point1 andPoint:point2];
    selectionRect.origin.x -= graphOrigin.x;
    selectionRect.origin.y -= graphOrigin.y;

    //NSLog(@"%s, selectionRect: %@", _cmd, NSStringFromRect(selectionRect));

    intonationPoints = [_eventList intonationPoints];
    count = [intonationPoints count];
    //NSLog(@"%d display points", count);
    for (index = 0; index < count; index++) {
        MMIntonationPoint *currentIntonationPoint;
        NSPoint currentPoint;

        currentIntonationPoint = [intonationPoints objectAtIndex:index];
        currentPoint.x = [self scaleXPosition:[currentIntonationPoint absoluteTime]];
        currentPoint.y = rint(([currentIntonationPoint semitone] + ZERO_SECTION) * [self sectionHeight]) + 0.5;

        //NSLog(@"%2d: currentPoint: %@", index, NSStringFromPoint(currentPoint));
        if (NSPointInRect(currentPoint, selectionRect) == YES) {
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
    NSArray *points;

    // We need to be careful that intermediate notifications don't change the selectedPoints array here.

    points = [[NSArray alloc] initWithArray:_selectedPoints];
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
    struct _rule *rule;
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

- (void)selectIntonationPoint:(MMIntonationPoint *)anIntonationPoint;
{
    [_selectedPoints removeAllObjects];
    if (anIntonationPoint != nil)
        [_selectedPoints addObject:anIntonationPoint];
    [self _selectionDidChange];
}

- (void)_selectionDidChange;
{
    NSNotification *aNotification;

    aNotification = [NSNotification notificationWithName:MAIntonationViewSelectionDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotification:aNotification];

    if ([[self delegate] respondsToSelector:@selector(intonationViewSelectionDidChange:)] == YES)
        [[self delegate] intonationViewSelectionDidChange:aNotification];

    [self setNeedsDisplay:YES];
}

#pragma mark - View geometry

- (CGFloat)sectionHeight;
{
    NSRect bounds;
    CGFloat sectionHeight;

    bounds = [self bounds];
    sectionHeight = (bounds.size.height - TOP_MARGIN - BOTTOM_MARGIN) / SECTION_COUNT;

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

- (CGFloat)convertYPositionToSemitone:(CGFloat)yPosition;
{
    NSPoint graphOrigin;

    graphOrigin = [self graphOrigin];

    return ((yPosition - graphOrigin.y) / [self sectionHeight]) - ZERO_SECTION;
}

- (CGFloat)convertXPositionToTime:(CGFloat)xPosition;
{
    return xPosition * _timeScale;
}

- (void)intonationPointDidChange:(NSNotification *)aNotification;
{
    [self removeOldSelectedPoints];
    [self setNeedsDisplay:YES];
}

- (void)removeOldSelectedPoints;
{
    NSInteger count, index;

    // This is another case where count cannot be unsigned.
    count = [_selectedPoints count];
    for (index = count - 1; index >= 0; index--) {
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
